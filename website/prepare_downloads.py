"""Build versioned, licensed downloads from current local Rev 3.0 files."""
from pathlib import Path
import hashlib, json, shutil, zipfile
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'website/dist/downloads'
OUT.mkdir(parents=True, exist_ok=True)
def add_file(archive, path, name):
 info = zipfile.ZipInfo(name, (2026, 9, 14, 0, 0, 0))
 info.compress_type = zipfile.ZIP_DEFLATED
 info.external_attr = 0o100644 << 16
 archive.writestr(info, path.read_bytes())

def add_text(archive, name, text):
 info = zipfile.ZipInfo(name, (2026, 9, 14, 0, 0, 0))
 info.compress_type = zipfile.ZIP_DEFLATED
 info.external_attr = 0o100644 << 16
 archive.writestr(info, text)
copies = {
 'prints/PongFetch_Rev3_Frame.3mf': 'PongFetch_Rev3_Frame.3mf',
 'prints/PongFetch_Rev3_Handle_Parts.3mf': 'PongFetch_Rev3_Handle_Parts.3mf',
 'SmallPicker.stl': 'PongFetch_Rev3_Frame.stl',
 'ColletCap.stl': 'PongFetch_Rev3_Cap.stl',
 'Collet.stl': 'PongFetch_Rev3_Collet.stl',
 'LICENSE.md': 'PongFetch_License_Notice.md',
 'CC-BY-NC-SA-4.0.txt': 'CC-BY-NC-SA-4.0.txt',
 'THIRD_PARTY_NOTICES.md': 'THIRD_PARTY_NOTICES.md',
}
for source, name in copies.items():
 shutil.copy2(ROOT/source, OUT/name)
notes = 'PongFetch rev 3.0 — CC BY-NC-SA 4.0\nPersonal and noncommercial use. Credit PongFetch and identify changes when sharing; shared adaptations follow ShareAlike. Editable source sharing is encouraged, not mandatory.\nFull scope: PongFetch_License_Notice.md\nOfficial terms: https://creativecommons.org/licenses/by-nc-sa/4.0/\n\n'
notes += (ROOT/'prints/PRINTING.md').read_text()+'\n\n'+(ROOT/'docs/ASSEMBLY.md').read_text()
(OUT/'PongFetch_Print_Notes.txt').write_text(notes)
design = ['SmallPicker.scad','SideLatch.scad','ColletSocket.scad','Branding.scad']
license_files = ['LICENSE.md','CC-BY-NC-SA-4.0.txt','THIRD_PARTY_NOTICES.md']
source_readme = '''# PongFetch rev 3.0 — editable design

Personal and noncommercial use under CC BY-NC-SA 4.0. Read LICENSE.md and the included official legal text. Credit PongFetch and identify your changes when sharing; publicly shared adaptations follow ShareAlike. Sharing editable source is encouraged, not an additional requirement.

## Start editing

Install OpenSCAD and BOSL2 separately. For text, install a properly licensed Arial Bold font or adjust brand_font in Branding.scad and recheck the text fit. Third-party tools and fonts are not included or relicensed.

- SmallPicker.scad: main product entry, frame and assembly.
- SideLatch.scad: integrated folding latches and first-layer ties.
- ColletSocket.scad: socket, collet and cap.
- Branding.scad: four text labels, orientation and inlay depth.

Keep the four SCAD files in the same folder. Open SmallPicker.scad in OpenSCAD. Use part="frame_base" and part="frame_text" to export the two frame-colour meshes, then import them as parts of one object in your slicer, preserving their shared coordinates. Plain STL carries no colour assignments. Recheck geometry and slicing after modifications.

This ZIP contains editable design documents, not the website app, Python utilities, installed libraries or printer software. Current ready-to-slice 3MF projects are available separately or in the maker bundle.

The current model retains a historical "open source" label; it does not override the noncommercial license. Publication preserves the existing model geometry and lettering.

Project: https://github.com/Tia-Lin/PongFetch
'''
with zipfile.ZipFile(OUT/'PongFetch_Rev3_Design_Source.zip','w',zipfile.ZIP_DEFLATED) as archive:
 add_text(archive, 'README.md', source_readme)
 for name in [*design,*license_files]: add_file(archive, ROOT/name,name)
with zipfile.ZipFile(OUT/'PongFetch_Rev3_Maker_Bundle.zip','w',zipfile.ZIP_DEFLATED) as archive:
 add_text(archive, 'README.md', source_readme+'\n## Included print files\nThis maker bundle also includes the two current 3MF projects, all three single-colour STL parts, printing and assembly notes, and product previews. Use the frame 3MF for flush two-colour lettering. Re-slice for your machine.\n')
 add_text(archive, 'PRINT_NOTES.txt', notes)
 for name in [*design,*license_files,'SmallPicker.stl','ColletCap.stl','Collet.stl','prints/PongFetch_Rev3_Frame.3mf','prints/PongFetch_Rev3_Handle_Parts.3mf','prints/PRINTING.md','docs/ASSEMBLY.md','docs/VALIDATION.md','previews/rev3-assembly.png','previews/rev3-front.png','previews/rev3-rear.png']:
  add_file(archive, ROOT/name,name)
names = [*copies.values(),'PongFetch_Print_Notes.txt','PongFetch_Rev3_Design_Source.zip','PongFetch_Rev3_Maker_Bundle.zip']
manifest = {name:{'bytes':(OUT/name).stat().st_size,'sha256':hashlib.sha256((OUT/name).read_bytes()).hexdigest()} for name in sorted(names)}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(f'Prepared {len(names)} current licensed downloads; original model files are unchanged.')
