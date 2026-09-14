"""Remove pairs of exactly coincident, oppositely wound STL triangles.

V2.1 already contains eight such zero-thickness face pairs at fin tips.
Coordinates and all other triangles are preserved exactly; this is not
an approximate weld, remesh, or general-purpose mesh repair.
"""
import argparse
from collections import defaultdict
import json
from pathlib import Path
import struct
from stl_mesh import read_stl, mesh_data, qa

def clean(source, destination):
    triangles=read_stl(source)
    groups=defaultdict(list)
    for i,t in enumerate(triangles):
        groups[tuple(sorted(map(tuple,t)))].append(i)
    removed=set()
    for indices in groups.values():
        if len(indices)==1:
            continue
        assert len(indices)==2, 'Unexpected coincident face group'
        a,b=[list(map(tuple,triangles[i])) for i in indices]
        reverse=a[::-1]
        assert any(b==reverse[j:]+reverse[:j] for j in range(3)), 'Same-winding duplicate requires inspection'
        removed.update(indices)
    kept=[t for i,t in enumerate(triangles) if i not in removed]
    with destination.open('wb') as f:
        f.write(b'OpenSCAD; exactly coincident opposite face pairs removed'.ljust(80,b' '))
        f.write(struct.pack('<I',len(kept)))
        for tri in kept:
            f.write(struct.pack('<12fH',0,0,0,*(c for v in tri for c in v),0))
    vertices,faces=mesh_data(read_stl(destination))
    report=qa(destination,vertices,faces)
    report['removed_opposite_triangles']=len(removed)
    assert report['boundary_edges']==0 and report['nonmanifold_edges']==0, report
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('source',type=Path)
    p.add_argument('destination',type=Path)
    a=p.parse_args()
    print(json.dumps(clean(a.source,a.destination),indent=2))
