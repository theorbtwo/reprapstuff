#!/usr/bin/perl
use warnings;
use strict;
use Template;
use File::Temp 'tempfile';
use List::Util 'min', 'max';
use Data::Dump::Streamer 'Dump';
use POSIX 'ceil';
# http://www.robottrouble.com/2009/12/01/auto-rendering-stl-files-to-png/

my $tt = Template->new({
                        INCLUDE_PATH => '/mnt/shared/projects/shapercube/thumbnailer/'
                       });

for my $infn (@ARGV) {
  print "Working on $infn\n";

  if ($infn =~ m/\.stl$/i) {
    my $stash = {};

    $stash->{pov_mesh} = `/mnt/shared/projects/shapercube/thumbnailer/stl2pov-2.4.4/stl2pov "$infn"`;
    # stl2pov uses m_whateverthefilehad, and whateverthefilehad isn't neccessarly a valid povray name.
    $stash->{pov_mesh} =~ s/#declare (m_.*?) =/#declare the_mesh =/;

    my ($minpoint, $maxpoint) = ([ 1e99,  1e99,  1e99],
                                 [-1e99, -1e99, -1e99]);

    while ($stash->{pov_mesh} =~ m/<(-?[0-9.]+),\s*(-?[0-9.]+),\s*(-?[0-9.]+)>/g) {
      my @thispoint = ($1, $2, $3);
      $minpoint->[$_] = min($minpoint->[$_], $thispoint[$_]) for (0..2);
      $maxpoint->[$_] = max($maxpoint->[$_], $thispoint[$_]) for (0..2);
    }

    $stash->{minpoint} = $minpoint;
    $stash->{maxpoint} = $maxpoint;
    $stash->{midpoint}[$_] = ($minpoint->[$_] + $maxpoint->[$_])/2 for 0..2;

    $stash->{radius} = max map {abs} @$minpoint, @$maxpoint;

    $stash->{rounded_radius} = 50 * ceil($stash->{radius}/50);


    #Dump $stash;
    #exit;

    my ($povfh, $povfn) = tempfile();

    $tt->process('pov_layout.tt', $stash, $povfh)
      or die;

    my $pngfn = $infn;
    $pngfn =~ s/\.stl/.png/i;

    print "Povfn: $povfn\n";

    delete $ENV{DISPLAY};
    system('povray',
           '-GA',      # all to console (note: this is *not* a shortcut, but an override!)
           '-GD',      # debug to console
           '+GF',      # fatals to console
           '-GS',      # statistics to console
           '+GW',      # warnings to conole
           "-V",       # verbose
           "-D",       # preview display

           "+L/mnt/shared/projects/shapercube/thumbnailer/",       # POVRAY library directory

           "+A0.1",    # Antialias when this pixel is more then 0.1 R+G+B different from neighbors.

           "+I$povfn", # input filename
           "+H512",    # output height
           "+W512",    # output width
           "+Q9",      # quality (0..11)
           "+FN",      # Output pNg
           "+O$pngfn", # output filename
          );

  } else {
    die "Don't know what to do with $infn";
  }
}
