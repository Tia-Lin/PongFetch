# PongFetch D — removable hanging eye

The user reports that D works very well. Its geometry and native printing project are unchanged. Older loose A end caps have been retired; the current [A3 reduced-ID trials](../end-cap-a3/README.md) starts at the user-tested Firm fit. Historical files remain available in Git history.

## D — removable hanging eye with integral clamp

Two parts: `D_body.stl` integrates the eye, male thread and six flexible fingers; `D_nut.stl` provides the female thread and compression cone. The render uses two colours to identify the parts; the supplied D project prints both in one colour.

| Feature | Dimension |
|---|---:|
| Unclamped bore | 21.74 mm (0.40 mm diametral clearance) |
| Straight finger wall / slots | 1.73 / 1.20 mm |
| Rounded slot-root relief | Ø2.40 mm |
| Compression cone | 15° to the axis |
| Male thread major diameter / pitch | 30.0 / 3.0 mm |
| Thread depth / diametral clearance | 1.0 / 0.60 mm |
| Body maximum diameter / height | 35.40 / 67.20 mm |
| Nut maximum diameter / height | 35.00 / 30.80 mm |
| Eye plate thickness / outer width | 6.40 / 34.00 mm |
| Eye aperture maximum width | 18.00 mm, pointed roof |
| Projection above nominal seated pipe end | About 39.5 mm |

The ring advances toward the eye when tightened. Its cone presses the fingers inward against the pipe. Loads pass from the hanging eye through the broad shoulder and integral body to friction at the pipe. Rounded slot roots and a gradual transition into the threaded section reduce abrupt section changes. The eye has a pointed, 45° roof to avoid a broad horizontal bridge. The pipe socket also has a 45° internal roof rather than a flat bridging ceiling.

The widened finger tips are about Ø27.99 mm and can pass through the female thread's nominal Ø28.60 mm minimum opening. This clearance was checked explicitly. The thread entry stays clear throughout the designed stroke.

`travel=0` in the source is an assembly reference position, **not the start of thread engagement**. From that position, cone contact begins at roughly 0.67 mm advance, and matching shoulder cones meet at approximately 2.0 mm. That leaves nominal room to take up the 0.20 mm radial pipe clearance and apply some preload. Actual force depends on the printed fingers and pipe. The shoulder is a travel stop, **not a torque limiter**; stop tightening once the pipe is held firmly, even if the shoulder has not seated.

### Assembly and trial

1. Slide the nut onto the free pipe end, with its large threaded opening toward that end.
2. Slip the body onto the pipe until seated against the internal roof.
3. Bring the nut up to the male thread, engage gently and hand-tighten toward the eye. Check that the body cannot readily rotate or pull off. Do not use pliers to force the shoulder closed.
4. To remove, loosen the nut until the fingers relax, then lift off the body.

First check thread engagement without the pipe, then check fit on the actual pipe. Mark the pipe at the body edge and test the empty picker close to a padded surface. Recheck for slip, rotation or cracks after repeated removal and a 24-hour hanging trial with the intended storage load. Do not treat this prototype as load-rated: PETG creep, layer adhesion and friction have not been physically measured. If the shoulder closes while the pipe still slips, revise the fit rather than applying more torque.

### Printing D

Use `D_Prototype_X2D_PETG_Basic.3mf`, or import the two STLs in their supplied orientations. Body: six finger tips on the bed, eye upright. Nut: smaller end down. The project adds a **2 mm external brim only to the body**, with 0.15 mm separation, to help its six separate starting feet; this is slicer-generated, not permanent breakaway ears in the CAD.

The D project uses X2D, 0.4 mm nozzle, textured PEI, Bambu PETG Basic, **0.20 mm first layer and subsequent layers, 4 walls, 20% gyroid, support disabled**. The D two-part slice estimates **1 h 45 min and 23.30 g**, including the saved brim/toolpath settings.

The upright body orientation prioritizes printable threads and fingers. It leaves layer interfaces across the hanging load direction; the wide eye and shoulder help distribute load, but do not eliminate that weakness. Do not assume slicing success proves long-term strength.

## Verification and source

`source/HangerD.scad` requires separately installed BOSL2 (BSD-2-Clause). Select `part="body"` or `"nut"` for print exports, or `"assembly"`, `"exploded"`, `"section"` for inspection. The actual STL meshes, thread-clearance scan, native slicing settings and layer toolpaths are documented in `verification/`. The user has reported successful use; this is not a quantified long-term load test.

Original design: PongFetch / Tia-Lin, **CC BY-NC-SA 4.0**. Official legal text is included in `CC-BY-NC-SA-4.0.txt`. BOSL2 and Bambu Studio/profile content retain their own terms. The tested rev3.0 picker is unchanged.
