include <MCAD/shapes.scad>

tube_od = 8;
tube_id = 6;

// Yet to do: Make casing, which holds the tube & motor in place.
// Top part, which holds the beaings in -- complement of barbs, holds tubing down.

// 608 bearings, 22 x 8 x 7
bearing_id = 8;
bearing_od = 22;
bearing_height = 7;

pump_dia = bearing_od * 3;

number_pinchers = 3;

difference() {
 for (i=[0:number_pinchers-1]) {
  rotate(a=i*360/number_pinchers, v=[0, 0, 1])
   pinch_arm_assy(bearing_id, bearing_od, bearing_height, pump_dia);
 }

 hexagon(4, 40);
}

module pinch_arm_assy(id, od, height, pump_dia) {
 support_width = id;
 support_height = id;

 // FIXME: Place the bearing based on wall thickness of tube? 
 translate([pump_dia/2-bearing_od/2, 0, -bearing_height/2])
  union() {
   % bearing(bearing_id, bearing_od, bearing_height);
   bearing_hook(bearing_id, bearing_od, bearing_height);
   translate([-(pump_dia/2-bearing_od/2), -support_width/2, -support_height])
    cube([pump_dia/2-bearing_od/2, support_width, support_height]);

   translate([1, 0, -support_height])
    cylinder(h=support_height, r=support_width/2);
  }
}

module bearing_hook(id, od, height) {
 barb_margin = 2.5;
 barb_dia = id+barb_margin;
 barb_r   = barb_dia/2;

 echo("Barb margin: ", barb_margin);
 echo("Barb tall bit width: ", (id-barb_margin)/2);
 echo("Barb margin too big: ", barb_margin > id ? "yes" : "no");
 
 difference() {
  union() {
   cylinder(r=id/2, h=height);

   translate([0, 0, height])
    cylinder(r1=barb_r, r2=0, h=barb_r);
  } 

  translate([-(id+barb_margin+1), -barb_margin/2, -1])
   cube([2*(id+barb_margin+1), barb_margin, height+id+barb_margin+2]);
 
  rotate(a=90, v=[0, 0, 1])
   translate([-(id+barb_margin+1), -barb_margin/2, -1])
    cube([2*(id+barb_margin+1), barb_margin, height+id+barb_margin+2]);
 }
}

% union() {
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
