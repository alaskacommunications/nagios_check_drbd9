#!/usr/bin/perl -Tw
#
#   Nagios DRBD 9 Checks
#   Copyright (c) 2016, David M. Syzdek <david@syzdek.net>
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are
#   met:
#
#      1. Redistributions of source code must retain the above copyright
#         notice, this list of conditions and the following disclaimer.
#
#      2. Redistributions in binary form must reproduce the above copyright
#         notice, this list of conditions and the following disclaimer in the
#         documentation and/or other materials provided with the distribution.
#
#      3. Neither the name of the copyright holder nor the names of its
#         contributors may be used to endorse or promote products derived from
#         this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
#   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# +-=-=-=-=-=-+
# |           |
# |  Headers  |
# |           |
# +-=-=-=-=-=-+

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

$|++;

our $PROGRAM_NAME    = 'dump_drbd9.pl';
our $VERSION         = '0.3';
our $DESCRIPTION     = 'Dump hash structure of DRBD resources';
our $AUTHOR          = 'David M. Syzdek <david@syzdek.net>';

%ENV                 = ();
$ENV{PATH}           = '/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin';


# +-=-=-=-=-=-=-=+
# |              |
# |  Prototypes  |
# |              |
# +-=-=-=-=-=-=-=+

sub HELP_MESSAGE();
sub VERSION_MESSAGE();
sub chk_drbd_config($);
sub chk_drbd_walk($);

sub main(@);                     # main statement


# +-=-=-=-=-=-=-+
# |             |
# |  Functions  |
# |             |
# +-=-=-=-=-=-=-+

sub HELP_MESSAGE()
{
   printf STDERR ("Usage: %s [OPTIONS]\n", $PROGRAM_NAME);
   printf STDERR ("OPTIONS:\n");
   printf STDERR ("  -h              display this message\n");
   printf STDERR ("  -i pattern      include resource name or resource minor (default: all)\n");
   printf STDERR ("  -V              display program version\n");
   printf STDERR ("  -x pattern      exclude resource name or resource minor\n");
   printf STDERR ("\n");
   return(0);
};


sub VERSION_MESSAGE()
{
   printf ("%s (%s)\n\n", $PROGRAM_NAME, $VERSION);
   return 0;
};


sub chk_drbd_config($)
{
   my $cnf = shift;

   my $opt;
   my $list;
   my $state;
   my $key;

   $cnf->{'include'}                 = 'all';
   $cnf->{'exclude'}                 = '^$';

   $Getopt::Std::STANDARD_HELP_VERSION=1;

   $opt = {};
   if (!(getopts("hi:Vx:", $opt)))
   {
      HELP_MESSAGE();
      return(3);
   };
   if (($cnf->{'h'}))
   {
      HELP_MESSAGE();
      return(3);
   };

   $cnf->{'include'} = defined($opt->{'i'}) ? $opt->{'i'} : $cnf->{'include'};
   $cnf->{'exclude'} = defined($opt->{'x'}) ? $opt->{'x'} : $cnf->{'exclude'};

   return(0);
};


sub chk_drbd_walk($)
{
   my $cnf = shift;

   my $name;
   my $resource;
   my $resources;
   my $sh_resources;
   my $line;
   my $rec;
   my @lines;
   my %data;


   $resources = {};


   # parse /proc/drbd
   if (!(open(FD, '</proc/drbd')))
   {
      printf("DRBD UNKNOWN: kernel module is not loaded\n");
      return(3);
   };
   chomp(@lines = <FD>);
   close(FD);
   ($cnf->{'version'})    =  grep(/^version: /i,  @lines);
   $cnf->{'version'}      =~ s/^version: //gi;
   ($cnf->{'git-hash'})   = grep(/^GIT-hash: /i, @lines);
   $cnf->{'git-hash'}     =~ s/^GIT-hash: //gi;
   ($cnf->{'transports'}) = grep(/^Transports /i, @lines);
   $cnf->{'transports'}   =~ s/^Transports //gi;


   # builds resources
   $sh_resources = `/usr/sbin/drbdadm sh-resources`;
   if ($sh_resources =~ /^([-_.\w\s]+)$/)
   {
      $sh_resources = $1;
      chomp($sh_resources);
      for $name (split(/\s/, $sh_resources))
      {
         # create new resource
         $resource            = {};
         $resource->{'name'}  = $name;
         $resource->{'role'}  = 'unconfigured';
         $resources->{$name}  = $resource;
      };
   } else {
      printf("DRBD UNKNOWN: invalid DRBD resource names found\n");
      return(3);
   };


   # read events
   @lines = `/usr/sbin/drbdsetup events2 --now --statistics all`;
   chomp(@lines);


   # parse resource lines
   for $line (grep(/^exists[\s]+resource/i, @lines))
   {
      %data               = split(/[ :]/, $line);
      $rec                = $resources->{$data{'name'}};
      $rec->{'nodes'}     = {};
      $rec->{'devs'}      = {};
      @{$rec}{keys %data} = values(%data);
   };


   # parse device lines
   for $line (grep(/^exists[\s]+device/i, @lines))
   {
      $rec = {};
      %{$rec} = split(/[ :]/, $line);
      $resource = $resources->{$rec->{'name'}};
      $resource->{'devs'}->{$rec->{'volume'}} = $rec;
   };


   # parse connection lines
   for $line (grep(/^exists[\s]+connection/i, @lines))
   {
      $rec = {};
      %{$rec} = split(/[ :]/, $line);
      $rec->{'devs'} = {};
      $resource = $resources->{$rec->{'name'}};
      $resource->{'nodes'}->{$rec->{'conn-name'}} = $rec;
   };


   # parse peer-device lines
   for $line (grep(/^exists[\s]+peer-device/i, @lines))
   {
      $rec = {};
      %{$rec} = split(/[ :]/, $line);
      $resource = $resources->{$rec->{'name'}}->{'nodes'}->{$rec->{'conn-name'}};
      $resource->{'devs'}->{$rec->{'volume'}} = $rec;
   };


   # pulls select resources to monitor
   for $name (keys(%{$resources}))
   {
      if ($name =~ $cnf->{'exclude'})
      {
         continue;
      };
      if ($name =~ $cnf->{'include'})
      {
         $cnf->{'all'}->[@{$cnf->{'all'}}] = $resources->{$name};
      }
      elsif (($cnf->{'include'} eq 'configured') && ($resources->{$name}->{'role'} ne 'unconfigured'))
      {
         $cnf->{'all'}->[@{$cnf->{'all'}}] = $resources->{$name};
      }
      elsif ($cnf->{'include'} =~ /^all$/i)
      {
         $cnf->{'all'}->[@{$cnf->{'all'}}] = $resources->{$name};
      };
   };


   return(0);
}



# +-=-=-=-=-=-=-=-=-+
# |                 |
# |  Main  Section  |
# |                 |
# +-=-=-=-=-=-=-=-=-+
sub main(@)
{
   # grabs passed args
   my @argv = @_;

   my $cnf;
   my $rc;
   my $res;
   my @resources;


   $cnf = {};


   # parses CLI arguments
   if ((chk_drbd_config($cnf)))
   {
      return(3);
   };


   # collects DRBD information
   if (($rc = chk_drbd_walk($cnf)) != 0)
   {
      return($rc);
   };


   print(Dumper($cnf));


   # ends function
   return(0);
};
exit(main(@ARGV));


# end of script
