slot_length=50;
slot_height=30;

module coin_slot(nominal_dia) {
  dia = nominal_dia + 1;
  full_width = dia+2;
  
  extra_height = slot_height-dia;

  rotate(a=-90, v=[0, 1, 0]) {

    difference() {
      translate([-(full_width+extra_height)/2-1.01, -full_width/2, -1])
        cube([full_width+extra_height, full_width, slot_length-0.01]);

      cylinder(r=dia/2, h=slot_length);
      translate([0, -dia/2, 0])
        cube([slot_height/2, dia, slot_length]);
    }
  }
}

// 1p
coin_slot(20.32);


// 2p
/* FIXME: Make this formula in the center make more sense */
translate([0, 20.32+5, 0])
 coin_slot(25.9);

// 5p
translate([0, 20.32+5+25.9-2, 0])
 coin_slot(18);

// 10p
translate([0, 20.32+5+25.9-2+18+5, 0])
 coin_slot(24.5);


