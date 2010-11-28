include <MCAD/shapes.scad>

tube_od = 8;
tube_id = 6;

// 608 bearings, 22 x 8 x 7
bearing_id = 8;
bearing_od = 22;
bearing_height = 7;

pump_dia = bearing_od * 3;

arm_height = tube_od * 1.1;

tube_thicknes = (tube_od - tube_id)/2;

tube_guide_width = 4;

draw_inside = false;
draw_outside = true;

// occlusion = 2*wall_thickness - g

/* even numbers of pinchers have the nice property that there are always the same number of
   pinches in the tube, given that we have 180 degrees of tubing active */
number_pinchers = 4;

% tube();

if (draw_inside) {
 rotate(a=$t*90, v=[0, 0, 1]) {
  translate([0, 0, -arm_height/2]) {
   difference() {
    union () {
     for (i=[0:number_pinchers-1]) {
      rotate(a=i*360/number_pinchers, v=[0, 0, 1])
       translate([0, -arm_height/2, 0])
        pinch_arm_assy(arm_height, pump_dia);
     }

     /* A bit of extra reinforcement around the axis */
     cylinder(r=8, h=arm_height);
    }
  
    // for attaching the screwdriver -- simply use a hex bit of this size (AF).  
    hexagon(4, 40);
   }
  }
 
  /* Tube gide, keeps the tube in place from the inside. */
  translate([0, 0, -arm_height/2]) {
   difference() {
    cylinder(r=(pump_dia-arm_height)/2, h=arm_height);
    translate([0, 0, -1])
     cylinder(r=(pump_dia-arm_height)/2-tube_guide_width, h=arm_height+2);
   }
  }
 }
}

if (draw_outside) {
 /* Tube gide, keeps the tube in place from the outside. */
 difference() {
  translate([0, 0, -arm_height/2]) {
   difference() {
    cylinder(r=(pump_dia+arm_height)/2+tube_guide_width, h=arm_height);
    translate([0, 0, -1])
     cylinder(r=(pump_dia+arm_height)/2, h=arm_height+2);
   }
  }
  tube();
 }
 
 /* covers, keeps everything nicely in place (hopefully) */
 translate([0, 0, -arm_height/2])
  cube([pump_dia+arm_height*2, pump_dia+arm_height*2, tube_guide_width], center=true);
 
 /*
 translate([0, 0, arm_height/2])
  cube([pump_dia+arm_height*2, pump_dia+arm_height*2, tube_guide_width], center=true);
 */
}

/*
 FIXME: Why doesn't this work?
rotate_extrude(convexity = 10)
 translate([-(pump_dia/2-arm_height/2), 0, 0])
  rotate(a=90, v=[0, 0, 0])
   // NB: square() creates a sqare in the x-y plane, we want it in the y-z plane.
   square([tube_guide_width, arm_height]);
*/

module pinch_arm_assy(height, pump_dia) {
 arm_width = height;
 arm_height = height;
 arm_length = pump_dia/2-height/2;

 union() {
  cube([arm_length, arm_width, arm_height]);
  translate([arm_length, arm_width/2, 0]) 
   cylinder(r=arm_width/2, arm_height);
 }
}

module tube() {
 union() {
  difference() {
   torus(tube_od/2, pump_dia/2);
   translate([0, -pump_dia/2-tube_od/2, -tube_od/2])
    cube([pump_dia/2+tube_od, pump_dia+tube_od, tube_od]);
  }

  translate([0, pump_dia/2, 0])
   rotate(a=90, v=[0,1,0])
    cylinder(r=tube_od/2, h=pump_dia);

  translate([0, -pump_dia/2, 0])
   rotate(a=90, v=[0,1,0])
    cylinder(r=tube_od/2, h=pump_dia);
 }
}

module bearing(id, od, height) {
  difference() {
    cylinder(r=od/2, h=height);
    translate([0, 0, -0.05])
     cylinder(r=id/2, h=height+0.1);
  }
}

module torus(small, big) {
 rotate_extrude(convexity=10) {
  translate([big, 0, 0]) {
   circle(r=small);
  }
 }
}
