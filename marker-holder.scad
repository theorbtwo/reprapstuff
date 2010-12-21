use <MCAD/involute_gears.scad>

$fn = 16;

pen_dia = 11;
// the dia of the bit of the pen that we try to grip.
pen_height = 18;
pen_wall_width = 2.5;

feedstock_dia = 3;
// How much extra space all around the feedstock fill line?
feedstock_fudge = 0.2;

cylinder(r=feedstock_dia/2+feedstock_fudge, h=pen_dia+pen_wall_width*2+2);

translate([40, 0, 0])
 rotate(a=-90,  v=[0, 1, 0])
  marker_holder(pen_dia, pen_height, pen_wall_width);


/*
translate([-(pen_height+10)/2, -(pen_height+10)/2, 0])
 difference() {
  cube([pen_height+10, (pen_height+10), pen_height+pen_wall_width]);
  translate([0.5, 0.5, -0.5])
   cube([pen_height+10-1, (pen_height+10)-1, pen_height+pen_wall_width+2]);
 }
*/

/*
// Here as a sort of "lightning rod", so the threads don't go on the teeth side.
translate([0, -(pen_dia), 0])
 cylinder(r=2, h=pen_height+pen_wall_width);
*/

/*
pitch_dia = 40;
circular_pitch = 100;
number_of_teeth = ceil(pitch_dia * 180/circular_pitch);
echo("Number of teeth: ", number_of_teeth);
echo("Circular pitch: ", circular_pitch);
if(number_of_teeth > 5) {
 gear(number_of_teeth=number_of_teeth, circular_pitch=circular_pitch, circles=0);
}
*/

// the pen's axis goes along the z axis.
module marker_holder(pen_dia, pen_height, pen_wall_width) {

 difference() {
  translate([0, 0, pen_height/2])
   cube([pen_dia+pen_wall_width*2, pen_dia+pen_wall_width*2, pen_height], center=true);
  // cylinder(r=pen_dia/2+pen_wall_width, h=pen_height);
  translate([0, 0, -0.5])
   cylinder(r=pen_dia/2, h=pen_height+1);
 }
 translate([pen_dia/2, -(pen_dia+pen_wall_width*2)/2, 0])
  cube([pen_wall_width, pen_dia+pen_wall_width*2, pen_height]);


 // (By experiment)
 // number_of_teeth = 72, circular_pitch = 100 --->
 //involute_gear_tooth(pitch_radius=20, root_radius=19.2444, base_radius=17.659, outer_radius=20.5556, half_thick_angle=1.25, involute_facets=0);

 gear_tooth_step = 2;

 intersection() {
  for(i=[0:ceil(pen_height/gear_tooth_step)])
   translate([-20.5556+pen_dia/2+pen_wall_width+2, (pen_dia+pen_wall_width*2)/2, (i+0.5)*gear_tooth_step])
    rotate(v=[1, 0, 0], a=90)
     linear_extrude(height = pen_dia+pen_wall_width*2)
      involute_gear_tooth(pitch_radius=20, root_radius=19.2444, base_radius=17.659, outer_radius=20.5556, half_thick_angle=1.25, involute_facets=0);
 
  translate([pen_dia/2, -(pen_dia+pen_wall_width*2)/2, 0])
   cube([pen_wall_width*20, pen_dia+pen_wall_width*2, pen_height]);
 }
}


// http://www.woodenworksclocks.com/Design.htm
// must specify either diametric pitch or circular pitch
// diametric pitch: # of teeth per inch of pitch diameter.
// size of each tooth goes up as diametric pitch goes up,
// 10 recommended for wooden clocks.
// circular pitch: 180 / diametric pitch
// pitch diameter: number of teeth * circular_pitch / 180
// pressure angle: 14.5 recommended for wood gears?
// 
// gear();