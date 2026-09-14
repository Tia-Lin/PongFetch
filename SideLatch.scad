// Integrated side latch, derived from R7; compact housing and 0.95 mm engagement.
// Local +X points toward the middle of the frame edge; +Y points toward balls.
// Closed axes: X along frame; +Y toward balls; +Z up. Flat printing is the R4 pose.
include <BOSL2/std.scad>
include <BOSL2/hinges.scad>

$fn=64;
eps=0.02;
axis=[0,-2.1,1.5];
panel_right=26.6;
panel_top=21.0;
latch_engagement=0.95; // Midpoint between the earlier 0.8 mm and R9 1.1 mm.
latch_nose_x=27.0+latch_engagement;
roof_bottom=3.0; // Print Z; 0.6 mm above the 2.4 mm-thick thumb/head.
roof_top=4.2;
net_pin_x=[-17,-17/3,17/3,17];
net_lane_front=2.4;
net_lane_back=4.4;
frame_top=14;
lane_floor_front=12.6; // R6 depth 16.8 -> 8.4 mm from Z21.
lane_floor_back=12.0; // R6 depth 18 -> 9 mm from Z21.
function sl_smooth01(t)=t*t*(3-2*t);
function sl_blend_top(x0,x1)=
    [for(i=[32:-1:0]) [x0+(x1-x0)*i/32,
        frame_top+(panel_top-frame_top)*sl_smooth01(i/32)]];

module sl_original_hinge(inner) {
    knuckle_hinge(length=40,segs=13,offset=2.1,inner=inner,
        clearance=-1.5,knuckle_diam=3,arm_angle=45,gap=0.15,
        in_place=true,clip=1.5) children();
}
module sl_fixed_leaf() {
    cuboid([40,3,5],anchor=TOP+BACK,rounding=1,edges=[BOT+LEFT,BOT+RIGHT]);
}
module sl_moving_leaf() {
    cuboid([40,3,14],anchor=TOP+BACK,rounding=1,edges=[BOT+LEFT,BOT+RIGHT]);
}
module sl_original_pair() {
    translate([0,0,3]) xrot(90)
        sl_original_hinge(false) {
            position(BOT) sl_fixed_leaf();
            up(0.6) attach(BOT,TOP,inside=true) tag("")
                sl_original_hinge(true) position(BOT) sl_moving_leaf();
        }
}
module sl_closed_to_print() {
    multmatrix([[1,0,0,0],[0,0,-1,-0.6],[0,1,0,3.6],[0,0,0,1]]) children();
}
module sl_prism_x(x0,width,profile) {
    translate([x0,0,0])
        multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
            linear_extrude(width) polygon(profile);
}
module sl_closed_box(x,y,z,dx,dy,dz) { translate([x,y,z]) cube([dx,dy,dz]); }
module sl_prism_y(y0,depth,profile) {
    translate([0,y0+depth,0]) rotate([90,0,0])
        linear_extrude(depth) polygon(profile);
}
module sl_top_envelope_closed(x0,x1) {
    sl_prism_y(-30,60,concat([[-40,-30],[40,-30],[40,panel_top]],
        sl_blend_top(x0,x1),[[-40,frame_top]]));
}
module sl_frame_height_blend() {
    // Add supported material above the existing frame, then cut the net lane.
    // Tangent at both ends: no abrupt 7 mm step into the tall receiver.
    sl_prism_y(1.8,4.2,concat([[12,frame_top-eps],[27,frame_top-eps]],
        sl_blend_top(12,27)));
}

