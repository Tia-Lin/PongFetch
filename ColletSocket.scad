// PETG prototype: reusable PVC collet and screw cap.
// Lengths are millimetres. All local geometry uses the socket axis as +Z.
include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// Measure your actual pipe before printing the complete picker.
pipe_od = 21.34;
socket_bore_d = 21.75;
collet_bore_clearance = 0.40;  // DIAMETRAL, independent of thread clearance
thread_diametral_clearance = 0.60;
cone_radial_clearance = 0.20;

socket_angle = 30;
socket_length = 50.3;         // 5 mm shorter than the physically tested collet revision
socket_bottom = 6.25;
socket_lower_d = 30;
thread_major_d = 34;
thread_pitch = 3;
thread_depth = 1.0;
thread_angle = 90;           // 45-degree flanks for axial printing
thread_root_d = thread_major_d - 2*thread_depth;
thread_band_length = 12.5;
socket_pilot_d = 25.70;      // retain this pocket so the previous pilot collet still fits
socket_pilot_depth = 4.2;

// Restore the pilot and preserve the flat flange seat at local Z4.
collet_seat_z = 4.0;
collet_pilot_d = 25.20;
collet_pilot_trim = 0.25;
collet_bottom_chamfer = 0.4;
collet_collar_bore_d = 22.0;
collet_collar_relief_z = 6.0;
collet_flange_d = 30.20;
collet_flange_h = 2.0;
collet_finger_d = 25.20;
// Printed tips-down: expand into the full-thickness flange at 45 degrees.
collet_flange_ramp_h = (collet_flange_d-collet_finger_d)/2;
collet_height = 24.0;        // upper local Z; tips-down printed height is 24 - 0.25 = 23.75
collet_slot_count = 6;
collet_slot_width = 1.2;
collet_slot_root_z = 8.2;
collet_slot_root_d = 2.4;
cone_half_angle = 15;
cone_length = 8;

cap_outer_d = 40;
cap_grip_depth = 0.35;       // shallow grooves preserve the hoop wall
cap_cone_wall = 3.0;         // radial wall following the upper internal taper
cap_start_above_thread_base = 1.0;
cap_max_travel = 3.2;        // geometric stop, NOT a torque limiter
cap_lip_h = 1.0;
cap_chamber_d = 30.8;        // clears flange; forms stop against socket rim

cs_eps = 0.02;
cs_fn = 96;
cone_start_z = collet_height-cone_length;
cone_bottom_d = collet_finger_d + 2*cone_length*tan(cone_half_angle);
cone_ramp_h = (cone_bottom_d-collet_finger_d)/2;
collet_assembly_z = socket_length-collet_seat_z;
cap_bottom_z = socket_length-thread_band_length+cap_start_above_thread_base;
cap_thread_top_z = socket_length+cap_max_travel;
cap_cone_start_z = collet_assembly_z+cone_start_z;
cap_cone_end_z = collet_assembly_z+collet_height+cap_max_travel;
cap_top_z = cap_cone_end_z+cap_lip_h;
cap_height = cap_top_z-cap_bottom_z;
cap_top_bore_d = collet_finger_d + 2*cone_radial_clearance
    -2*cap_max_travel*tan(cone_half_angle);
cap_taper_start_z = cap_thread_top_z+0.8;
cap_cone_outer_bottom_d = cone_bottom_d+2*cone_radial_clearance+2*cap_cone_wall;
cap_outer_top_d = cap_top_bore_d+2*cap_cone_wall;

// Male and female use the same reference length and axial origin.
// BOSL2 shifts the internal symmetric profile by half a pitch; the internal
// mask is rotated 180 degrees to align its cavity with the external ridge.
thread_reference_z = socket_length-25;
thread_reference_h = 32;

