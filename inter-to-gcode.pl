#!/usr/bin/perl
use warnings;
use strict;

# Speeds, in mm/min.  (1mm/sec = 60 mm/min)
# up/down movements.
# 240 seems to be too high -- seemed to be going OK, but the final Z move didn't actually move at all.
my $speed_z = 200;
# x/y, with pen up.
my $speed_move = 32*60;
# x/y, with pen down.
my $speed_draw = 21*60;

# Heights, in mm, for moving and drawing.
# 3mm too high.  0.5 not high enough.
my $move_height = 1.75;
my $draw_height = 0;

# The resolution used, straight out of the eagle.def file, in dots/inch.
my $ResX=254000;
# The value to multiply a value from the file by to get a value in mm.
my $unit_convert = 25.4/$ResX;
# The minimum distance we should move -- moves smaller then this amount are ignored -- in mm.
my $min_move = 0.05;

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

my $state = {x => 0,
             y => 0,
             speed => $speed_z,
             total_time => 0,
             last_reported_time => 0,
             pen_down => 1,
            };

while (<>) {
  chomp;
  s/\x0D//g;

  if (m/^pen (\d+)$/) {
    print "( switch to pen $1 )\n";
  } elsif (m/^move (\d+), (\d+)$/) {
    my ($x, $y) = map {$_*$unit_convert} ($1, $2);
    
    if ($state->{pen_down} == 0) {
      do_move($state, $x, $y, $speed_move);
    } else {
      do_move($state, $x, $y, $speed_draw);
    }
  } elsif (m/^pen-down$/) {
    if ($state->{speed} != $speed_z) {
      print "G1 F$speed_z\n";
      $state->{speed} = $speed_z;
    }
    print "G1 Z$draw_height\n";
    $state->{pen_down}=1;
  } elsif (m/^pen-up$/) {
    if ($state->{speed} != $speed_z) {
      print "G1 F$speed_z\n";
      $state->{speed} = $speed_z;
    }
    print "G1 Z$move_height\n";
    $state->{pen_down} = 0;
  } else {
    die "Don't know how to translate intermediate code $_";
  }
}

warn "Total time estimate: $state->{total_time}";

print "G1 F$speed_z\n";
print "G1 Z50\n";

sub do_move {
  my ($state, $x, $y, $speed) = @_;

  # Distance in mm.
  my $dist = (($state->{x} - $x)**2 + ($state->{y} - $y)**2) ** 0.5;

  #print "($dist mm)\n";

  if ($dist < $min_move) {
    #print "( Ignoring short move ($dist mm)";
    return;
  }

  # Time in minutes
  my $time = $dist / $speed;
  $state->{total_time} += $time;
  if ($state->{total_time} > $state->{last_reported_time} + 1) {
    print "($state->{total_time} minutes)\n";
    $state->{last_reported_time} = $state->{total_time};
  }

  if ($state->{speed} != $speed) {
    print "G1 F$speed\n";
    $state->{speed} = $speed;
  }
  print "G1 X$x Y$y\n";
  $state->{x} = $x;
  $state->{y} = $y;
}
