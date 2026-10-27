#!/usr/bin/env python3
"""Render a plain-data PR brief from stdin into a private, standalone HTML file."""
import html
import json
import os
from pathlib import Path
import re
import tempfile
from urllib.parse import urlsplit

SECTIONS = (
    ('purpose', 'Purpose'), ('context', 'Prerequisites'),
    ('changes', 'Change map'), ('reading', 'Reading order'),
    ('flow', 'Processing flow'), ('risks', 'Risks and questions'),
    ('tests', 'Tests and unknowns'),
)
KINDS = {'author': "Author's account", 'verified': 'Verified in code',
         'unknown': 'Inference / unknown'}
CSS = '''
:root { color-scheme: light; font-family: system-ui, sans-serif; color: #182638; background: #eef2f6; }
* { box-sizing: border-box; }
body { margin: 0; line-height: 1.65; }
a { color: #164db0; text-decoration-thickness: .1em; text-underline-offset: .18em; }
a:focus-visible { outline: 3px solid #8a3900; outline-offset: 4px; }
.skip { position: absolute; left: 1rem; top: -10rem; background: white; padding: .5rem; }
.skip:focus { top: 1rem; }
header, main, footer { max-width: 1120px; margin: auto; padding: 2rem; }
header { padding-bottom: 1rem; }
h1 { font-size: clamp(1.8rem, 4vw, 3rem); line-height: 1.2; margin: .4rem 0 1rem; overflow-wrap: anywhere; }
h2 { font-size: 1.35rem; margin: 0 0 1rem; }
.kicker { color: #405168; font-weight: 700; letter-spacing: .1em; text-transform: uppercase; }
nav { display: flex; flex-wrap: wrap; gap: .5rem 1.2rem; padding: 1rem 0; }
main { display: grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap: 1.2rem; padding-top: 1rem; }
section { background: #fff; border: 1px solid #ccd5e0; border-radius: 12px; padding: 1.5rem; min-width: 0; scroll-margin-top: 1rem; }
#purpose, #changes, #flow, #snapshot { grid-column: 1 / -1; }
ol, ul { padding-left: 1.4rem; margin-bottom: 0; }
li { margin-bottom: 1rem; padding-left: .2rem; }
p { margin: .5rem 0; }
.text { white-space: pre-wrap; overflow-wrap: anywhere; }
.badge { display: inline-block; font-size: .8rem; font-weight: 700; border-radius: 4px; padding: .1rem .5rem; background: #e5edf6; color: #243e5e; }
.author { background: #eee8fa; color: #50327a; }
.unknown { background: #fff0d5; color: #714400; }
.source { font-size: .9rem; overflow-wrap: anywhere; }
dl { display: grid; grid-template-columns: 8rem minmax(0, 1fr); gap: .5rem 1rem; margin: 0; }
dt { font-weight: 700; } dd { margin: 0; overflow-wrap: anywhere; }
code { font-family: ui-monospace, monospace; font-size: .9em; }
footer { color: #405168; padding-top: 0; }
@media (max-width: 700px) { main { grid-template-columns: minmax(0, 1fr); } header, main, footer { padding: 1rem; } section { padding: 1.1rem; } dl { grid-template-columns: 1fr; } dd { margin-bottom: .5rem; } }
@media print { :root { background: white; } main { display: block; } section { margin-bottom: 1rem; break-inside: avoid; } nav, .skip { display: none; } }
'''


def text(value):
    if not isinstance(value, str):
        raise ValueError('Expected plain text')
    return html.escape(value, quote=True)


def url(value):
    if not isinstance(value, str) or any(c.isspace() or ord(c) < 32 for c in value):
        raise ValueError('Invalid source URL')
    parsed = urlsplit(value)
    if parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.password or '\\' in value:
        raise ValueError('Sources must be HTTPS URLs without credentials')
    return text(value)


def link(label, target):
    return f'<a href="{url(target)}" rel="noreferrer">{text(label)}</a>'


def render(data):
    title = text(data['title'])
    snapshot = data['snapshot']
    for key in ('base', 'head'):
        if not re.fullmatch(r'[0-9a-fA-F]{40,64}', snapshot[key]):
            raise ValueError(f'{key} must be a full SHA')
    parts = ['<!doctype html><html lang="' + text(data.get('lang', 'en')) + '"><head>',
             '<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">',
             '<meta name="referrer" content="no-referrer">',
             '<meta http-equiv="Content-Security-Policy" content="default-src \'none\'; style-src \'unsafe-inline\'; base-uri \'none\'; form-action \'none\'">',
             f'<title>{title} — PR brief</title><style>{CSS}</style></head><body>',
             '<a class="skip" href="#main">Skip to brief</a><header><div class="kicker">PR reading brief</div>',
             f'<h1>{title}</h1><p>{link("Pull request", data["url"])}</p>',
             '<nav aria-label="Brief sections">']
    for key, label in SECTIONS + (('snapshot', 'Snapshot'),):
        parts.append(f'<a href="#{key}">{label}</a>')
    parts.append('</nav></header><main id="main">')
    for key, label in SECTIONS:
        entries = data[key]
        if not isinstance(entries, list) or not entries:
            raise ValueError(f'{key} needs at least one entry; mark missing evidence unknown')
        tag = 'ol' if key in ('reading', 'flow') else 'ul'
        parts.append(f'<section id="{key}" aria-labelledby="h-{key}"><h2 id="h-{key}">{label}</h2><{tag}>')
        for entry in entries:
            kind = entry['kind']
            if kind not in KINDS:
                raise ValueError('Unknown evidence kind')
            parts.append(f'<li><span class="badge {kind}">{KINDS[kind]}</span><p class="text">{text(entry["text"])}</p>')
            for source in entry.get('sources', []):
                parts.append(f'<p class="source">Source: {link(source["label"], source["url"])}</p>')
            parts.append('</li>')
        parts.append(f'</{tag}></section>')
    parts.append('<section id="snapshot" aria-labelledby="h-snapshot"><h2 id="h-snapshot">Snapshot and coverage</h2><dl>')
    for key, label in (('observed', 'Observed'), ('base', 'Base SHA'), ('head', 'Head SHA'), ('merge_base', 'Merge base'), ('coverage', 'Coverage')):
        if key in snapshot:
            parts.append(f'<dt>{label}</dt><dd class="text">{text(snapshot[key])}</dd>')
        elif key != 'merge_base':
            raise ValueError(f'Missing snapshot {key}')
    parts.append('</dl></section></main><footer>Private reading aid · No review or merge action. Evidence labels distinguish claims, code observations, and uncertainty.</footer></body></html>')
    return '\n'.join(parts)


def save(document):
    root = Path(tempfile.gettempdir()).resolve()
    if any((p / '.git').exists() for p in (root, *root.parents)):
        raise ValueError('Temporary directory must be outside Git repositories')
    directory = Path(tempfile.mkdtemp(prefix='brief-pr-', dir=root))
    os.chmod(directory, 0o700)
    output = directory / 'brief.html'
    with output.open('x', encoding='utf-8') as stream:
        os.chmod(output, 0o600)
        stream.write(document)
    return output


if __name__ == '__main__':
    import sys
    try:
        print(save(render(json.load(sys.stdin))))
    except (ValueError, KeyError, TypeError, OSError) as error:
        # Do not echo possibly private input values in diagnostics.
        print(f'Cannot render brief ({type(error).__name__}); check schema and private temp directory.', file=sys.stderr)
        sys.exit(1)
