connector_dia = 124.33/3;

// Note that this is in real mm, not jumbo mm.
support_r = 1;
support_step = 15;

// support(-21, 21, -21, 22, -18, 25);
// support(-20, 21, -5, 5, -18, 25);
// support(-5, 5, -20, 21, -18, 25);

// under central +.
translate([2, 2, -20]) cylinder(h=20, r=support_r);

// under brackets
translate([-20, 4, -18]) cylinder(h=8, r=support_r);
translate([20, 4,  -18]) cylinder(h=8, r=support_r);
translate([4, 20,  -18]) cylinder(h=8, r=support_r);
translate([2, -20, -18]) cylinder(h=8, r=support_r);

rotate(a=14.108, v=[1, 0, 0])
rotate(a=-14.108, v=[0, 1, 0]) {
 rotate(a=90, v=[1, 0, 0]) {

  scale([1/24.8, 1/24.8, 1/24.8]) {
   plus();
   rotate(a=90, v=[0, 1, 0]) plus();

   cylinder(r=connector_dia, h=1000, center=true);
   rotate(a=90, v=[0, 1, 0])
    cylinder(r=connector_dia, h=1000, center=true);

   rotate(a=-90, v=[1, 0, 0])
    cylinder(r=connector_dia, h=500, center=false);

   translate([0, 500+connector_dia*5/4, 0])
    torus(connector_dia, connector_dia*2);
  }
 }
}
 
module support(minx, maxx, miny, maxy, minz, maxz) {
 for (xi = [0 : ((maxx-minx)/support_step)]) {
  for (yi = [0 : ((maxy-miny)/support_step)]) {
   assign(x = xi*support_step+minx, y = yi*support_step+miny)
    translate([x, y, minz])
     cylinder(h = maxz-minz, r = support_r);
  }
 }
}


module plus() {
 translate([-875, 812.5, 0])
  linear_extrude(file = "pluslogo.dxf", height=124.33, center=true);
}

module torus(small, big) {
 rotate_extrude(convexity=10) {
  translate([big, 0, 0]) {
   circle(r=small);
  }
 }
}