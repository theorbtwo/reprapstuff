// The smallest size of feature we can rely on to not crack.
wall_width = 2.5;

bolt_dia = 6;

// the dia of the bit of the pen that we try to grip.
pen_holder_bottom_id = 8.5;
pen_holder_bottom_od = pen_holder_bottom_id;
// the entire bit that is this dia, plus the actual tip
pen_height = 25;

feedstock_dia = 3;
// How much extra space all around the feedstock fill line?
feedstock_fudge = 0.2;
feedstock_holder_width = max(feedstock_dia+feedstock_fudge*2, pen_holder_bottom_od) + +wall_width*2;

rotate(a=180, v=[0, 1, 0])
 translate([0, feedstock_holder_width+wall_width*2, 0])
  marker_holder(true, false);

marker_holder(false, true);

make_feedstock_holder_top = true;
make_feedstock_holder_bottom = true;

module marker_holder(make_feedstock_holder_top, make_feedstock_holder_bottom) {
 rotate(a=180, v=[1, 0, 0])
 rotate(a=90, v=[0, 0, 1])
 difference () {
  union () {
   // feedstock holder proper
   cube([feedstock_holder_width, feedstock_holder_width, feedstock_holder_width], center=true);

   // Wings to bolt together.
   cube([feedstock_holder_width, feedstock_holder_width+bolt_dia*2+wall_width*4, wall_width*2], center=true);

   // additional height for the marker holder.
   translate([0, 0, pen_height/2])
    cube([feedstock_holder_width, feedstock_holder_width, pen_height], center=true);
  }

  // hole for feedstock
  # translate([-feedstock_holder_width*2, 0, 0])
   rotate(a=90, v=[0, 1, 0])
    cylinder(r=feedstock_dia/2+feedstock_fudge, h=feedstock_holder_width*4);

  // hole for +y bolt
  translate([0, feedstock_holder_width/2 + bolt_dia/2 + wall_width, -feedstock_holder_width])
   cylinder(r=bolt_dia/2, h=feedstock_holder_width*2);

  // hole for -y bolt
  translate([0, -(feedstock_holder_width/2 + bolt_dia/2 + wall_width), -feedstock_holder_width])
   cylinder(r=bolt_dia/2, h=feedstock_holder_width*2);

  // hole for the marker holder
  cylinder(r=pen_holder_bottom_od/2, h=30);

  // bolt for holding in the marker. (should be along x, so we can place several in close vicinity.
  translate([0, 0, pen_height/2])
   rotate(a=90, v=[1, 0, 0])
    cylinder(r=bolt_dia/2, h=30);

  // I hear that adding a very thin cut on the edge of holes can make skeinforge string across them less.
  translate([-40, 0, 0])
   cube([80, 0.01, 80], center=true);

  if (!make_feedstock_holder_top) {
   translate([0, 0, 40])
    cube([80, 80, 80], center=true);
  }

  if (!make_feedstock_holder_bottom) {
   translate([0, 0, -40])
    cube([80, 80, 80], center=true);
  }
 }
}