assert(collet_finger_d > pipe_od+collet_bore_clearance+2.5);
assert(collet_flange_d < thread_root_d+thread_diametral_clearance);
assert(cap_chamber_d > collet_flange_d+0.3);
assert(cap_chamber_d < thread_root_d);
assert(cap_top_bore_d > pipe_od+0.8);
assert((thread_root_d-socket_pilot_d)/2 > 2.5);
assert(collet_collar_bore_d >= pipe_od+collet_bore_clearance);
assert(collet_collar_relief_z+0.6 < collet_slot_root_z-collet_slot_root_d/2);
assert(collet_pilot_trim+collet_bottom_chamfer < collet_seat_z);
assert(collet_pilot_d < socket_pilot_d);
assert(collet_seat_z-collet_pilot_trim < socket_pilot_depth);
assert(collet_seat_z+collet_flange_h+collet_flange_ramp_h < cone_start_z-cone_ramp_h);
assert(cap_taper_start_z < cap_cone_start_z);
assert(cap_outer_d > cap_cone_outer_bottom_d);
assert((cap_outer_d-thread_major_d-thread_diametral_clearance)/2-cap_grip_depth > 2.2);
assert(socket_length-0.8-(cap_bottom_z+1.5) >= 3*thread_pitch);

module cs_axial_clip(z0,z1,diam=120) {
    translate([-diam/2,-diam/2,z0]) cube([diam,diam,z1-z0]);
}

module cs_thread(internal=false) {
    translate([0,0,thread_reference_z])
      rotate([0,0,internal ? 180 : 0])
        trapezoidal_threaded_rod(d=thread_major_d,
            l=thread_reference_h, pitch=thread_pitch,
            thread_depth=thread_depth, thread_angle=thread_angle,
            internal=internal, blunt_start=false, bevel=false,
            anchor=BOT, $slop=internal ? thread_diametral_clearance/4 : 0,
            $fn=cs_fn);
}

module socket_placement(frame_outer_x=184.2) {
    translate([frame_outer_x/2+13,0,34])
        rotate([0,socket_angle,0]) translate([0,0,-30]) children();
}

module socket_bore_local() {
    translate([0,0,socket_bottom])
        cylinder(d=socket_bore_d,h=socket_length+2,$fn=cs_fn);
    translate([0,0,socket_length-socket_pilot_depth])
        cylinder(d=socket_pilot_d,h=socket_pilot_depth+2,$fn=cs_fn);
    // Small pilot entrance chamfer. The flat annular seat remains intact.
    translate([0,0,socket_length-0.4])
        cylinder(d1=socket_pilot_d,d2=socket_pilot_d+0.8,
            h=0.4+cs_eps,$fn=cs_fn);
}

module socket_shell_local() {
    difference() {
        union() {
            cylinder(d=socket_lower_d,h=socket_length-thread_band_length-3,$fn=cs_fn);
            translate([0,0,socket_length-thread_band_length-3-cs_eps])
                cylinder(d1=socket_lower_d,d2=thread_root_d,h=3+2*cs_eps,$fn=cs_fn);
            translate([0,0,socket_length-thread_band_length-cs_eps])
                // Slight overlap avoids coincident root faces in binary STL.
                cylinder(d=thread_root_d+2*cs_eps,h=thread_band_length+cs_eps,$fn=cs_fn);
            intersection() {
                cs_thread();
                cs_axial_clip(socket_length-thread_band_length,socket_length-0.8);
                // Lead-in tapers to the root diameter at the upper end.
                union() {
                    cylinder(d=thread_major_d+2,h=socket_length-2,$fn=cs_fn);
                    translate([0,0,socket_length-2])
                        cylinder(d1=thread_major_d+2,d2=thread_root_d,h=1.2,$fn=cs_fn);
                }
            }
        }
        socket_bore_local();
    }
}

