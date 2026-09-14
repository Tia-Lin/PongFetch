# Rev 3.0 printing / 打印与清理

Use [the frame project](PongFetch_Rev3_Frame.3mf) and [the handle-parts project](PongFetch_Rev3_Handle_Parts.3mf). Both are editable, unsliced 3MF projects. Select your actual printer, plate, nozzle and material, then re-slice. Preserve the part orientations and the frame's eight local bridge modifiers.

## Saved settings in this release

These are the latest saved project settings, not a claim that both plates were printed on the same machine.

| Setting | Frame | Collet + cap |
| --- | --- | --- |
| Saved machine | Bambu Lab H2D, 0.4 mm nozzle | Bambu Lab X1 Carbon, 0.4 mm nozzle |
| Walls | 4 | 4 |
| Layer / first-layer height | 0.20 / 0.20 mm | 0.20 / 0.20 mm |
| Infill | 15%, grid | 15%, grid |
| Assigned material | Body: slot 4, PETG Basic, yellow; text: slot 2, PETG-CF, green | Slot 1, PETG Basic |
| Supports | Disabled | Disabled |

The frame also retains unused material slots 1, 3 and 5. These are not extra materials you must load. Map the body and text to your actual filaments; the saved PETG-CF text profile is not a requirement or a separately validated material pairing. The mechanical baseline used PETG. Changing material or machine profiles requires another slice review. Do not infer a profile from the preview colour.

## Frame

The frame and lettering are two normal parts of one object. Do not separate or independently reposition them. Text is flush with the print-bed face and 0.60 mm deep; at the saved layer height it occupies the first three layers. Use the 3MF for colour; the single-colour STL has the full solid envelope and no visible inlaid text.

The open frame footprint is approximately **242.9 × 217.4 mm**, before any purge tower or brim. Check the complete layout on your selected printer. The three fins have a 1.2 mm flat base at the bed. Inspect the first-layer preview, small springs and bridge directions before printing.

Let the plate cool. From the print-bed side, release the **three internal ties at each of the eight latches** individually. Each tie is 0.50 mm wide and 0.20 mm thick. Check that the spring moves freely and returns before closing the flap. There are no external adhesion ears to remove. Changing first-layer height can change how these ties slice.

## Collet and cap

Print one of each. Keep the collet **six fingers down, locating skirt up**. Its saved 3 mm outer brim and 0.15 mm brim gap are retained. Keep the cap in its saved orientation. Remove the collet brim carefully, then check the slots and mating surfaces before assembly.

## Validation

The mechanical baseline has physical print feedback. Earlier Rev 3.0 digital checks confirmed the colour partition, assembled text direction and text paths in a native Bambu Studio slice. The subsequently saved printer/material settings are preserved here; those earlier logs do not certify this exact profile combination. The release checks archive integrity, mesh topology and current settings, not a new physical print. See [validation details](../docs/VALIDATION.md).

## 中文要点

- 两张 3MF 都需要按自己的机器、喷嘴、打印板及实际装料重新切片。框身保存 H2D 配置，小件保存 X1 Carbon 配置；均为 4 圈墙、0.20 mm 层高及首层。
- 当前框身主体指定材料槽 4（黄色 PETG Basic），文字指定槽 2（绿色 PETG-CF）；其余槽位未参与打印。按实际材料映射，不必为了预览颜色购买对应材料。这个混合预设组合不等于已经完成实打验证。
- 保留八个桥接修改器、双色零件的相对位置和原有打印方向。检查首层及换色塔的位置。
- 冷却后逐一抠断八只翻片各自的上、中、下三条首层细筋，再检查回弹；齐平文字不能剥除。
- 夹头六瓣朝下、定位裙朝上，保留小件盘的夹头 brim。框身、夹头和帽的机械外形没有因本次发布改变。
