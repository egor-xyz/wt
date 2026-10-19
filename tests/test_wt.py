"""Exercise discovery and the real zsh picker without user data."""
import fcntl
import json
import os
from pathlib import Path
import pty
import select
import shutil
import struct
import subprocess
import tempfile
import termios
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]


class PickerTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = Path(self.tmp.name).resolve()
        self.repo = self.home / 'repo with spaces'
        self.run_cmd('git', 'init', '-q', str(self.repo))
        self.run_cmd('git', '-C', str(self.repo), '-c', 'user.name=Test',
                     '-c', 'user.email=test@example.com', 'commit', '-qm', 'init', '--allow-empty')
        self.worktree = self.repo / '.worktrees' / 'risk-policy-wiring'
        self.run_cmd('git', '-C', str(self.repo), 'worktree', 'add', '-qb', 'risk', str(self.worktree))
        self.outside = self.home / 'external-tree'
        self.run_cmd('git', '-C', str(self.repo), 'worktree', 'add', '-qb', 'external', str(self.outside))
        self.codex = self.home / 'custom-codex'
        self.env = dict(os.environ, HOME=str(self.home), CODEX_HOME=str(self.codex),
                        XDG_CONFIG_HOME=str(self.home / 'config'), WT_NO_ROBOT='1', WT_AUTO_UPDATE='0')
        self.session('parent', self.worktree)
        self.session('child', self.worktree, {'subagent': {'other': 'guardian'}})
        (self.codex / 'session_index.jsonl').write_text(json.dumps({
            'id': 'parent', 'thread_name': 'Risk policy wiring', 'updated_at': '2026-10-19T10:00:00Z'}) + '\n')

    def run_cmd(self, *args):
        return subprocess.run(args, check=True, capture_output=True, text=True).stdout

    def session(self, sid, cwd, source='vscode'):
        folder = self.codex / 'sessions' / '2026' / '10' / '19'
        folder.mkdir(parents=True, exist_ok=True)
        (folder / f'{sid}.jsonl').write_text(json.dumps({'type': 'session_meta', 'payload': {
            'id': sid, 'cwd': str(cwd), 'timestamp': '2026-10-19T09:00:00Z', 'source': source}}) + '\n')

    def scan(self):
        out = subprocess.check_output(['zsh', '-fc',
            'fpath=("$1/functions" $fpath); autoload -Uz _wt_scan; _wt_scan',
            'test', str(ROOT)], env=self.env, text=True)
        return {r[0]: r for r in (line.split('\t') for line in out.splitlines())}

    def test_codex_only_and_registered_worktrees(self):
        self.session('missing', self.home / 'deleted')
        rows = self.scan()
        self.assertEqual(set(rows), {str(self.repo), str(self.worktree), str(self.outside)})
        row = rows[str(self.worktree)]
        self.assertEqual(row[1:], ['Risk policy wiring', '1', '0', str(self.repo), 'Codex'])
        self.assertEqual(rows[str(self.repo)][2], '0')

    def test_live_claude_wins_and_dead_claude_is_ignored(self):
        folder = self.home / '.claude' / 'sessions'
        folder.mkdir(parents=True)
        for name, pid, cwd in [('live', os.getpid(), self.worktree), ('dead', 2147483647, self.outside)]:
            (folder / f'{name}.json').write_text(json.dumps({
                'updatedAt': 1, 'pid': pid, 'cwd': str(cwd), 'name': name}))
        rows = self.scan()
        self.assertEqual(rows[str(self.worktree)][1], 'live')
        self.assertEqual(rows[str(self.worktree)][5], 'Claude Code')
        self.assertEqual(rows[str(self.outside)][1], '-')
        self.assertEqual(rows[str(self.outside)][5], '-')

    def test_metadata_fallback_without_index(self):
        (self.codex / 'session_index.jsonl').unlink()
        rows = self.scan()
        self.assertEqual(rows[str(self.worktree)][1], 'parent')

    def test_session_in_worktree_subdirectory(self):
        subdir = self.worktree / 'src'
        subdir.mkdir()
        self.session('subdir', subdir)
        rows = self.scan()
        self.assertEqual(rows[str(subdir)][4], str(self.repo))
        self.assertEqual(rows[str(subdir)][2], '1')

    def test_claude_only(self):
        shutil.rmtree(self.codex)
        folder = self.home / '.claude' / 'sessions'
        folder.mkdir(parents=True)
        (folder / 'live.json').write_text(json.dumps({
            'updatedAt': 1, 'pid': os.getpid(), 'cwd': str(self.repo), 'name': 'Claude'}))
        self.assertEqual(len(self.scan()), 3)

    def test_picker_search_select_and_no_idle_redraw(self):
        master, slave = pty.openpty()
        self.addCleanup(os.close, master)
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 30, 160, 0, 0))
        proc = subprocess.Popen(['zsh', '-fc',
            'source "$1/wt.plugin.zsh"; wt; print -r -- "SELECTED:$PWD"', 'test', str(ROOT)],
            stdin=slave, stdout=slave, stderr=slave, env=self.env, start_new_session=True)
        os.close(slave)
        self.addCleanup(lambda: proc.poll() is None and proc.kill())
        output = b''
        deadline = time.monotonic() + 8
        while b'quit' not in output and time.monotonic() < deadline:
            if select.select([master], [], [], .2)[0]:
                output += os.read(master, 65536)
        self.assertIn(b'Risk policy wiring', output)
        self.assertIn(b'tool', output)
        self.assertIn(b'Codex', output)
        self.assertNotIn(b'Codex:', output)
        self.assertFalse(select.select([master], [], [], .4)[0], 'picker redraws while idle')
        os.write(master, b'risk-policy-wiring')
        time.sleep(.2)
        os.write(master, b'\r')
        while proc.poll() is None:
            if select.select([master], [], [], .2)[0]:
                try:
                    output += os.read(master, 65536)
                except OSError:
                    break
            self.assertLess(time.monotonic(), deadline, 'picker did not exit')
        proc.wait(timeout=2)
        self.assertEqual(proc.returncode, 0, output.decode(errors='replace'))
        self.assertIn(f'SELECTED:{self.worktree}'.encode(), output)


if __name__ == '__main__':
    unittest.main()
