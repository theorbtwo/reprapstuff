#!/usr/bin/perl
use warnings;
use strict;
use Font::FreeType;
use charnames ();
use Data::Dump::Streamer;

# LIMITATIONS:
#  - No support for right-to-left characters.

my $face = Font::FreeType->new->face(shift || '/usr/share/fonts/truetype/msttcorefonts/arial.ttf');
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
                      print "module $module_name() {\n";

                      my ($state) = {};

                      $glyph->outline_decompose(
                                                move_to => sub {move_to($state, @_)},
                                                line_to => sub {line_to($state, @_)},
                                                cubic_to => sub {cubic_to($state, @_)},
                                               );

                      move_to($state, 0, 0);

                      # Dump $state;

                      if ($state->{paths}) {
                        print " polygon(points=[\n";
                        my $n = 0;
                        for my $point (sort {$state->{coded_points}{$a} <=> $state->{coded_points}{$b}} keys %{$state->{coded_points}}) {
                          print "   [$point], // $state->{coded_points}{$point}\n";
                          $n++;
                        }
                        print "  ],\n";
                        print "  paths = [\n";
                        for my $path (@{$state->{paths}}) {
                          print "   [", join(", ", @$path), "],\n";
                        }
                        print "  ]\n";
                        
                        print " );\n";
                      }

                      print " translate([", $glyph->horizontal_advance, ", 0, 0]) child(0);\n";
                      print "}\n\n";
});

sub assign_coded_point {
  my ($state, $x, $y) = @_;

  #print "//assign_coded_point(..., $x, $y)\n";
  my $str = "$x, $y";
  $state->{n_coded_points} //= 0;
  if (not exists $state->{coded_points}{$str}) {
    $state->{coded_points}{$str} = $state->{n_coded_points}++;
  }
  #print "//assign_coded_point(..., $x, $y) -> $state->{coded_points}{$str}\n";

  return $state->{coded_points}{$str};
}

sub move_to {
  my ($state, $x, $y) = @_;
  #print " // move_to ($x, $y)\n";

  if ($state->{current_path}) {
    push @{$state->{paths}}, $state->{current_path};
    $state->{current_path} = [];
  }

  $state->{current_pos} = assign_coded_point($state, $x, $y);
}

sub line_to {
  my ($state, $x, $y) = @_;
  #print "  // line_to ($x, $y)\n";

  push @{$state->{current_path}}, assign_coded_point($state, $x, $y);

  $state->{current_pos} = assign_coded_point($state, $x, $y);
}

sub cubic_to {
  my ($state, $destx, $desty, $c1x, $c1y, $c2x, $c2y) = @_;
  # print "// cubic_to ($destx, $desty) control 1 ($c1x, $c1y) control 2 ($c2x, $c2y)\n";
  line_to($state, $destx, $desty);
}
