// PongFetch D1: integral six-finger hanger and compression nut. Prototype.
// Original design: PongFetch / Tia-Lin, CC BY-NC-SA 4.0.
// Assembly coordinates: pipe enters from -Z; body fingers start at Z=0.
// Nut advances +Z and rotates +360*travel/pitch. Not a rated suspension part.
include <BOSL2/std.scad>
include <BOSL2/threading.scad>
part="body"; // [body,nut,assembly,exploded,section,pipe]
travel=0;
show_pipe=true;
quality=96;
$fn=quality;
eps=0.015;
pipe_od=21.34;
bore_d=21.74;
finger_d=25.20;
fingers=6;
slot_width=1.20;
slot_root_z=15.60;
slot_root_d=2.40;
cone_angle=15;
cone_h=5.20;
cone_clearance=0.18; // Radial loose-position clearance.
cone_r0=finger_d/2;
cone_r1=cone_r0+cone_h*tan(cone_angle);
root_blend_start=13.40;
thread_major=30.0;
thread_depth=1.0;
thread_root=thread_major-2*thread_depth;
thread_pitch=3.0;
thread_clearance=0.60; // Diametral, matching the established coarse-thread family.
thread_start=18.0;
thread_end=29.60;
thread_ref=-6;
thread_ref_h=48;
stop_start_z=29.60;
stop_r0=thread_root/2;
shoulder_r=17.70;
shoulder_z=stop_start_z+shoulder_r-stop_r0;
pipe_stop_z=27.50;
roof_apex_z=pipe_stop_z+bore_d/2;
eye_y=6.40;
eye_center_z=50.20;
eye_outer_r=17.0;
eye_inner_r=9.0;
nut_bottom=-1.40;
nut_top=29.40;
nut_outer_r=17.50;
nut_cone_end=8.0;
chamber_r=15.10;
nut_thread_start=15.50; // Keep female entry below male start throughout the 2 mm stroke.
nut_mouth_start=27.80;
nut_mouth_r0=14.20;
// Matching 45-degree conical shoulders meet at this nominal advance.
max_travel=stop_start_z-stop_r0-(nut_mouth_start-nut_mouth_r0); // 2.0 mm
function smooth(t)=t*t*t*(10-15*t+6*t*t);
function nut_cone_r(z)=cone_r0+cone_clearance+z*tan(cone_angle);
assert(max_travel==2.0);
assert(cone_r1*2 < thread_root+thread_clearance-0.4,
       "Free finger flare must pass through female thread crests.");
assert(eye_center_z-eye_inner_r > roof_apex_z+2.0);
assert(eye_outer_r-eye_inner_r*sqrt(2)>4.0);
assert(nut_outer_r-0.25-(thread_major+thread_clearance)/2>1.8);
assert(slot_root_z+slot_root_d/2 < thread_start-1.0);

