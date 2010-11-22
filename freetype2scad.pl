#!/usr/bin/perl
use warnings;
use strict;
use Font::FreeType;
use Math::Bezier;
use charnames ();
use Data::Dump::Streamer;
use POSIX 'ceil';

binmode \*STDOUT, ":utf8";

# LIMITATIONS:
#  - No support for right-to-left characters or combining chars.

my $face = Font::FreeType->new->face(shift || '/usr/share/fonts/truetype/msttcorefonts/arial.ttf');
# In points.
my $nominal_size = 8;
# In DPI.
my $nominal_res = 254;

print "// ", $face->family_name, " ", $face->style_name, "\n";
print "\n";

my $PI = 2*atan2(1,0);

$face->set_char_size($nominal_size, $nominal_size, $nominal_res, $nominal_res);
my @glyphs;

$face->foreach_char( sub {
                       push @glyphs, $_;
                     } );

print "module by_codepoint(codepoint) {\n";
print by_codepoint_generator(0, $#glyphs, 1), "\n";
print "}\n\n";

#print "module by_char(codepoint) {\n";
#print by_char_generator(0, $#glyphs, 1), "\n";
#print "}\n\n";

$face->foreach_char(sub {
                      my $glyph = $_;
                      
                      printf "// U+%x -- %s\n", $glyph->char_code, charnames::viacode($glyph->char_code) || $glyph->name;

                      my $module_name = module_name($glyph);


                      # This origin to next origin, always positive.  FIXME: This is what breaks right-to-left.
                      printf "// Horizontal advance: %d\n", $glyph->horizontal_advance;

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

sub by_codepoint_generator {
  my ($low_glyphindex, $high_glyphindex, $indent) = @_;

  my $this_indent = " " x $indent;
  if($high_glyphindex == $low_glyphindex) {
    return $this_indent . module_name($glyphs[$high_glyphindex])."(); // CP = " 
      . $glyphs[$high_glyphindex]->char_code;
  } else {
    my $mid_glyphindex = int (($high_glyphindex + $low_glyphindex) / 2);

    return
      $this_indent .  "if(codepoint <= " . $glyphs[$mid_glyphindex]->char_code . ") \n"
    . by_codepoint_generator($low_glyphindex, $mid_glyphindex, $indent + 1) . "\n"
    . $this_indent .  "else\n"
    . by_codepoint_generator($mid_glyphindex+1, $high_glyphindex, $indent + 1);
  } 
}

sub module_name {
  my ($glyph) = @_;
  
  my $module_name = charnames::viacode($glyph->char_code) || $glyph->name;
  $module_name =~ s/\W/_/g;
  $module_name =~ s/_+/_/g;
  $module_name =~ s/ /_/g;
  $module_name =~ s/-/_/g;

  return $module_name;
}

sub assign_coded_point {
  my ($state, $x, $y) = @_;

  #print "//assign_coded_point(..., $x, $y)\n";
  my $str = sprintf "%f, %f", $x, $y;
  $state->{n_coded_points} //= 0;
  my $this_point;
  if (not exists $state->{coded_points}{$str}) {
    $this_point = $state->{n_coded_points}++;
    $state->{coded_points}{$str} = $this_point;
    $state->{coded_points_array}[$this_point] = [$x, $y];
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
  # print "  // line_to ($x, $y)\n";

  push @{$state->{current_path}}, assign_coded_point($state, $x, $y);

  $state->{current_pos} = assign_coded_point($state, $x, $y);
}

sub cubic_to {
  my ($state, $destx, $desty, $c1x, $c1y, $c2x, $c2y) = @_;
  #print "// cubic_to ($destx, $desty) control 1 ($c1x, $c1y) control 2 ($c2x, $c2y)\n";
  
  # Dump $state;
  
  my ($initial_x, $initial_y) = @{$state->{coded_points_array}[$state->{current_pos}]};

  #print "// from $initial_x, $initial_y\n";

  my $naive_length = sqrt(($initial_x-$destx)**2 + ($initial_y-$desty)**2);
  #print "// Naive length: $naive_length\n";

  my $n_points = ceil($naive_length*2);
  # Asking Math::Bezier for one point along the curve will confuse it.
  $n_points = 2 if $n_points < 2;
  #print "// Using $n_points along curve\n";

  my $curve = Math::Bezier->new($initial_x, $initial_y, $c1x, $c1y, $c2x, $c2y, $destx, $desty);

  my @points = $curve->curve($n_points);
  # First x, y pair is always the initial x, y, which we have already put in the path, no need to line_to it again.
  shift @points;
  shift @points;
  while (@points) {
    my ($x, $y) = splice(@points, 0, 2);
    line_to($state, $x, $y);
  }

  # print "// End bezier\n";
}
