#!/usr/bin/perl
use warnings;
use strict;
use Font::FreeType;
use charnames ();

# LIMITATIONS: No support for right-to-left characters.

my $face = Font::FreeType->new->face('/usr/share/fonts/truetype/msttcorefonts/arial.ttf');
# In points.
my $nominal_size = 8;
# In DPI.
my $nominal_res = 254;

my $PI = 2*atan2(1,0);

$face->set_char_size($nominal_size, $nominal_size, $nominal_res, $nominal_res);

$face->foreach_char(sub {
                      my $glyph = $_;
                      
                      printf "// U+%x -- %s\n", $glyph->char_code, charnames::viacode($glyph->char_code) || $glyph->name;

                      # This origin to next origin, always positive.  FIXME: This is what breaks right-to-left.
                      printf "// Horizontal advance: %d\n", $glyph->horizontal_advance;

                      my $module_name = charnames::viacode($glyph->char_code) || $glyph->name;
                      $module_name =~ s/ /_/g;
                      $module_name =~ s/-/_/g;
                      print "module $module_name(stroke_width) {\n";

                      $glyph->outline_decompose(
                                                move_to => \&move_to,
                                                line_to => \&line_to,
                                                cubic_to => \&cubic_to,
                                               );
                      print " translate([", $glyph->horizontal_advance, ", 0, 0]) child(0);\n";
                      print "}\n\n";
});

my ($last_x, $last_y);

sub move_to {
  my ($x, $y) = @_;
  # print " // move_to $x, $y\n";
  ($last_x, $last_y) = ($x, $y);
}

sub line_to {
  my ($x, $y) = @_;
  print "  // line ($last_x, $last_y) - ($x, $y)\n";
  my ($delta_x) = $x - $last_x;
  my ($delta_y) = $y - $last_y;
  print "  // delta ($delta_x, $delta_y)\n";
  my $angle = atan2($delta_y, $delta_x) * 360/(2*$PI);
  print "  // angle $angle\n";
  my $length = sqrt($delta_x**2 + $delta_y**2);
  print "  // length $length\n";
  
  my $stroke = "translate([-$length, -stroke_width]) square([$length, stroke_width])";
  print "  translate([$x, $y]) rotate(v=[0,0,1], a=$angle) $stroke;\n";
  
  ($last_x, $last_y) = ($x, $y);
}

sub cubic_to {
  my ($destx, $desty, $c1x, $c1y, $c2x, $c2y) = @_;
  print "// cubic_to ($destx, $desty) control 1 ($c1x, $c1y) control 2 ($c2x, $c2y)\n";
  line_to($destx, $desty);
  
  ($last_x, $last_y) = ($destx, $desty);
}
