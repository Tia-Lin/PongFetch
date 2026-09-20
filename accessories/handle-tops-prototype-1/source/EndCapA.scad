// PongFetch A1 decorative pipe-end cap prototype. Units: mm.
// CC BY-NC-SA 4.0, original design: PongFetch / Tia-Lin.
// Not a suspension attachment. Fit is unvalidated; use actual pipe measurements.
part="cap"; // [cap,body,inlay,fit_ring]
pipe_od=21.34;
bore_clearance=0.40; // Diametral clearance of the cylindrical bore.
wall=1.20;
roof=1.20;
insertion=8.00;
contact_d=21.24; // Three rib tips; change +/-0.10 for fit trials.
inlay_depth=0.40;
$fn=128;
eps=0.01;
bore_d=pipe_od+bore_clearance;
outer_d=bore_d+2*wall;
height=roof+insertion;

assert(contact_d<=bore_d);
assert(roof>inlay_depth+0.6);

module paddle_mark() {
    rotate(24) {
        translate([-1,1.6]) scale([0.83,1]) circle(r=4.4,$fn=64);
        hull() {
            translate([-1,-2]) circle(r=1.15,$fn=32);
            translate([-1,-6.0]) circle(r=1.15,$fn=32);
        }
    }
    translate([5,4.5]) circle(r=1.45,$fn=40);
}

module outer_shell() {
    difference() {
        union() {
            cylinder(d1=outer_d-0.8,d2=outer_d,h=0.4);
            translate([0,0,0.4-eps]) cylinder(d=outer_d,h=height-0.4+eps);
        }
        translate([0,0,roof]) cylinder(d=bore_d,h=insertion+eps);
        translate([0,0,height-0.6]) cylinder(d1=bore_d,d2=bore_d+0.6,h=0.6+eps);
    }
}

module contact_ribs() {
    // Rounded axial ribs overlap the wall. The opening end fades into the bore.
    rib_r=0.60;
    center_r=contact_d/2+rib_r;
    for (a=[0:120:240]) rotate([0,0,a]) {
        translate([center_r,0,roof-eps]) cylinder(r=rib_r,h=insertion-1.6+eps);
        hull() {
            translate([center_r,0,height-1.6-eps]) cylinder(r=rib_r,h=eps);
            translate([bore_d/2+rib_r,0,height-eps]) cylinder(r=rib_r,h=eps);
        }
    }
}

module cap() {
    union() {
        outer_shell();
        intersection() {
            contact_ribs();
            cylinder(d=outer_d,h=height);
        }
    }
}

module ink() {
    linear_extrude(inlay_depth) paddle_mark();
}

if(part=="cap") cap();
else if(part=="body") difference() { cap(); translate([0,0,-eps]) linear_extrude(inlay_depth+eps) paddle_mark(); }
else if(part=="inlay") ink();
else if(part=="fit_ring") intersection() {
    translate([0,0,-(height-4.8)]) cap();
    cylinder(d=outer_d+1,h=4.8);
}
