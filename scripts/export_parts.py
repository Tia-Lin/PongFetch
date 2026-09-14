"""Export the current three printable parts, remove opposite face pairs, and verify topology.

Example: python3 scripts/export_parts.py --parts cap collet
The whole frame can take several minutes with OpenSCAD 2021.01.
Requires the same BOSL2 library as SmallPicker.scad.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
from clean_stl import clean
from stl_mesh import read_stl, mesh_data, qa

FILES={'frame':'SmallPicker.stl','cap':'ColletCap.stl',
       'collet':'Collet.stl'}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--parts',nargs='+',choices=FILES,default=list(FILES))
    p.add_argument('--openscad',default=shutil.which('openscad') or 'openscad')
    a=p.parse_args()
    root=Path(__file__).resolve().parent.parent
    reports=[]
    with tempfile.TemporaryDirectory(prefix='picker-collet-') as tmp:
        for part in a.parts:
            raw=Path(tmp)/(part+'.stl')
            result=subprocess.run([a.openscad,'-o',str(raw),'--export-format','binstl',
                                   '-D',f'part="{part}"',str(root/'SmallPicker.scad')],
                                  capture_output=True,text=True)
            # Some older CGAL failures return exit code 0, so check the log too.
            print(result.stdout+result.stderr,flush=True)
            if result.returncode or 'ERROR:' in result.stderr or not raw.exists():
                raise RuntimeError(f'OpenSCAD failed to export {part}')
            reports.append(clean(raw,root/FILES[part]))
    # Partial exports must retain verification of the other deliverable meshes.
    qa_path=root/'verification'/'mesh-qa.json'
    qa_path.parent.mkdir(parents=True,exist_ok=True)
    previous=json.loads(qa_path.read_text()).get('meshes',[]) if qa_path.exists() else []
    known={r['file']:r for r in previous+reports}
    complete=[]
    for name in FILES.values():
        path=root/name
        if not path.exists():
            continue
        report=qa(path,*mesh_data(read_stl(path)))
        report['removed_opposite_triangles']=known.get(name,{}).get('removed_opposite_triangles',0)
        report['sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
        assert all(report[k]==0 for k in ['boundary_edges','nonmanifold_edges',
            'inconsistent_winding_edges','duplicate_triangles','degenerate_index_triangles']), report
        assert report['connected_components']==(9 if name=='SmallPicker.stl' else 1), report
        complete.append(report)
    qa_path.write_text(json.dumps({'meshes':complete},indent=2)+'\n')
    print(json.dumps(complete,indent=2))

if __name__=='__main__':
    main()
