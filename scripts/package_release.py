"""Build the rev3.0 download set plus Accessories from a verified clean snapshot.

Run from a clean committed snapshot to avoid publishing local slicer experiments.
Output ZIPs are release assets, not tracked copies of the design files.
"""
import argparse, hashlib, json, shutil, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument('--output-dir', required=True, type=Path)
parser.add_argument('--source-commit', required=True, help='Commit represented by this snapshot')
args = parser.parse_args()
OUT = args.output_dir.resolve()
OUT.mkdir(parents=True, exist_ok=True)
LICENSE = ['LICENSE.md', 'CC-BY-NC-SA-4.0.txt', 'THIRD_PARTY_NOTICES.md']
DESIGN = ['SmallPicker.scad', 'SideLatch.scad', 'ColletSocket.scad', 'Branding.scad']
CORE = ['SmallPicker.stl', 'Collet.stl', 'ColletCap.stl',
        'prints/PongFetch_Rev3_Frame.3mf', 'prints/PongFetch_Rev3_Handle_Parts.3mf']
ACCESSORIES = sorted(str(p.relative_to(ROOT)) for p in (ROOT/'Accessories').rglob('*') if p.is_file())
assert ACCESSORIES and not any('prototype' in n.lower() for n in ACCESSORIES)
info = {'core_revision': '3.0', 'original_core_tag': 'v3.0',
        'supplement': 'Accessories', 'supplement_date': '2026-09-22',
        'source_commit': args.source_commit, 'repository': 'https://github.com/Tia-Lin/PongFetch',
        'note': 'The original v3.0 tag is unchanged. This curated bundle adds Accessories from source_commit.'}

def package(name, files, texts=None):
    texts = dict(texts or {})
    contents = {n:(ROOT/n).read_bytes() for n in files}
    contents.update({n:s.encode() for n,s in texts.items()})
    details = {**info, 'sha256': {n:hashlib.sha256(d).hexdigest() for n,d in sorted(contents.items())}}
    contents['PACKAGE_INFO.json'] = (json.dumps(details, indent=2)+'\n').encode()
    with zipfile.ZipFile(OUT/name, 'w', zipfile.ZIP_DEFLATED) as z:
        for n,d in sorted(contents.items()):
            entry = zipfile.ZipInfo(n, (2026,9,22,0,0,0))
            entry.compress_type = zipfile.ZIP_DEFLATED
            entry.external_attr = 0o100644 << 16
            z.writestr(entry,d)
    with zipfile.ZipFile(OUT/name) as z:
        assert z.testzip() is None
        assert len(z.namelist()) == len(contents)
        for n,d in contents.items(): assert z.read(n) == d

copies = {'SmallPicker.stl':'PongFetch_Rev3_Frame.stl',
          'Collet.stl':'PongFetch_Rev3_Collet.stl','ColletCap.stl':'PongFetch_Rev3_Cap.stl',
          'prints/PongFetch_Rev3_Frame.3mf':'PongFetch_Rev3_Frame.3mf',
          'prints/PongFetch_Rev3_Handle_Parts.3mf':'PongFetch_Rev3_Handle_Parts.3mf'}
for src,name in copies.items(): shutil.copy2(ROOT/src, OUT/name)
notes = '# PongFetch rev 3.0 + Accessories\n\nCC BY-NC-SA 4.0. Re-slice every project for the actual printer and materials.\n\n'
notes += '\n\n'.join((ROOT/p).read_text() for p in ['prints/PRINTING.md','docs/ASSEMBLY.md','Accessories/README.md'])
(OUT/'PongFetch_Print_Notes.txt').write_text(notes)
source_readme = '''# PongFetch rev 3.0 + Accessories — editable design

Core source: SmallPicker.scad, SideLatch.scad, ColletSocket.scad and Branding.scad. Keep these four files together.

Accessory source: Accessories/EndCap/source/EndCap.scad (standalone) and Accessories/Hanger/source/Hanger.scad (requires BOSL2).

Install OpenSCAD and BOSL2 separately. For frame lettering, install a licensed Arial Bold font or adjust brand_font and check the result. The end cap's paddle mark is geometric and needs no font. Use part="body" and part="inlay" in EndCap for the two colour parts, preserving their coordinates. Hanger exports body/nut in print orientation.

CC BY-NC-SA 4.0 applies to original design documents. See LICENSE.md and the official legal text. Third-party libraries/software are not bundled or relicensed. Python utilities are not included in this source-design ZIP.

The core v3.0 tag is unchanged. PACKAGE_INFO.json identifies the source commit for this supplement. Ready-to-slice 3MFs and assembly instructions are in the Maker Bundle or standalone Accessories download.
'''
package('PongFetch_Rev3_Design_Source.zip', DESIGN+LICENSE+[n for n in ACCESSORIES if n.endswith('.scad')], {'README.md':source_readme})
extras = ['prints/PRINTING.md','docs/ASSEMBLY.md','docs/VALIDATION.md','verification/release.json']
extras += sorted(str(p.relative_to(ROOT)) for p in (ROOT/'previews').glob('*.png'))
package('PongFetch_Rev3_Maker_Bundle.zip', ['README.md']+DESIGN+LICENSE+CORE+extras+ACCESSORIES, {'PRINT_NOTES.txt':notes})
package('PongFetch_Accessories.zip', LICENSE+ACCESSORIES)
names = sorted(list(copies.values())+['PongFetch_Print_Notes.txt','PongFetch_Rev3_Design_Source.zip',
               'PongFetch_Rev3_Maker_Bundle.zip','PongFetch_Accessories.zip'])
manifest = {n:{'bytes':(OUT/n).stat().st_size,'sha256':hashlib.sha256((OUT/n).read_bytes()).hexdigest()} for n in names}
(OUT/'SHA256SUMS.txt').write_text(''.join(f'{v["sha256"]}  {n}\n' for n,v in manifest.items()))
print(json.dumps(manifest, indent=2))