module socket_mount(frame_outer_x=184.2) {
    // Broad frame-root shoulders replace the former twisted eight-vertex block.
    // The two sides retreat along an ellipse above the ordinary frame top;
    // a coaxial outer envelope blends tangentially into the existing sleeve.
    // This is a load-path geometry revision, not a tested strength rating.
    // X >= frame_outer_x/2-15.6 and |Y| <= 22.7 preserve the R8 net routes,
    // side keeper throat and the eight moving latch envelopes.
    x = frame_outer_x/2;
    inner_x = x-15.1;  // retain the old 0.1 mm union-overlap datum
    root_half_width = 22.7;
    frame_top = 14;
    blend_top = 42;
    radial_steps = cs_fn;
    blend_steps = 64;
    base_steps = 14;
    // Horizontal intersections of the unchanged axis placement and cylinder.
    axis_bottom_x = x+13-30*sin(socket_angle);
    axis_bottom_z = 34-30*cos(socket_angle);
    ellipse_rx = socket_lower_d/2/cos(socket_angle);
    function axis_x(z) = axis_bottom_x+(z-axis_bottom_z)*tan(socket_angle);
    function smoothstep(t) = t*t*(3-2*t);
    function signed_power(v,p) = sign(v)*pow(abs(v),p);
    function ring_point(z,a) =
        let(u=max(0,min(1,(z-25)/(blend_top-25))),
            root_u=max(0,min(1,(z-frame_top)/6)),
            shoulder=smoothstep(u),
            width_u=max(0,min(1,(z-20)/(blend_top-20))),
            root_round=sqrt(max(0,2*root_u-root_u*root_u)),
            toe_u=max(0,min(1,(z-frame_top)/1.5)),
            toe=0.5*(1-sqrt(max(0,2*toe_u-toe_u*toe_u))),
            left=inner_x-toe+max(0,axis_x(z)-ellipse_rx-inner_x)*shoulder,
            right=z < frame_top
                ? (x+14.9)+(axis_x(frame_top)+ellipse_rx-(x+14.9))*z/frame_top
                : axis_x(z)+ellipse_rx,
            half_y=root_half_width-3.0*root_round-(root_half_width-3.0-socket_lower_d/2)*smoothstep(width_u),
            exponent=4-2*smoothstep(root_u))
        [(left+right)/2+(right-left)/2*signed_power(cos(a),2/exponent),
         half_y*signed_power(sin(a),2/exponent),z];
    levels=concat([for(i=[0:base_steps-1]) frame_top*i/base_steps],
                  [for(i=[0:blend_steps]) frame_top+(blend_top-frame_top)*i/blend_steps]);
    points=[for(z=levels) for(i=[0:radial_steps-1]) ring_point(z,360*i/radial_steps)];
    count=len(levels);
    // OpenSCAD polyhedron uses clockwise faces as viewed from outside.
    faces=concat([[for(i=[0:radial_steps-1]) i]],
        [for(k=[0:count-2]) for(i=[0:radial_steps-1]) for(t=[0:1])
            let(j=(i+1)%radial_steps,a=k*radial_steps+i,b=(k+1)*radial_steps+i,
                c=(k+1)*radial_steps+j,d=k*radial_steps+j)
            t==0 ? [a,b,c] : [a,c,d]],
        [[for(i=[radial_steps-1:-1:0]) (count-1)*radial_steps+i]]);
    intersection() {
        polyhedron(points=points,faces=faces,convexity=8);
        // This envelope preserves the broad root through the former upper
        // gusset, then approaches the sleeve with zero radial slope. It avoids
        // both a narrow upper neck and a flat annular clipping ledge.
        // End 0.02 mm inside the unchanged sleeve to avoid coincident CSG faces.
        socket_placement(frame_outer_x) rotate_extrude($fn=cs_fn)
            polygon(concat([[0,-50],[socket_lower_d/2-cs_eps+12,-50],[socket_lower_d/2-cs_eps+12,20]],
                [for(i=[1:48]) let(t=i/48)
                    [socket_lower_d/2-cs_eps+12*(1-t)*(1-t),
                     20+(socket_length-thread_band_length-3-20)*t]],
                [[socket_lower_d/2-cs_eps,60],[0,60]]));
    }
}

module collet_socket(frame_outer_x=184.2) {
    difference() {
        union() {
            socket_placement(frame_outer_x) socket_shell_local();
            socket_mount(frame_outer_x);
        }
        // The bore also passes through the mounting gusset, as in V2.1.
        socket_placement(frame_outer_x) socket_bore_local();
    }
}

module pvc_collet() {
    difference() {
        // One revolved annular profile avoids near-coincident boolean seams
        // at the collar relief and pilot chamfers when exported to STL.
        rotate_extrude($fn=cs_fn) polygon([
            [collet_pilot_d/2-collet_bottom_chamfer,collet_pilot_trim],
            [collet_pilot_d/2,collet_pilot_trim+collet_bottom_chamfer],
            [collet_pilot_d/2,collet_seat_z],
            [collet_flange_d/2,collet_seat_z],
            [collet_flange_d/2,collet_seat_z+collet_flange_h],
            [collet_finger_d/2,collet_seat_z+collet_flange_h+collet_flange_ramp_h],
            [collet_finger_d/2,cone_start_z-cone_ramp_h],
            [cone_bottom_d/2,cone_start_z],
            [collet_finger_d/2,collet_height],
            [(pipe_od+collet_bore_clearance)/2+0.6,collet_height],
            [(pipe_od+collet_bore_clearance)/2,collet_height-0.6],
            [(pipe_od+collet_bore_clearance)/2,collet_collar_relief_z+0.6],
            [collet_collar_bore_d/2,collet_collar_relief_z],
            [collet_collar_bore_d/2,collet_pilot_trim+collet_bottom_chamfer],
            [collet_collar_bore_d/2+collet_bottom_chamfer,collet_pilot_trim]
        ]);
        // Radial cuts leave six fingers attached to the continuous lower collar.
        for (a=[0:360/collet_slot_count:359]) rotate([0,0,a]) {
            translate([0,-collet_slot_width/2,collet_slot_root_z])
                cube([collet_flange_d,collet_slot_width,collet_height]);
            translate([0,0,collet_slot_root_z]) rotate([0,90,0])
                cylinder(d=collet_slot_root_d,h=collet_flange_d,$fn=32);
        }
    }
}

