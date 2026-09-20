# A2 — same-height decorative cap, stronger trial fits

The user reported that D works very well and A1 is loose. D is unchanged. This A2 trial addresses **radial preload first**, without increasing the cap's height, wall thickness, insertion depth or number of ribs. These are fit trials, not yet physically validated.

## What changed

For nominal Ø21.34 mm PVC, the original A1 rib contact diameter was 21.24 mm: only 0.05 mm nominal radial interference. Small differences in the actual pipe, printed rib location or slicing can consume this allowance. This is a plausible explanation for the reported loose fit; the actual pipe and printed cap have not been measured.

| Version | Rib contact diameter | Nominal radial interference | Change from A1 |
|---|---:|---:|---:|
| A1, previously printed | 21.24 mm | 0.05 mm | — |
| A2 medium — try first | 21.04 mm | 0.15 mm | Each rib projects 0.10 mm farther inward |
| A2 firm — comparison | 20.94 mm | 0.20 mm | Each rib projects 0.15 mm farther inward |

All versions retain three rounded longitudinal ribs, an entrance ramp, **24.14 mm OD, 9.20 mm overall height, 8.00 mm insertion, 1.20 mm wall and 1.20 mm roof**. A fully seated cap extends only 1.2 mm beyond the pipe end. The full cylindrical bore remains Ø21.74 mm. Interference figures describe ideal CAD, not measured printed compression or a predicted gripping force.

Longer insertion may help retention if sufficient contact pressure exists, but it does not resolve a loose radial fit by itself. A longer external skirt also increases the area the hand can rub or catch. A2 therefore isolates the fit change. Three ribs retain room for the thin shell to flex between contact points; adding ribs or thickening the wall is deferred until these trials show it is needed.

## Print and compare

Open `A2_Fit_Comparison_X2D_PETG_Basic.3mf`. It contains **two complete, plain caps**, named medium and firm. Both are closed-face-down, open-side-up. They are full caps rather than short rings because the closed roof and full contact length affect retention. Mark M/F with a pen as you remove each identified object from the plate; their outer shapes are identical.

Saved settings: X2D, 0.4 mm nozzle, textured PEI, Bambu PETG Basic, 0.20 mm first layer and layer height, four requested walls, 20% gyroid, no support, no brim. The two-cap native slice estimates **2.84 g and 18 minutes**; actual machine start-up and material use can differ. The thin wall only contains the wall lines that fit. Confirm actual filament/nozzle mapping and re-slice before printing; the project does not contain G-code.

1. Try **medium first**, seating it fully with ordinary hand pressure. Stop if it needs force or the rim visibly spreads/whitens. Do not force firm onto a pipe that medium already holds securely.
2. Compare resistance to a straight pull, twisting and the same sideways hand contact experienced during picking. Choose the least tight version that resists accidental removal.
3. Recheck after repeated removal and after a day seated on the pipe. Immediate fit alone does not establish long-term retention. If it loosens over time or still peels off sideways despite a snug fit, revisit shell compliance/edge shape rather than indefinitely shrinking the bore.
4. If both are loose, measure the actual PVC OD and printed rib-tip spacing before further adjustment.

These caps are decorative and are not hanging attachments. The existing flush logo remains in the editable source (`part="body"` and `part="inlay"`); the comparison pieces omit colour changes to reduce trial cost. Once the fit is chosen, export the matching logo body with the same `fit` setting. The inlay is shared between fits.

## Source and checks

`source/EndCapA.scad` is standalone OpenSCAD; set `fit="medium"` or `"firm"`. `pipe_od` defaults to 21.34 mm. Do not use a nominal plumbing size as the actual OD.

Mesh and native slicing results are recorded in `verification/`. Digital checks establish closed geometry and generated support-free toolpaths; the trial fit still requires printing and testing.

## 中文

这次不加深，也不增厚，只把原来的三条圆筋向内增加一点。先试 medium（每条向内增加 0.10 mm），如果仍松再试 firm（增加 0.15 mm）。两个都是完整帽，外形和高度与之前一致，打印后根据切片对象名称标上 M/F，避免混淆。

比较直接拔、扭动和捡球时手碰边缘的表现，再检查装上一天后的松紧。选择能防止意外脱落的较松一档；无需追求越紧越好。此次用单色完整帽验证配合，确定尺寸后再生成相应双色图案版本。D 保持原样。

Original design: PongFetch / Tia-Lin, **CC BY-NC-SA 4.0**. The repository's `CC-BY-NC-SA-4.0.txt` contains the official license text; the download bundle includes a copy. Bambu Studio profile content retains its own terms.