module clip(z0,z1) { translate([-50,-50,z0]) cube([100,100,z1-z0]); }
module helix(internal=false) {
    translate([0,0,thread_ref]) rotate([0,0,internal ? 180 : 0])
        trapezoidal_threaded_rod(d=thread_major,l=thread_ref_h,pitch=thread_pitch,
            thread_depth=thread_depth,thread_angle=90,internal=internal,
            blunt_start=false,bevel=false,anchor=BOT,
            $slop=internal ? thread_clearance/4 : 0,$fn=quality);
}
module eye_outline() {
    hull() {
        translate([0,eye_center_z]) circle(r=eye_outer_r,$fn=quality);
        translate([-14,36.0]) square([28,0.10]);
    }
}
module eye_hole() {
    // Circular lower edge and tangent 45-degree roof: no horizontal bridge roof.
    polygon(concat([for(a=[135:3:405])
        [eye_inner_r*cos(a),eye_center_z+eye_inner_r*sin(a)]],
        [[0,eye_center_z+eye_inner_r*sqrt(2)]]));
}
module eye_plate() {
    translate([0,eye_y/2,0]) rotate([90,0,0]) linear_extrude(eye_y)
        difference() { eye_outline(); eye_hole(); }
}
module body_blank() {
    union() {
        rotate_extrude($fn=quality) polygon(concat(
            [[0,0],[cone_r0,0],[cone_r1,cone_h],
             [cone_r0,cone_h+cone_r1-cone_r0],[cone_r0,root_blend_start]],
            [for(i=[1:24]) let(t=i/24)
                [cone_r0+(thread_root/2-cone_r0)*smooth(t),
                 root_blend_start+(thread_start-root_blend_start)*t]],
            [[thread_root/2,stop_start_z],[shoulder_r,shoulder_z],
             [shoulder_r,shoulder_z+0.25],[0,shoulder_z+0.25]]));
        intersection() {
            helix(); clip(thread_start,thread_end);
            // Taper in/out of each thread band to avoid unsupported abrupt starts.
            rotate_extrude($fn=quality) polygon([
                [0,thread_start],[thread_root/2,thread_start],
                [thread_major/2,thread_start+1],
                [thread_major/2,thread_end-1],
                [thread_root/2,thread_end],[0,thread_end]]);
        }
        hull() {
            translate([0,0,shoulder_z]) cylinder(r=shoulder_r,h=0.25);
            translate([-14,-eye_y/2,40.3]) cube([28,eye_y,0.25]);
        }
        eye_plate();
    }
}
module slot_cut() {
    // Rounded relief at the closed slot end; only a 2.4 mm local roof span.
    union() {
        translate([0,-slot_width/2,-1]) cube([25,slot_width,slot_root_z+1]);
        translate([0,0,slot_root_z]) rotate([0,90,0])
            cylinder(d=slot_root_d,h=25,$fn=40);
    }
}
module body() {
    difference() {
        body_blank();
        translate([0,0,-eps]) cylinder(d=bore_d,h=pipe_stop_z+eps);
        translate([0,0,pipe_stop_z-eps])
            cylinder(r1=bore_d/2,r2=0,h=bore_d/2+eps);
        // Mouth chamfer faces downward in the upright print orientation.
        translate([0,0,-eps]) cylinder(d1=bore_d+0.8,d2=bore_d,h=0.4+eps);
        for(a=[0:360/fingers:359]) rotate([0,0,a+30]) slot_cut();
    }
}
module nut_assembly() {
    difference() {
        rotate_extrude($fn=quality) polygon([
            [0,nut_bottom],[nut_cone_r(nut_bottom)+2.1,nut_bottom],
            [nut_cone_r(6)+2.1,6],[17.2,8],[nut_outer_r,16.8],
            [nut_outer_r,nut_top],[0,nut_top]]);
        // Continuous cone/chamber/entry profile, with no horizontal internal shelf.
        rotate_extrude($fn=quality) polygon([
            [0,nut_bottom-1],[nut_cone_r(nut_bottom-1),nut_bottom-1],
            [nut_cone_r(nut_cone_end),nut_cone_end],
            [chamber_r,nut_cone_end+chamber_r-nut_cone_r(nut_cone_end)],
            [chamber_r,15.8],[(thread_root+thread_clearance)/2,16.6],
            [nut_mouth_r0,nut_mouth_start],
            [nut_mouth_r0+(nut_top-nut_mouth_start),nut_top],
            [nut_mouth_r0+(nut_top+1-nut_mouth_start),nut_top+1],[0,nut_top+1]]);
        intersection() { helix(true); clip(nut_thread_start,nut_top+1); }
        // Shallow exterior flutes leave >=1.95 mm at the deepest thread clearance.
        for(a=[0:30:359]) rotate([0,0,a])
            translate([nut_outer_r+2.75,0,18]) cylinder(r=3,h=nut_top-18+1,$fn=32);
    }
}
module nut_print() { translate([0,0,-nut_bottom]) nut_assembly(); }
module pipe() {
    color([0.7,0.7,0.7,0.45]) translate([0,0,-45]) difference() {
        cylinder(d=pipe_od,h=pipe_stop_z+45+0.20);
        // Display only: the actual pipe inside diameter is not part of the interface.
        translate([0,0,-1]) cylinder(d=15.8,h=pipe_stop_z+47);
    }
}
module assembly(separated=0) {
    color("Gold") body();
    color("SeaGreen") translate([0,0,travel-separated])
        rotate([0,0,360*travel/thread_pitch]) nut_assembly();
    if(show_pipe) pipe();
}
if(part=="body") body();
else if(part=="nut") nut_print();
else if(part=="assembly") assembly();
else if(part=="exploded") assembly(38);
else if(part=="section") intersection() {
    assembly(); translate([-50,-50,-100]) cube([100,50,200]);
}
else if(part=="pipe") pipe();
