#!/usr/bin/perl
use warnings;
use strict;

# Speeds, in mm/min.  (1mm/sec = 60 mm/min)
# up/down movements.
my $speed_z = 1*60;
# x/y, with pen up.
my $speed_move = 32*60;
# x/y, with pen down.
my $speed_draw = 21*60;

# Heights, in mm, for moving and drawing.
# 3mm to high.
my $move_height = 0.5;
my $draw_height = 0;

# The resolution used, straight out of the eagle.def file, in dots/inch.
my $ResX=254000;
# The value to multiply a value from the file by to get a value in mm.
my $unit_convert = 25.4/$ResX;

my $pen_down = '0';
my $cur_speed = 0;

# Zero X & Y at the move speed, but Z at the Z speed.  Also, zero Z last, so we don't
# draw while zeroing.
print "G0 F$speed_move\n";
print "G28 X0 Y0\n";
print "G0 F$speed_z\n";
print "G28 Z0\n";
# Tell it that the current location is zero.
print "G92 X0 Y0 Z0\n";

# Absolute positioning, in mm.
print "G21\nG90\n";

while (<>) {
  chomp;
  s/\x0D//g;

  if (m/^pen (\d+)$/) {
    print "( switch to pen $1 )\n";
  } elsif (m/^move (\d+), (\d+)$/) {
    my ($x, $y) = map {$_*$unit_convert} ($1, $2);
    
    if ($pen_down == 0) {
      # Move while pen up.
      if ($cur_speed != $speed_move) {
        print "G1 F$speed_move\n";
        $cur_speed = $speed_move;
      }
      print "G1 X$x Y$y Z$move_height\n";
    } else {
      # Drawing while pen down.
      # Move while pen up.
      if ($cur_speed != $speed_draw) {
        print "G1 F$speed_draw\n";
        $cur_speed = $speed_draw;
      }
      print "G1 X$x Y$y Z$draw_height\n";
    }
  } elsif (m/^pen-down$/) {
    if ($cur_speed != $speed_z) {
      print "G1 F$speed_z\n";
      $cur_speed = $speed_z;
    }
    print "G1 Z$draw_height\n";
    $pen_down = 1;
  } elsif (m/^pen-up$/) {
    if ($cur_speed != $speed_z) {
      print "G1 F$speed_z\n";
      $cur_speed = $speed_z;
    }
    print "G1 Z$move_height\n";
    $pen_down = 0;
  } else {
    die "Don't know how to translate intermediate code $_";
  }
}

print "G1 F$speed_z\n";
print "G1 Z25\n";

