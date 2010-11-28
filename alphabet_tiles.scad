include <freesans.scad>
 
// The raised space on the outside of a tile.
border_size = 1;
base_height = 1;

inner_size = 17.5;
shift_up = 2;
shift_right = 1;
font_scale = 0.5;
font_height = 2;

// The blank space between tiles.
blank_space = 3;

codepoint_shift_right = 13;
codepoint_shift_up = 15.5;
codepoint_scale = 0.2;
codepoint_digits = 4;

// 913: GREEK_CAPITAL_LETTER_ALPHA
// 12450: 'A' kana.
start_codepoint = 913;
rows = 5;
cols = 5;

module tile(codepoint) {
 difference () {
  translate([-border_size, -border_size, -base_height])
   cube([border_size*2+inner_size, border_size*2+inner_size, base_height+font_height]);

  cube([inner_size,inner_size,font_height+0.1]);
 }


 translate([shift_right, shift_up, 0])
  linear_extrude(height=font_height)
    scale([font_scale, font_scale])
     by_codepoint(codepoint);

 translate([codepoint_shift_right, codepoint_shift_up, 0])
  rotate(a=-90, v=[0, 0, 1])
   linear_extrude(height=font_height)
    scale([codepoint_scale, codepoint_scale])
     hex_num(codepoint, codepoint_digits, 20);

}

module hex_num(n, n_digits, digit_width) {
  for (digit_n = [0:n_digits-1]) {
   translate([digit_width * (n_digits-digit_n-1), 0, 0])
    hex_digit(get_hex_digit(n, digit_n));
  }
}

function get_hex_digit(n, digit_num) =
  floor(n / pow(2, 4*digit_num)) % 16;

module hex_digit(n) {
  if (n < 10)
    by_codepoint(48 + n);
  else
    by_codepoint(97 + (n-10));
}

for (x = [0:cols-1]) {
 for (y = [0:rows-1]) {
  translate([x * (inner_size + border_size*2 + blank_space),
             y * (inner_size + border_size*2 + blank_space),
             0])
   tile(start_codepoint + x + y*rows);
 }
}