module pvc_collet_for_print() {
    // Six tips on the bed; the pilot and flange seat finish facing upward.
    translate([0,0,collet_height]) rotate([180,0,0]) pvc_collet();
}

// Cap at the nominal loose assembly position in socket coordinates.
module cap_at_socket() {
    difference() {
        // A tapered exterior follows the functional cone instead of carrying
        // the full grip diameter all the way to the pipe opening.
        rotate_extrude($fn=cs_fn) polygon([
            [0,cap_bottom_z],
            [cap_outer_d/2,cap_bottom_z],
            [cap_outer_d/2,cap_taper_start_z],
            [cap_cone_outer_bottom_d/2,cap_cone_start_z],
            [cap_outer_top_d/2,cap_cone_end_z],
            [cap_outer_top_d/2,cap_top_z],
            [0,cap_top_z]
        ]);
        intersection() {
            cs_thread(internal=true);
            cs_axial_clip(cap_bottom_z-1,cap_thread_top_z);
        }
        // Female thread mouth: clearance taper for easy starting.
        translate([0,0,cap_bottom_z-cs_eps])
            cylinder(d1=thread_major_d+thread_diametral_clearance+1,
                d2=thread_root_d+thread_diametral_clearance,h=1.5,$fn=cs_fn);
        translate([0,0,cap_thread_top_z-cs_eps])
            cylinder(d=cap_chamber_d,h=cap_cone_start_z-cap_thread_top_z+cs_eps,$fn=cs_fn);
        translate([0,0,cap_cone_start_z-cs_eps])
            cylinder(d1=cone_bottom_d+2*cone_radial_clearance+2*cs_eps*tan(cone_half_angle),
                d2=cap_top_bore_d,h=cap_cone_end_z-cap_cone_start_z+cs_eps,$fn=cs_fn);
        translate([0,0,cap_cone_end_z-cs_eps])
            cylinder(d=cap_top_bore_d,h=cap_lip_h+1,$fn=cs_fn);
        // Shallow axial grip flutes keep a thick continuous load-bearing ring.
        for(a=[0:30:330]) rotate([0,0,a])
            translate([cap_outer_d/2+3-cap_grip_depth,0,cap_bottom_z+2]) union() {
                cylinder(d1=6-2*cap_grip_depth,d2=6,h=cap_grip_depth,$fn=32);
                translate([0,0,cap_grip_depth])
                    cylinder(d=6,h=cap_taper_start_z-cap_bottom_z-2-cap_grip_depth,$fn=32);
            }
    }
}

module collet_cap() {
    // Small pipe opening on the bed: the internal shoulder faces upward.
    // The unchanged symmetric thread keeps its 45-degree flanks.
    translate([0,0,cap_top_z]) rotate([180,0,0]) cap_at_socket();
}

module socket_assembly(frame_outer_x=184.2, exploded=0, pipe=false) {
    color("SteelBlue") collet_socket(frame_outer_x);
    socket_placement(frame_outer_x) {
        color("DarkOrange") translate([0,0,collet_assembly_z+exploded]) pvc_collet();
        color("SeaGreen") translate([0,0,exploded*2]) cap_at_socket();
        if(pipe) color([0.7,0.7,0.7,0.3])
            translate([0,0,socket_bottom]) difference() {
                cylinder(d=pipe_od,h=95,$fn=cs_fn);
                translate([0,0,-1]) cylinder(d=15.8,h=97,$fn=cs_fn);
            }
    }
}
