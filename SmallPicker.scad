// PongFetch rev 3.0: validated mechanism with flush two-colour branding.
// Select a part in the Customizer or with: openscad -D 'part="cap"' ...
include <BOSL2/std.scad>
include <BOSL2/hinges.scad>
include <ColletSocket.scad>
use <SideLatch.scad>
use <Branding.scad>

part = "frame"; // [frame,frame_base,frame_text,assembly,exploded,section,frame_only,socket,collet,cap]
show_pipe = false;
explode_distance = 75;

ball_size = 40;
ball_interference= 1.7;
rib_width =3;
rib_height =8;
fin_bottom_width = 1.2; // Flat bed contact; target two first-layer paths at 0.5 mm line width.
grid_size = 4;
cuboid_wall = 6;
cuboid_height = 14;
cuboid_wall_reinforcement = 10;

// Local root transitions; the flexible central fin section remains 3 x 8 mm.
fin_root_step_from_outer = 25;
fin_root_transition = 15;
fin_root_radius = 2;
fin_root_samples = 48;
function picker_smooth01(t) = t*t*t*(10-15*t+6*t*t);

cuboid_inner_x = grid_size*(ball_size-ball_interference)+(grid_size-1)*(rib_width); 
cuboid_inner_y = cuboid_inner_x;

cuboid_outter_x = cuboid_inner_x + (cuboid_wall*2) + cuboid_wall_reinforcement;
cuboid_outter_y = cuboid_inner_y + (cuboid_wall*2);




// Station distances are measured from the middle of each edge.
// 46 mm keeps the four-pin pockets clear of the fin-root attachments.
latch_station=46;
handle_latch_station=52;
latch_layout=[
    [-latch_station,-cuboid_outter_y/2,0,false],
    [ latch_station,-cuboid_outter_y/2,0,true],
    [ latch_station, cuboid_outter_y/2,180,false],
    [-latch_station, cuboid_outter_y/2,180,true],
    [-cuboid_outter_x/2, latch_station,-90,false],
    [-cuboid_outter_x/2,-latch_station,-90,true],
    [ cuboid_outter_x/2,-handle_latch_station,90,false],
    [ cuboid_outter_x/2, handle_latch_station,90,true]
];
module at_latch(i) {
    t=latch_layout[i];
    translate([t[0],t[1],0]) rotate([0,0,t[2]])
        if(t[3]) mirror([1,0,0]) children(); else children();
}

// A C2 height transition replaces the old abrupt 6 mm root step.
module picker_root_envelope(width, bottom=0) {
    step_y=cuboid_outter_y/2-fin_root_step_from_outer;
    start_y=step_y-fin_root_transition/2;
    profile=concat([[start_y,bottom],[cuboid_outter_y/2,bottom],
                    [cuboid_outter_y/2,cuboid_height]],
        [for(i=[fin_root_samples:-1:0]) let(t=i/fin_root_samples)
            [start_y+fin_root_transition*t,
             rib_height+(cuboid_height-rib_height)*picker_smooth01(t)]]);
    multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
        linear_extrude(width,center=true) polygon(profile);
}
// Fill the wedge-to-fillet gaps only in the last 3.5 mm at each fin end.
// The round nose is tangent to the original side fillet in plan view.
// Above the 2 mm wedge height this addition is inside the existing fin.
module picker_fin_root_base() {
    wall_y=cuboid_inner_y/2;
    r=fin_root_radius;
    linear_extrude(rib_width/1.5+0.02) union() {
        translate([-rib_width/2,wall_y-r]) square([rib_width,r+0.02]);
        translate([0,wall_y-r]) circle(r=rib_width/2,$fn=48);
    }
}