module sl_spring_bay_closed() {
    // Exterior recess: narrow around the stem and wide around the thumb/head.
    sl_closed_box(20.3,-3.7,5.0,4.9,3.2,5.2+eps);
    sl_closed_box(18.0,-3.7,10.2,7.2,3.2,5.4);
    sl_closed_box(20.0,-3.7,15.6,5.2,3.2,4.2);
    // Only the nose exit interrupts the right bridge-support rail.
    sl_closed_box(25.2-eps,-3.7,15.5,panel_right-25.2+2*eps,3.2,4.3);
}
module sl_rigid_body_untrimmed_print() {
    difference() {
        union() {
            sl_original_pair();
            translate([-22,-panel_top-0.6,0])
                cube([panel_right+22,panel_top-3.6,3]);
        }
        sl_closed_to_print() sl_spring_bay_closed();
    }
    // Side/top/root rails support a short bridge over the exterior spring bay.
    difference() {
        translate([16.5,-panel_top-0.6,3-eps])
            cube([panel_right-16.5,panel_top-3.6,roof_bottom-3+eps]);
        sl_closed_to_print() {
            sl_closed_box(20.3,-0.7,5.0,4.9,1.0,5.2+eps);
            sl_closed_box(18.0,-0.7,10.2,7.2,1.0,5.4);
            sl_closed_box(20.0,-0.7,15.6,5.2,1.0,4.2);
            sl_closed_box(25.2-eps,-0.7,15.5,panel_right-25.2+2*eps,1.0,4.3);
        }
    }
    // Unbroken net-contact skin. The seam and spring are on the hand side.
    translate([16.5,-panel_top-0.6,roof_bottom])
        cube([panel_right-16.5,panel_top-3.6,roof_top-roof_bottom]);
    // 45-degree blend from the old net plane to the raised skin.
    translate([0,-4.2,0]) rotate([90,0,0]) linear_extrude(panel_top-3.6)
        polygon([[15.3,3-eps],[16.5,3-eps],[16.5,roof_top]]);
    // Thumb over-travel stop, attached to the rigid wall, not to the spring.
    sl_closed_to_print() sl_closed_box(17.8,-3.6,11.5,2.25,2.8,3.3);
}
module sl_rigid_body_print() {
    intersection() {
        sl_rigid_body_untrimmed_print();
        // Trim the unused high left shoulder; preserve the upper-head bridge rail.
        sl_closed_to_print() sl_top_envelope_closed(14,20.5);
    }
}
module sl_latch_head_closed() {
    // The flat -Y face is the retaining face; only the incoming face is ramped.
    translate([0,0,16.0]) linear_extrude(2.6)
        polygon([[22.0,-3.6],[latch_nose_x,-3.6],[latch_nose_x,-3.1],
                 [latch_nose_x-1.4,-1.2],[22.0,-1.2]]);
}
module sl_spring_closed() {
    // Root overlap below Z5; X is the intended bending/withdrawal direction.
    sl_closed_box(22.0,-3.6,4.7,1.6,1.6,12.6);
    // Concave R1.2 root transitions in the intended bending plane.
    translate([0,-2.0,0]) rotate([90,0,0]) linear_extrude(1.6)
        polygon(concat([[20.8,4.7],[24.8,4.7]],
            [for(a=[270:-5:180]) [24.8+1.2*cos(a),6.2+1.2*sin(a)]],
            [for(a=[0:-5:-90]) [20.8+1.2*cos(a),6.2+1.2*sin(a)]]));
    // A 1.2 mm gap on its right gives access for a sideways finger push.
    sl_closed_box(21.0,-3.6,10.5,3.0,2.4,4.5);
    sl_latch_head_closed();
}
module sl_net_pin_closed(x) {
    translate([x,-0.62,7.2]) rotate([-90,0,0]) {
        cylinder(d=2.8,h=3.92,$fn=48);
        translate([0,0,3.92-eps]) cylinder(d1=2.8,d2=2.2,h=0.3+eps,$fn=48);
    }
    sl_closed_box(x-1.8,-0.62,5.4,3.6,0.37,3.6);
}
module sl_pin_pocket(x) {
    translate([x,4.1,0]) rotate([90,0,0]) linear_extrude(4.1+eps)
        polygon([[-1.9,5.3],[1.9,5.3],[1.9,10.1],[0,12],[-1.9,10.1]]);
}
module sl_net_lane_cut(end_x=33.52) {
    // A continuous, top-open passage behind the latch, open at both X ends.
    // Half the R6 depth; net rises from the pins into this shallow passage.
    sl_prism_x(23.5,end_x-23.5,[[net_lane_front,lane_floor_front],
        [net_lane_back,lane_floor_back],
        [net_lane_back,20.6],[net_lane_back+0.4,21.0],
        [net_lane_back+0.4,22.0],[net_lane_front-0.4,22.0],
        [net_lane_front-0.4,21.0],[net_lane_front,20.6]]);
}
module sl_guide_edge_reliefs(include_far=true) {
    // Widen the inlet in plan while its floor rises from Z10 to Z12.6.
    // The right pin pocket ends at X18.9; the lower frame stays connected.
    intersection() {
        translate([0,0,10]) linear_extrude(12)
            polygon([[20.5,1.8-eps],[23.5+eps,net_lane_back],
                     [23.5+eps,1.8-eps]]);
        sl_prism_y(-1,8,[[20.5,10],[23.52,12.61734],
            [23.52,22],[20.5,22]]);
    }
    // The entering mesh sees a ramp toward the wide lane, not a square ledge.
    translate([0,0,lane_floor_front]) linear_extrude(22-lane_floor_front)
        polygon([[23.5-eps,net_lane_front+eps],
                 [24.1,net_lane_front+eps],[23.5-eps,1.8]]);
    // Ease both lips at the open far end of the net passage.
    if(include_far) translate([0,0,lane_floor_back]) linear_extrude(22-lane_floor_back) {
        polygon([[33.1,net_lane_front+eps],[33.5+eps,net_lane_front+eps],
                 [33.5+eps,net_lane_front-0.4]]);
        polygon([[33.1,net_lane_back-eps],[33.5+eps,net_lane_back-eps],
                 [33.5+eps,net_lane_back+0.4]]);
    }
}
module sl_receiver_closed(handle=false) {
    difference() {
        intersection() {
          union() {
            // R5 retaining lip, insertion ramp clearance and 45-degree brace.
            sl_prism_x(27.0,6.5,[[0,0],[6,0],[6,21],[-5.2,21],[-5.2,7.2],[0,2.0]]);
            // Fixed overlap shields the moving-cover seam from the net side.
            // Its underside grows outward at 45 degrees from the frame.
            sl_prism_x(23.5,3.52,[[1.8,2.4],[6,2.4],[6,21],[1.2,21],[1.2,3.0]]);
          }
          sl_top_envelope_closed(12,27);
        }
        // Blind outer end: keep 1.2 mm of solid wall at X32.3..33.5.
        sl_closed_box(26.9,-3.95,14.6,5.4,3.25,4.7);
        sl_net_lane_cut(handle ? 28.6 : 33.52);
        sl_guide_edge_reliefs(!handle);
    }
}
module sl_rigid_additions_print() {
    sl_closed_to_print() {
        for(x=net_pin_x) sl_net_pin_closed(x);
    }
}

