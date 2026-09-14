// Rev 3.0: flush, three-layer inlays on the outward face of four closed flaps.
// Text is specified in the CLOSED pose; mirrored stations compensate glyph handedness.
use <SideLatch.scad>
brand_depth=0.60;
brand_font="Arial:style=Bold";
brand_labels=["PongFetch","Pick.Play.","open source","rev 3.0"];
brand_stations=[4,5,6,7];
module brand_local_text(label, mirrored=false) {
    translate([-4,-3.6+brand_depth,9.1]) rotate([90,0,0])
        scale([mirrored ? -1 : 1,1,1]) linear_extrude(brand_depth)
            text(label,size=label=="open source" ? 4.0 : 4.5,font=brand_font,halign="center",valign="center",spacing=1,$fn=32);
}
module brand_local_print(k) {
    sl_closed_to_print() brand_local_text(brand_labels[k],k==1 || k==3);
}