module picker_fin_root() {
    picker_fin_root_base();
    wall_y=cuboid_inner_y/2;
    r=fin_root_radius;
    // Add only the smoothly rising cap to the unchanged wedge-bottom fin.
    picker_root_envelope(rib_width,rib_height-0.02);
    // In-plane tangent fillets spread lateral bending into the frame wall.
    // Grounded at the bed: no horizontal underside or support-required shelf.
    intersection() {
        picker_root_envelope(rib_width+2*r+0.04);
        linear_extrude(cuboid_height) for(side=[-1,1]) scale([side,1,1])
            polygon(concat([[rib_width/2-0.02,wall_y-r]],
                [for(i=[0:32]) let(a=180-90*i/32)
                    [rib_width/2+r+r*cos(a),wall_y-r+r*sin(a)]],
                [[rib_width/2+r,wall_y+0.02],[rib_width/2-0.02,wall_y+0.02]]));
    }
}
module picker_ribs() {
    translate([-cuboid_wall_reinforcement/2,0,0])
    for(i=[1:grid_size-1]) {
        j=i-grid_size/2;
        translate([j*(ball_size-ball_interference+rib_width),0,0]) {
            // Flat underside stays on Z=0; blend into the original full width at Z=2.
            translate([0,cuboid_outter_y/2,0]) rotate([90,0,0])
                linear_extrude(cuboid_outter_y)
                    polygon([[-fin_bottom_width/2,0],[fin_bottom_width/2,0],
                        [rib_width/2,rib_width/1.5],
                        [rib_width/2,rib_height],[-rib_width/2,rib_height],
                        [-rib_width/2,rib_width/1.5]]);
            picker_fin_root();
            mirror([0,1,0]) picker_fin_root();
        }
    }
}

module picker_ring() {
    translate([0,0,cuboid_height/2]) difference() {
        cuboid([cuboid_outter_x,cuboid_outter_y,cuboid_height],
            rounding=(ball_size+2*cuboid_wall)/2,
            edges=[FWD+LEFT,FWD+RIGHT,BACK+RIGHT,BACK+LEFT],$fn=50);
        translate([-cuboid_wall_reinforcement/2,0,0])
            cuboid([cuboid_inner_x,cuboid_inner_y,cuboid_height+0.1],
                rounding=ball_size/2,
                edges=[FWD+LEFT,FWD+RIGHT,BACK+RIGHT,BACK+LEFT],$fn=50);
    }
}
module picker_frame() {
    difference() {
        union() {
            picker_ring();
            difference() {
                for(i=[0:7]) at_latch(i) side_latch_frame_additions(handle=i>=6);
                // New shoulders must not refill the validated PVC insertion bore.
                // Restrict this cut to new additions: original rim and mount stay intact.
                socket_placement(cuboid_outter_x) socket_bore_local();
            }
        }
        for(i=[0:7]) at_latch(i) side_latch_frame_cuts(handle=i>=6);
    }
    // Keep ball-contact spans and add the smooth fin-root transitions after latch cuts.
    picker_ribs();
    for(i=[0:7]) at_latch(i) side_latch_print_parts();
}
module picker_body() {
    picker_frame();
    collet_socket(cuboid_outter_x);
}

module picker_branding() {
    for(k=[0:3]) at_latch(k+4) brand_local_print(k);
}
module picker_branded_body() {
    color("#FCE300") difference() { picker_body(); picker_branding(); }
    color("#034638") picker_branding();
}

if (part == "frame") picker_branded_body();
else if (part == "frame_base") difference() { picker_body(); picker_branding(); }
else if (part == "frame_text") picker_branding();
else if (part == "frame_only") picker_frame();
else if (part == "socket") collet_socket(cuboid_outter_x);
else if (part == "collet") pvc_collet_for_print();
else if (part == "cap") collet_cap();
else if (part == "socket_test") socket_shell_local();
else if (part == "fit_test_layout") {
    // Three small test pieces on one plate; the socket keeps the real 30° tilt.
    translate([-77,0,0]) collet_socket(cuboid_outter_x);
    translate([-30,0,0]) pvc_collet_for_print();
    translate([-78,0,0]) collet_cap();
}
else if (part == "section") {
    difference() {
        socket_assembly(cuboid_outter_x,pipe=show_pipe);
        translate([-200,-200,-10]) cube([500,200,250]);
    }
}
else if (part == "assembly" || part == "exploded") {
    color("#FCE300") difference() { picker_frame(); picker_branding(); }
    color("#034638") picker_branding();
    socket_assembly(cuboid_outter_x,
        exploded=part == "exploded" ? explode_distance : 0,
        pipe=show_pipe);
}
else assert(false,str("Unknown part: ",part));
