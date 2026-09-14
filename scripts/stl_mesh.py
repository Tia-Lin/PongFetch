"""Binary/ASCII STL inspection, without third-party Python packages."""
import collections
import struct
def read_stl(path):
    data = path.read_bytes()
    count = struct.unpack_from("<I", data, 80)[0] if len(data) >= 84 else 0
    tris = []
    if len(data) == 84 + 50 * count:
        for i in range(count):
            row = struct.unpack_from("<12fH", data, 84 + i * 50)
            tris.append([row[3:6], row[6:9], row[9:12]])
    else:
        verts = []
        for line in data.decode("ascii").splitlines():
            t = line.split()
            if t and t[0] == "vertex":
                verts.append(tuple(map(float, t[1:4])))
        if len(verts) % 3:
            raise ValueError(f"Incomplete ASCII STL triangles: {path}")
        tris = [verts[i:i+3] for i in range(0, len(verts), 3)]
    return tris


def mesh_data(tris):
    vertices, faces, seen = [], [], {}
    for tri in tris:
        face = []
        for coord in tri:
            key = tuple(coord)
            if key not in seen:
                seen[key] = len(vertices)
                vertices.append(tuple(coord))
            face.append(seen[key])
        faces.append(face)
    return vertices, faces


def qa(path, vertices, faces):
    if not vertices:
        return {"file": str(path), "error": "empty mesh"}
    edges = collections.Counter()
    directed_balance = collections.Counter()
    triangle_keys = collections.Counter(tuple(sorted(face)) for face in faces)
    adjacency = [[] for _ in vertices]
    degenerate = 0
    signed_volume = 0.0
    for face in faces:
        if len(set(face)) < 3:
            degenerate += 1
        for a, b in zip(face, face[1:] + face[:1]):
            edges[tuple(sorted([a, b]))] += 1
            directed_balance[tuple(sorted([a, b]))] += 1 if a < b else -1
            adjacency[a].append(b)
            adjacency[b].append(a)
        a, b, c = [vertices[i] for i in face]
        signed_volume += (a[0]*(b[1]*c[2]-b[2]*c[1])
                          + a[1]*(b[2]*c[0]-b[0]*c[2])
                          + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
    unvisited = set(range(len(vertices)))
    components = []
    while unvisited:
        start = unvisited.pop()
        stack, size = [start], 1
        while stack:
            for neighbor in adjacency[stack.pop()]:
                if neighbor in unvisited:
                    unvisited.remove(neighbor)
                    stack.append(neighbor)
                    size += 1
        components.append(size)
    minimum = [min(v[i] for v in vertices) for i in range(3)]
    maximum = [max(v[i] for v in vertices) for i in range(3)]
    return {
        "file": path.name, "triangles": len(faces), "welded_vertices": len(vertices),
        "bounds_min_mm": minimum, "bounds_max_mm": maximum,
        "dimensions_mm": [maximum[i] - minimum[i] for i in range(3)],
        "boundary_edges": sum(v == 1 for v in edges.values()),
        "nonmanifold_edges": sum(v > 2 for v in edges.values()),
        "inconsistent_winding_edges": sum(edges[k] == 2 and value != 0 for k, value in directed_balance.items()),
        "duplicate_triangles": sum(count - 1 for count in triangle_keys.values() if count > 1),
        "degenerate_index_triangles": degenerate,
        "connected_components": len(components),
        "component_vertex_counts": sorted(components, reverse=True),
        "signed_volume_mm3": signed_volume,
        "method": "Exactly equal exported coordinates welded; triangle edge incidence; no self-intersection test",
    }
