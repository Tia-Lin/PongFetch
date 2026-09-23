"""Verify the current deliverable meshes/projects; write a portable release report."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET
import zipfile
from stl_mesh import read_stl, mesh_data, qa

ROOT = Path(__file__).resolve().parent.parent

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    report = {'revision': '3.0', 'tag': 'v3.0', 'repository': 'https://github.com/Tia-Lin/PongFetch',
              'supplement': 'Accessories 2026-09-22', 'checks': [], 'projects': [], 'sha256': {}}
    for name, components in [('SmallPicker.stl', 9), ('Collet.stl', 1), ('ColletCap.stl', 1),
            ('Accessories/EndCap/EndCap_plain.stl', 1), ('Accessories/EndCap/EndCap_body.stl', 1),
            ('Accessories/EndCap/EndCap_logo.stl', 2), ('Accessories/Hanger/Hanger_body.stl', 1),
            ('Accessories/Hanger/Hanger_nut.stl', 1)]:
        p = ROOT / name
        result = qa(p, *mesh_data(read_stl(p)))
        for key in ['boundary_edges', 'nonmanifold_edges', 'inconsistent_winding_edges',
                    'duplicate_triangles', 'degenerate_index_triangles']:
            assert result[key] == 0, (name, key, result[key])
        assert result['connected_components'] == components, result
        report['checks'].append({'file': name, 'mesh_topology': 'pass',
                                 'triangles': result['triangles'], 'components': components})
        print(f'PASS {name}: {components} components; {result["triangles"]} triangles')
    for name in ['prints/PongFetch_Rev3_Frame.3mf', 'prints/PongFetch_Rev3_Handle_Parts.3mf',
                 'Accessories/EndCap/PongFetch_EndCap_Logo_X2D_PETG_Basic.3mf',
                 'Accessories/Hanger/PongFetch_Hanger_X2D_PETG_Basic.3mf']:
        p = ROOT / name
        with zipfile.ZipFile(p) as z:
            assert z.testzip() is None, name
            assert not any(n.lower().endswith(('.gcode', '.bgcode')) for n in z.namelist()), name
            for n in z.namelist():
                if n.endswith(('.model', '.xml', '.rels')) or n == '[Content_Types].xml':
                    ET.fromstring(z.read(n))
            settings = json.loads(z.read('Metadata/project_settings.config'))
            config = ET.fromstring(z.read('Metadata/model_settings.config'))
            normal = config.findall('./object/part[@subtype="normal_part"]')
            modifiers = config.findall('./object/part[@subtype="modifier_part"]')
            assert len(normal) == 2, (name, 'normal parts', len(normal))
            assert len(modifiers) == (8 if 'Frame' in name else 0), (name, len(modifiers))
            assignments = []
            for obj in config.findall('object'):
                meta = {m.get('key'): m.get('value') for m in obj.findall('metadata') if m.get('key')}
                for part in obj.findall('part[@subtype="normal_part"]'):
                    pm = {m.get('key'): m.get('value') for m in part.findall('metadata') if m.get('key')}
                    slot = int(pm.get('extruder', meta.get('extruder', '1')))
                    assignments.append({'name': pm.get('name'), 'slot': slot,
                        'profile': settings['filament_settings_id'][slot-1],
                        'colour': settings['filament_colour'][slot-1]})
            report['projects'].append({'file': name, 'archive_integrity': 'pass',
                'normal_parts': len(normal), 'modifiers': len(modifiers),
                'settings': {k: settings.get(k) for k in ['printer_model', 'printer_settings_id',
                    'wall_loops', 'layer_height', 'initial_layer_print_height',
                    'sparse_infill_density', 'sparse_infill_pattern']},
                'material_assignments': assignments})
            print(f'PASS {name}: archive, XML, {len(normal)} normal parts, {len(modifiers)} modifiers')
    for name in ['SmallPicker.scad', 'SideLatch.scad', 'ColletSocket.scad', 'Branding.scad',
                 'SmallPicker.stl', 'Collet.stl', 'ColletCap.stl',
                 'prints/PongFetch_Rev3_Frame.3mf', 'prints/PongFetch_Rev3_Handle_Parts.3mf',
                 'LICENSE.md', 'CC-BY-NC-SA-4.0.txt']:
        report['sha256'][name] = digest(ROOT / name)
    for p in sorted((ROOT / 'Accessories').rglob('*')):
        if p.is_file(): report['sha256'][str(p.relative_to(ROOT))] = digest(p)
    report['scope'] = 'Topology and archive checks; no new native slice, physical print, self-intersection or lifetime certification.'
    (ROOT / 'verification').mkdir(exist_ok=True)
    (ROOT / 'verification/release.json').write_text(json.dumps(report, indent=2)+'\n')

if __name__ == '__main__':
    main()
