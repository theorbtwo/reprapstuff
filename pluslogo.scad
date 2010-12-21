full();

module full () {
 connector_dia = 4.9;
 hole_dia = 2;

 plus();

 $fn=20;

 difference () {
  rotate(a=90, v=[1, 0, 0])
   cylinder(r=connector_dia/2, h=30);

  translate([0, -(30-connector_dia/2), 0])
   rotate(a=90, v=[0, 1, 0])
    cylinder(h=connector_dia*2, r=hole_dia/2, center=true);
 }

 translate([-20, 0, 0])
  rotate(a=90, v=[0, 1, 0])
   cylinder(r=connector_dia/2, h=40);
}

/*

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

*/
 

module plus() {
 scale(1/24.8)
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