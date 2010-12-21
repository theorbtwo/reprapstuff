inner_height = 25;
spindle_dia = 12;
walls_dia = 30;
walls_height = 5;
tie_hole_dia = 3;
bevel_height = 6;
shaft_dia = 6.35;
shaft_flat_dia = 5.8;
shaft_height = 17.2;


difference () {
 spindle();
 translate([0, (spindle_dia+2)/2, inner_height/2])
  rotate(a=90, v=[1, 0, 0])
   cylinder(h=spindle_dia+2, r=tie_hole_dia/2, $fn=20);

 translate([0, 0, inner_height+walls_height-shaft_height+0.01])
  d_shaft(shaft_dia, shaft_flat_dia, shaft_height);
}

module d_shaft(d, flat_d, h) {
 difference() {
  cylinder($fn=25, h=h, r=d/2);
  translate([d/2-(d-flat_d), -(d+2)/2, -1])
   cube([d, d+2, h+2]);
 }
}

module spindle() {
 cylinder(r1=walls_dia/2, r2=spindle_dia/2, h=bevel_height);

 translate([0, 0, inner_height])
  rotate(a=180, v=[1, 0, 0])
   cylinder(r1=walls_dia/2, r2=spindle_dia/2, h=bevel_height);

 cylinder(h=inner_height, r=spindle_dia/2);
 
 translate([0, 0, -walls_height])
  cylinder(h=walls_height, r=walls_dia/2);
 
 translate([0, 0, inner_height])
  cylinder(h=walls_height, r=walls_dia/2);
}

