include <impact.scad>
$fa = 1;
$fs = 0.125;

// Location where the sundial will be placed, tz it should read out in.
latitude = 51.5844;
longitude = -1.7415;
timezone = 0;

// The flat portion of the disk
base_height = 1;
base_dia = 80;

// The style, the bit that points upward.
style_dia = 4;

// Markings on the disk
hour_mark_dia = 4;
half_hour_mark_dia = 2;
number_height = 3;
number_shift = hour_mark_dia/2;

// http://en.wikipedia.org/wiki/Sundial#Horizontal_sundials

// The base.
translate([0, 0, -base_height])
 cylinder(h=base_height, r=base_dia/2);

// The style, flat at latitude=0 (equator), straight up at the poles.
intersection () {
 union() {
  rotate(a=latitude, v=[1, 0, 0])
   rotate(a=-90, v=[1,0,0])
    translate([0, 0, -base_height])
     cylinder(r1=style_dia/2, r2=style_dia/2, h=base_dia/2);


  // Hour lines (and labels)
  for (hour = [3:20]) {
   echo("hour: ", hour);
   echo("<6: ", hour <= 6);

   rotate(a=time_angle(hour), v=[0,0,1]) {
    rotate(a=-90, v=[1,0,0])
     cylinder(r1=0, r2=hour_mark_dia/2, h=base_dia/2);
    
    translate([number_shift, base_dia/2-3, 0])
     scale([0.1, 0.1, number_height])
      linear_extrude(height=1, convexity=10)
       number(hour);
   }
  }

  // Half-hour lines.
  for (hour = [3:20]) {
   rotate(a=time_angle(hour+0.5), v=[0,0,1]) {

    translate([0, base_dia/2-15, 0])
     rotate(a=-90, v=[1,0,0])
      cylinder(r1=0, r2=half_hour_mark_dia/2, h=10);
   }
  }
 }

 // Keeps the style from poking out the bottom.  Commented out because openscad won't render correctly on displays without opengl 2.0.
 cylinder(r=base_dia/2, h=1000);
}


function time_angle(hour) =
           hour <= 6  ? (-atan(sin(latitude) * tan(15*(hour+timezone)+longitude))-180) :
           hour <= 18 ? (-atan(sin(latitude) * tan(15*(hour+timezone)+longitude))) :
                        (-atan(sin(latitude) * tan(15*(hour+timezone)+longitude))+180);

module number(n) {
  if (n == 0) {
    DIGIT_ZERO();
  } else if (n == 1) {
    DIGIT_ONE();
  } else if (n == 2) {
    DIGIT_TWO();
  } else if (n == 3) {
    DIGIT_THREE();
  } else if (n == 4) {
    DIGIT_FOUR();
  } else if (n == 5) {
    DIGIT_FIVE();
  } else if (n == 6) {
    DIGIT_SIX();
  } else if (n == 7) {
    DIGIT_SEVEN();
  } else if (n == 8) {
    DIGIT_EIGHT();
  } else if (n == 9) {
    DIGIT_NINE();
  } else if (n == 10) {
    DIGIT_ONE() DIGIT_ZERO();
  } else if (n == 11) {
    DIGIT_ONE() DIGIT_ONE();
  } else if (n == 12) {
    DIGIT_ONE() DIGIT_TWO();
  } else if (n == 13) {
    DIGIT_ONE() DIGIT_THREE();
  } else if (n == 14) {
    DIGIT_ONE() DIGIT_FOUR();
  } else if (n == 15) {
    DIGIT_ONE() DIGIT_FIVE();
  } else if (n == 16) {
    DIGIT_ONE() DIGIT_SIX();
  } else if (n == 17) {
    DIGIT_ONE() DIGIT_SEVEN();
  } else if (n == 18) {
    DIGIT_ONE() DIGIT_EIGHT();
  } else if (n == 19) {
    DIGIT_ONE() DIGIT_NINE();
  } else if (n == 20) {
    DIGIT_TWO() DIGIT_ZERO();
  } else if (n == 21) {
    DIGIT_TWO() DIGIT_ONE();
  } else if (n == 22) {
    DIGIT_TWO() DIGIT_TWO();
  } else if (n == 23) {
    DIGIT_TWO() DIGIT_THREE();
  } else {
    echo("FIXME: number(", n, ")");
    LATIN_CAPITAL_LETTER_X();
  }
}

module co_number(n) {
  number(n);
}

module string(str) {
  echo(str);
}