# Rev 3.0 validation scope

The frame, skirted collet and cap have been physically printed and reported stable and usable by the designer. This is practical prototype feedback, not a fatigue-life or impact certification.

## Release checks

Run from the repository root with Python 3:

```sh
python3 scripts/verify_release.py
```

The release verifier checks the three STL meshes for open/nonmanifold edges, inconsistent winding, duplicate triangles and degenerate-index triangles. It expects nine disconnected components in the frame mesh (frame plus eight moving flaps) and one each for cap and collet. These checks do not detect every possible self-intersection or establish mechanical strength.

It also verifies each 3MF's ZIP integrity, XML/JSON readability, absence of machine-ready G-code, eight frame modifiers, two frame-colour parts and two handle components. Saved machine and material assignments are recorded in `verification/release.json`. Website validation and download packaging are maintained in the separate website repository.

`verification/mesh-qa.json` records the exported STL geometry; `verification/partition-check.json` records the earlier text partition check. The digital partition recombined to the original envelope within numerical precision, with no text outside that envelope. The text is 0.60 mm deep.

## Earlier checks and their limits

The original Rev 3.0 lettering was checked for assembled orientation and all 36 glyph islands had coloured toolpaths in the first three 0.20 mm layers during an earlier native Bambu Studio 02.08.03.66 slice. The current projects subsequently received user-saved machine/material settings. That earlier slice is not certification of the current saved profile combination.

The latest projects remain unsliced. Re-slice them for your actual machine and inspect the bed layout, first-layer contact, moving clearances, bridges and colour assignments. Coloured surface finish, mixed-material bonding and long-term durability require physical validation.
