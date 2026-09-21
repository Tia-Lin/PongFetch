# A3 — smaller bore and OD, constant 1.20 mm wall

The user found A2 Medium too loose and Firm acceptable, then proposed reducing the **cylindrical inside diameter** rather than making the gripping ribs taller. A3 follows that proposal. The earlier proposed Extra Firm/Max Firm rib-height trials are withdrawn and are not part of this delivery. D is unchanged.

| Variant | Cylindrical ID | OD | Wall thickness | Rib projection from cylindrical wall |
|---|---:|---:|---:|---:|
| **Firm reference**, previously tested | 21.74 mm | 24.14 mm | 1.20 mm | 0.40 mm |
| **ID 21.54**, try first | 21.54 mm | 23.94 mm | 1.20 mm | 0.30 mm |
| **ID 21.44**, closer fit | 21.44 mm | 23.84 mm | 1.20 mm | 0.25 mm |

**All three keep the same 20.94 mm rib-tip contact diameter**, equivalent to 0.20 mm nominal radial interference at the three ribs. The pipe's nominal OD is 21.34 mm. These are ideal CAD dimensions, not measured printed gaps or insertion forces.

The cylindrical wall is **1.20 mm in every variant**, with OD calculated as ID + 2 × wall. This supersedes the earlier fixed-OD A3 files. Overall height remains 9.20 mm, insertion depth 8.00 mm, and roof thickness 1.20 mm. A fully seated cap projects 1.2 mm beyond the pipe end. The three rounded ribs and entrance ramps remain. Reducing both ID and OD makes the cap slightly narrower without thickening the cylindrical wall or moving the rib tips inward. The intentional mouth and base chamfers are unchanged; the 1.20 mm value refers to the straight cylindrical wall.

The working hypothesis is that the closer surrounding wall provides better support against sideways rocking and may improve retention; keeping wall thickness constant avoids adding a thicker wall as a separate change. This is not equivalent to simply specifying more rib interference. Actual insertion and removal forces still need comparison on the user's PVC. The closer ID 21.44 trial has little nominal clearance, so printed size error may make it tighter than expected. Firm remains the known usable reference.

## Print and compare

`A3_Reduced_ID_X2D_PETG_Basic.3mf` contains only the two **new** complete plain caps: `A3_ID21_54` and `A3_ID21_44`. Both are closed-face-down and opening-up. There is no need to reprint Firm; `A3_firm.stl` is supplied separately and is byte-for-byte identical to the previously tested A2 Firm STL.

The two new caps together slice to approximately **2.79 g and 18 minutes** with the saved profile; actual machine start-up and material use may differ.

Mark the two new caps **54** and **44** as you remove the identified objects from the plate; their outside diameters differ by only 0.10 mm. Try ID 21.54 first, comparing it with existing Firm. Try ID 21.44 only if a closer fit is useful. Compare hand installation, straight pull-off, twist and the sideways hand contact experienced during picking. Stop if installation requires excessive force or the rim visibly spreads/whitens. Prefer the least tight variant that remains secure during use.

Recheck after repeated installation/removal and after a day seated on the pipe. A snug initial fit does not demonstrate long-term retention. These are decorative caps, not hanging attachments.

Saved settings: X2D, 0.4 mm nozzle, textured PEI, Bambu PETG Basic, 0.20 mm first layer and layer height, four requested walls, 20% gyroid, no supports or brim. Thin walls contain only the wall lines that fit. Confirm actual filament/nozzle mapping and re-slice; the delivered project has no executable G-code.

The fit trials are single-colour to reduce waste. The flush paddle-and-ball design remains in the source: export `part="body"` and `part="inlay"` for the selected fit, import them together with coordinates preserved, and assign colours.

## Source and checks

`source/EndCapA.scad` is standalone OpenSCAD. Select `fit="firm"`, `"id_21_54"` or `"id_21_44"`; Firm is the default. These ID labels assume the default `pipe_od=21.34`. The OD parameter represents actual pipe OD, not nominal plumbing size.

`verification/` records closed mesh topology, updated outer diameters with equal straight-wall thickness, exact preservation of the tested Firm STL, unchanged rib-tip locations and support-free native slicing. No stress/deformation simulation or measured retention force is claimed. Old A/Medium delivery files have been retired; earlier committed files remain in Git history.

## 中文

这一轮改为缩小圆筒内径，保持 Firm 已验证的 20.94 mm 凸筋尖端接触直径不变。两档内径分别为 21.54、21.44 mm，外径同步改为 23.94、23.84 mm；两档直筒壁厚都保持 1.20 mm，凸筋相对内壁更矮。高度、套入深度和凸筋尖端位置不变。此版本替换之前外径固定、壁厚不同的 A3 文件。

先试 21.54 mm，与手头 Firm 比较，再按需试 21.44 mm。打印盘只含这两个新版本，取下时按对象名标记 54/44。内径更小是否确实改善保持力，仍需实际安装、侧碰和放置后的比较；不是越紧越好。D 保持原样。

Original design: PongFetch / Tia-Lin, **CC BY-NC-SA 4.0**. Official legal text is included in the download bundle and repository root. Bambu Studio/profile content retains its own terms.
