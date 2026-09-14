"""Check static routes, assets, downloads and archive integrity without a browser."""
from pathlib import Path
import hashlib
import json
import re
import zipfile
from html.parser import HTMLParser

DIST = Path(__file__).resolve().parent / 'dist'
markup = (DIST / 'index.html').read_text() + (DIST / 'content.js').read_text()
class References(HTMLParser):
    def __init__(self):
        super().__init__()
        self.refs = []
        self.ids = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.append(attrs['id'])
        for key in ('src', 'href'):
            if key in attrs:
                self.refs.append(attrs[key])
parser = References()
parser.feed(markup)
assert len(parser.ids) == len(set(parser.ids)), 'Duplicate HTML IDs'
for ref in parser.refs:
    if ref.startswith('data:'):
        continue
    if ref.startswith('#'):
        assert ref[1:] in parser.ids, f'Missing target: {ref}'
    else:
        if re.match(r'https?://', ref):
            assert ref.startswith(('https://github.com/Tia-Lin/PongFetch', 'https://creativecommons.org/licenses/by-nc-sa/4.0/')), f'Unexpected external link: {ref}'
            continue
        assert (DIST / ref).is_file(), f'Missing file: {ref}'
for palette in ('sunshine', 'tangerine', 'poolside'):
    for view in ('hero', 'front'):
        assert (DIST / 'assets' / f'{palette}-{view}.webp').is_file()
manifest = json.loads((DIST / 'downloads' / 'manifest.json').read_text())
for name, expected in manifest.items():
    data = (DIST / 'downloads' / name).read_bytes()
    assert len(data) == expected['bytes'], name
    assert hashlib.sha256(data).hexdigest() == expected['sha256'], name
    if name.endswith(('.zip', '.3mf')):
        with zipfile.ZipFile(DIST / 'downloads' / name) as archive:
            assert archive.testzip() is None, f'Archive CRC failure: {name}'
for name in ('PongFetch_Rev3_Design_Source.zip', 'PongFetch_Rev3_Maker_Bundle.zip'):
    with zipfile.ZipFile(DIST / 'downloads' / name) as archive:
        for included in ('LICENSE.md', 'CC-BY-NC-SA-4.0.txt', 'THIRD_PARTY_NOTICES.md', 'Branding.scad'):
            assert included in archive.namelist(), (name, included)
for route in ('home', 'guide', 'downloads', 'kit', 'license'):
    assert route in parser.ids
print(f'PASS: 5 page targets, {len(parser.refs)} references, 6 palette assets, {len(manifest)} downloads, bundled licenses and archive CRCs.')
