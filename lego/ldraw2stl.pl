#!/usr/bin/perl
use warnings;
use strict;
use Data::Dump::Streamer;
use Math::Geometry;
use Math::MatrixReal;
#use Data::Dump::Streamer 'Dump', 'Dumper';
use 5.10.0;

# Each stack entry has...
# {filename}: Filename that this represents.
# {color}: The color being drawn (ldraw color number)
# {effective_matrix}: A Math::MatrixReal, 4x4, the matrix that should be (post) multiplied to give
#  ... err, more verbiage goes here.
# {bfc}{certified}: Set to 1 by top-level
# {bfc}{winding}: Either cw or ccw
# {bfc}{invertnext}: 1 when an 0 BFC INVERTNEXT command is in effect -- that is, we are looking for the "next".
# {bfc}{inverting}: 1 when we are inverting -- the parent had an invertnext in effect.
my @stack;
## current item on stack (bottom of stack)
my $bos = {
          };
$bos->{filename} = $ARGV[0];
$bos->{color} = 0;

# We need to specify the correct initial matrix here to:
# http://www.ldraw.org/Article218.html#coords
# 1: Scale from LDU to mm.  1 ldu = 0.4 mm
# 2: Rotate 90 degrees about x.  Ldraw's coord sys has -y as up, reprap's uses +z is up.
$bos->{effective_matrix} = Math::MatrixReal->new(4,4)->exponent(0) * 0.4;

$stack[0] = $bos;

my @model_data;

while (@stack) {
  if (!$bos->{fh}) {
    $bos->{fh} = open_ldraw_file($bos->{filename});
  }

  if (eof $bos->{fh}) {
    pop @stack;
    $bos = $stack[-1];
    next;
  }

  my $line = readline($bos->{fh});
  if (not defined $line) {
    die "Can't read line from $bos->{filename}: $!";
  }
  chomp $line;
  $line =~ s/\x0d//g;
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;

  #warn "$bos->{filename} $.: <<$line>>\n";

  if ($line =~ m/^0\s/ || $line =~ m/^0$/) {

    if ($line =~ m/^0 BFC (.*)$/) {
      # http://webcache.googleusercontent.com/search?q=cache:3Ba0lniZ724J:www.ldraw.org/Article415.html&cd=1&hl=en&ct=clnk

      my @flags = map {lc} split /\s+/, $1;

      for (@flags) {
        when ('certify') {
          $bos->{bfc}{certified} = 1;
        }
        when ('ccw') {
          $bos->{bfc}{winding} = 'ccw';
        }
        when ('cw') {
          $bos->{bfc}{winding} = 'cw';
        }
        when ('invertnext') {
          $bos->{bfc}{invertnext} = 1;
        }
        default {
          $|=1;
          die "Unhandled flag $_ in BFC line";
        }
      }
    } else {
      # Not a BFC line.
      #print "$line\n";
    }

    # At some point, will have to seperate out the important ones from the unimportant ones -- BFC probably the most important.
  } elsif ($line =~ m/^\s*$/) {
  } elsif ($line =~ m/^1\s/) {
    my @split = split m/\s+/, $line;
    my (undef, $color, $x, $y, $z) = splice(@split, 0, 5);
    my @xforms = splice(@split, 0, 9);
    my $file = shift @split;
    if (@split) {
      die "Too many values on type 1 line $line -- @split";
    }
    
    my $new_xform =
      Math::MatrixReal->new_from_rows([[$xforms[0], $xforms[1], $xforms[2], $x],
                                       [$xforms[3], $xforms[4], $xforms[5], $y],
                                       [$xforms[6], $xforms[7], $xforms[8], $z],
                                       [0,          0,          0,          1 ]]);

    my $old_bos = $bos;

    push @stack, {};
    $bos = $stack[-1];
    $bos->{filename} = $file;
    $bos->{color} = resolve_color($old_bos, $color);
    $bos->{effective_matrix} = $old_bos->{effective_matrix} * $new_xform;

    $bos->{bfc}{inverting} = $old_bos->{bfc}{inverting};
    #warn "Inverting starts at $bos->{bfc}{inverting}\n";

    $bos->{bfc}{inverting} = !$bos->{bfc}{inverting}
      if $old_bos->{bfc}{invertnext};
    #warn "Inverting after checking invertnext: $bos->{bfc}{inverting}\n";

    #warn "Determinant: ", $new_xform->det, "\n";
    $bos->{bfc}{inverting} = !$bos->{bfc}{inverting}
      if $new_xform->det < 0;
    #warn "Inversion after checking det: $bos->{bfc}{inverting}\n";

    #print STDERR Dumper($old_bos);
    #print STDERR Dumper($bos);

    $old_bos->{bfc}{invertnext} = 0;
  } elsif ($line =~ m/^2/) {
    # We do not implement type 2 lines, which are line segments, and
    # thus have zero width and cannot exist in the real world.

  } elsif ($line =~ m/^3\s/) {
    my ($color, @points) = extract_polygon(3, $line, $bos);
    $color = resolve_color($bos, $color);

    push @model_data, {type => 'triangle',
                       points => [map {apply_xform($bos->{effective_matrix}, $_)} @points],
                       color => $color};

  } elsif ($line =~ m/^4\s/) {
    my ($color, @points) = extract_polygon(4, $line, $bos);

    $color = resolve_color($bos, $color);

    @points = map {apply_xform($bos->{effective_matrix}, $_)} @points;

    #push @model_data, {type => 'quad', points => \@points, color=>$color};

    # Decompose the quad into two triangles *with the same winding as the original quad*
    # so the output loop only has to deal with triangles, not quads.

    push @model_data, {type => 'triangle',
                       points => [$points[0], $points[1], $points[3]],
                       color => $color
                      };

    push @model_data, {type => 'triangle',
                       points => [$points[1], $points[2], $points[3]],
                       color => $color
                      };

  } elsif ($line =~ m/^5\s/) {
    # Type 5 lines are optinal line segments, and are unimplemented for the same reason as type 2.
  } else {
    die "Unhandled line $line from $bos->{filename}:$.";
  }
}

