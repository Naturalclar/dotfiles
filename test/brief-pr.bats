#!/usr/bin/env bats

@test "brief-pr renders safe standalone HTML in private storage" {
  python3 - "$BATS_TEST_DIRNAME/../.claude/skills/brief-pr/scripts/render.py" <<'PY'
from html.parser import HTMLParser
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
renderer = Path(sys.argv.pop()).resolve()
spec = importlib.util.spec_from_file_location('brief_renderer', renderer)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

# Entirely fictional; never add captured PR contents to this fixture.
def fixture():
    data = {'title': 'Example: preserve draft notes', 'url': 'https://example.invalid/project/pull/42',
            'lang': 'en', 'snapshot': {'observed': '2026-01-01T00:00:00Z',
            'base': 'a' * 40, 'head': 'b' * 40, 'coverage': 'Fictional demonstration only.'}}
    for key, label in m.SECTIONS:
        data[key] = [{'kind': 'unknown', 'text': label + ': evidence not yet available.'}]
    return data

class Document(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.tags = []
        self.texts = []
        self.feed(source)
    def handle_starttag(self, tag, attrs):
        self.tags.append((tag, dict(attrs)))
    def handle_data(self, value):
        self.texts.append(value)

class RenderTests(unittest.TestCase):
    def test_untrusted_text_never_becomes_markup(self):
        attack = '</style><script>alert(1)</script><img src=x onerror=alert(2)> & "quoted"'
        data = fixture()
        data['title'] = data['snapshot']['coverage'] = attack
        data['changes'] = [{'kind': 'verified', 'text': attack,
                            'sources': [{'label': attack, 'url': 'https://example.invalid/code?q="value"&x=1'}]}]
        doc = Document(m.render(data))
        self.assertIn(attack, doc.texts)
        self.assertFalse(any(tag in ('script', 'img', 'iframe', 'object', 'embed', 'link') for tag, _ in doc.tags))
        self.assertFalse(any(k.startswith('on') for _, attrs in doc.tags for k in attrs))
        self.assertEqual([attrs['href'] for tag, attrs in doc.tags if tag == 'a' and 'code?' in attrs.get('href', '')],
                         ['https://example.invalid/code?q="value"&x=1'])

    def test_rejects_active_or_invalid_links(self):
        for target in ('javascript:alert(1)', 'data:text/html,hello', '//example.invalid',
                       'http://example.invalid', 'https://user:pass@example.invalid',
                       'https://example.invalid/\nscript', 'https://example.invalid\\evil'):
            for placement in ('pr', 'source'):
                with self.subTest(target=target, placement=placement):
                    data = fixture()
                    if placement == 'pr':
                        data['url'] = target
                    else:
                        data['purpose'][0]['sources'] = [{'label': 'source', 'url': target}]
                    with self.assertRaises(ValueError):
                        m.render(data)

    def test_sections_navigation_and_evidence_labels(self):
        data = fixture()
        data['purpose'][0]['kind'] = 'author'
        data['changes'][0]['kind'] = 'verified'
        doc = Document(m.render(data))
        ids = {attrs['id'] for _, attrs in doc.tags if 'id' in attrs}
        self.assertTrue(all(attrs['href'][1:] in ids for tag, attrs in doc.tags
                            if tag == 'a' and attrs['href'].startswith('#')))
        self.assertEqual(len([tag for tag, _ in doc.tags if tag == 'h1']), 1)
        self.assertEqual(len([tag for tag, _ in doc.tags if tag == 'h2']), 8)
        for label in m.KINDS.values():
            self.assertIn(label, doc.texts)
        self.assertTrue(any(attrs.get('name') == 'viewport' for _, attrs in doc.tags))
        self.assertTrue(any("default-src 'none'" in attrs.get('content', '') for _, attrs in doc.tags))

    def test_missing_evidence_and_short_sha_fail(self):
        for key in ('purpose', 'flow', 'tests'):
            data = fixture()
            data[key] = []
            with self.assertRaises(ValueError):
                m.render(data)
        data = fixture()
        data['snapshot']['head'] = 'abc123'
        with self.assertRaises(ValueError):
            m.render(data)

    def test_cli_private_output_and_repository_refusal(self):
        with tempfile.TemporaryDirectory() as root:
            env = dict(os.environ, TMPDIR=root)
            result = subprocess.run([sys.executable, str(renderer)], input=json.dumps(fixture()),
                                    text=True, capture_output=True, env=env, check=True)
            output = Path(result.stdout.strip())
            self.assertEqual(output.name, 'brief.html')
            self.assertEqual(output.parent.parent.resolve(), Path(root).resolve())
            self.assertEqual(stat.S_IMODE(output.stat().st_mode), 0o600)
            self.assertEqual(stat.S_IMODE(output.parent.stat().st_mode), 0o700)
            self.assertIn('Example: preserve draft notes', output.read_text())
            (Path(root) / '.git').mkdir()
            with patch.object(m.tempfile, 'gettempdir', return_value=root):
                with self.assertRaises(ValueError):
                    m.save('not written')
            (Path(root) / '.git').rmdir()
            (Path(root) / '.git').write_text('gitdir: elsewhere')
            with patch.object(m.tempfile, 'gettempdir', return_value=root):
                with self.assertRaises(ValueError):
                    m.save('not written')

unittest.main()
PY
}