// Return the raised keeper to the ordinary frame on its center-facing side.
// Height and hand-side projection both taper, so there is no terminal ledge.
module sl_far_frame_blend(length=10) {
    if(length>0) intersection() {
        sl_prism_x(33.5-eps,length+eps,
            [[0,0],[6,0],[6,21],[-5.2,21],[-5.2,7.2],[0,2]]);
        sl_prism_y(-6,13,concat([[33.5-eps,0],[33.5+length,0]],
            [for(i=[32:-1:0]) [33.5+length*i/32,
                21-7*sl_smooth01(i/32)]],[[33.5-eps,21]]));
        linear_extrude(22) polygon(concat(
            [[33.5-eps,6],[33.5+length,6]],
            [for(i=[32:-1:0]) [33.5+length*i/32,
                -5.2*(1-sl_smooth01(i/32))]],[[33.5-eps,-5.2]]));
    }
}
module sl_far_net_exit(length=10) {
    // Lift the groove floor above the continuous Z14 ring at its far end.
    // Simply adding a shoulder would close the coupon's formerly open end.
    if(length>0) {
        n=32;
        points=[for(i=[0:n]) each let(t=i/n,s=sl_smooth01(t),x=33.5+length*t)
            [[x,net_lane_front,lane_floor_front+(14.2-lane_floor_front)*s],
             [x,net_lane_back,lane_floor_back+(14.2-lane_floor_back)*s],
             [x,net_lane_back,25],[x,net_lane_front,25]]];
        faces=concat([[0,3,2],[0,2,1]],
            [for(i=[0:n-1],j=[0:3]) each let(k=(j+1)%4)
                [[4*i+j,4*i+k,4*(i+1)+k],
                 [4*i+j,4*(i+1)+k,4*(i+1)+j]]],
            [[4*n,4*n+1,4*n+2],[4*n,4*n+2,4*n+3]]);
        polyhedron(points=points,faces=faces,convexity=6);
    }
}
module side_latch_frame_additions(far_length=10,handle=false) {
    sl_receiver_closed(handle);
    sl_frame_height_blend();
    sl_far_frame_blend(far_length);
    if(handle) side_latch_corner_land();
}
module side_latch_corner_land() {
    // Restore the outer pin's R7 datum where the handle-side corner recedes.
    // Only a 6 mm land is flat; its ends merge into the existing rounded rim.
    linear_extrude(14) polygon(concat([[-22,6],[-12,6]],
        [for(i=[16:-1:0]) [-14+2*i/16,6*sl_smooth01(i/16)]],
        [[-20,0]],
        [for(i=[1:16]) [-20-2*i/16,6*sl_smooth01(i/16)]]));
}
module side_latch_frame_cuts(far_length=10,handle=false) {
    sl_closed_box(14.0,-eps,3.0,13.0,1.8+eps,19.0);
    for(x=net_pin_x) sl_pin_pocket(x);
    sl_net_lane_cut(handle ? 28.6 : 33.52);
    sl_guide_edge_reliefs(!handle);
    if(handle) {
        // Turn the net toward the ball side before the unmodified handle mount.
        // The front separator and the functional tooth window remain intact.
        sl_closed_box(26.2,net_lane_front,14.2,2.4,16.8-net_lane_front,8);
    } else sl_far_net_exit(far_length);
}
// Three first-layer ties keep the spring and its narrow housing together.
// Break individually from the exposed bed/hand face before operating the latch.
// No exterior pads; designed to leave short broken ends attached to the parts.
module sl_spring_bed_tie_print() {
    // Existing middle tie: thumb pad to side rail, 1.2 mm free span.
    translate([23.8,-13.6,0]) cube([1.6,0.50,0.20]);
    // Upper tie: latch head to top rail, 1.2 mm free span.
    translate([22.55,-20.6,0]) cube([0.50,1.6,0.20]);
    // Lower tie: spring stem to side rail, 1.6 mm free span.
    translate([23.4,-9.25,0]) cube([2.0,0.50,0.20]);
}

module side_latch_print_parts() {
    sl_spring_bed_tie_print();
    sl_rigid_body_print();
    sl_rigid_additions_print();
    sl_closed_to_print() sl_spring_closed();
}
