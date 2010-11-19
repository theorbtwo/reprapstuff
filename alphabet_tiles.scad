include <arial.scad>

// The raised space on the outside of a tile.
border_size = 1;
base_height = 1;

inner_size = 35;
shift_up = 7;
shift_right = 1;
font_scale = 1;
font_height = 1;

// The blank space between tiles.
blank_space = 1;

// Cyrillic capital A.
start_codepoint = 1040;
rows = 7;
cols = 7;

module tile(codepoint) {
 difference () {
  translate([-border_size, -border_size, -base_height])
   cube([border_size*2+inner_size, border_size*2+inner_size, base_height+font_height]);

  cube([inner_size,inner_size,font_height+0.1]);
 }


 translate([shift_right, shift_up, 0])
  linear_extrude(height=font_height)
   by_codepoint(codepoint);
}

for (x = [0:cols-1]) {
 for (y = [0:rows-1]) {
  translate([x * (inner_size + border_size*2 + blank_space),
             y * (inner_size + border_size*2 + blank_space),
             0])
   tile(start_codepoint + x + y*rows);
 }
}
