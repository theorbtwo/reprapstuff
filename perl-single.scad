include <impact.scad>

$fa = 0.1;
$fs = 1;

top_height = 1.4;
centre_height = 2.1;
bottom_height = 0;

full_height = top_height+centre_height+bottom_height;

rim_width = 2.5;

coin_dia = 34;
logo_scale = 3.5;

difference () {
 perl();

 difference () {
  cylinder(h=full_height, r=coin_dia/2+1);
  translate([0, 0, -0.5])
   cylinder(h=full_height+1, r=coin_dia/5+3);
 }
}

/* The outside rim */
difference () {
 cylinder(h=full_height, r=coin_dia/2);
 translate([0, 0, -0.5])
  cylinder(h=full_height+1, r2=coin_dia/2-rim_width, r1=coin_dia/2-rim_width*2);
}

cylinder(h=centre_height, r = coin_dia/2, center = true);


rotate(a=90, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-11/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     LATIN_CAPITAL_LETTER_L();

rotate(a=65, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-14/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     LATIN_CAPITAL_LETTER_P();

rotate(a=35, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-22/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     LATIN_CAPITAL_LETTER_W();

rotate(a=-30, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-14/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     DIGIT_TWO();

rotate(a=-50, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-15/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     DIGIT_ZERO();

rotate(a=-70, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-11/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     DIGIT_ONE();

rotate(a=-90, v=[0, 0, 1])
 translate([0, coin_dia/4-3, 0])
  scale([0.3, 0.3, 1])
   translate([-15/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     DIGIT_ZERO();

//rotate(a=0, v=[0, 0, 1])
 translate([0, -coin_dia/2+1, 0])
  scale([0.3, 0.3, 1])
   translate([-14/2, coin_dia/5, 0])
    linear_extrude(height=top_height+centre_height)
     LATIN_SMALL_LETTER_B();


module perl() {
 difference() {
  translate([0,0,top_height-bottom_height])
   cylinder(h=top_height+centre_height+bottom_height, r=coin_dia/2, center=true);
  
  scale([logo_scale, logo_scale, 1])
   translate(v=[-5.895257/2, -5.895257/2, 0])
    linear_extrude(file = "Perl_Foundation.dxf", height=20, center=true, convexity=10);
 }
}