#print "<finished>\n";
#Dump \@model_data;

print "solid name\n";

for my $facet (@model_data) {
  my @points = @{$facet->{points}};
  my @normal = triangle_normal(map{@$_} @points);
  print <<"END";
facet normal $normal[0] $normal[1] $normal[2]
  outer loop
    vertex $points[0][0] $points[0][1] $points[0][2]
    vertex $points[1][0] $points[1][1] $points[1][2]
    vertex $points[2][0] $points[2][1] $points[2][2]
  endloop
endfacet
END
}

sub apply_xform {
  my ($xform, $point) = @_;
  # The $_+0 bit is to convert things of the form .333, which Math::MatrixReal chokes on.
  my $xformed = $xform * Math::MatrixReal->new_from_cols([[map {$_+0} @$point, 1]]);
  
  return [$xformed->element(1,1),
          $xformed->element(2,1),
          $xformed->element(3,1),
         ];
}

sub extract_polygon {
  my ($size, $line, $bos) = @_;
  
  my @split = split m/\s+/, $line;
  shift @split;
  my $color = shift @split;
  my @points;
  $points[$_] = [splice @split, 0, 3] for 0..$size-1;
  if (@split) {
    die "Too many arguments to type 3 line <<$line>> -- @split remain";
  }
  
  if ($bos->{bfc}{inverting}) {
    @points = reverse @points;
  }
  
  if ($bos->{bfc}{winding} eq 'cw') {
    @points = reverse @points;
  } elsif ($bos->{bfc}{winding} eq 'ccw') {
    # No need to do anything
  } else {
    die "Winding neither cw nor ccw: $bos->{bfc}{winding}";
  }
  
  return ($color, @points);
  
  #    push @model_data, {type => 'triangle',
  #                      points => [map {apply_xform($bos->{effective_matrix}, $_)} @points],
  #                       color => $color};
}

sub resolve_color {
  my ($stackitem, $color) = @_;
  if ($color == 16) {
    return $stackitem->{color};
  }
  if ($color == 24) {
    die "Get edge color for color #$stackitem->{color}";
  }
  return $color;
}

my %cache;
sub find_ldraw_file {
  my ($short_name) = @_;

  my $fh;

  $short_name =~ s!\\!/!g;

  if ($cache{$short_name}) {
    return $cache{$short_name};
  }
  if (-e $short_name) {
    $cache{$short_name} = $short_name;
    return $short_name;
  }
  for my $prefix ('parts', 'p') {
    my $name = "/mnt/shared/projects/shapercube/lego/ldraw/$prefix/$short_name";
    #print "Checking $name\n";
    if (-e $name) {
      $cache{$short_name} = $name;
      return $name;
    }
  }

  die "can't find $short_name anywhere";
}

sub open_ldraw_file {
  my ($filename) = @_;
  $filename = find_ldraw_file($filename);

  open my $fh, '<', $filename or die "Can't open $filename: $!";
  return $fh;
}
