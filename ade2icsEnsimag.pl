#!/usr/bin/env perl

# Author:
# Etienne Barbier Grenoble-inp Ensimag Alternance
# Nicolas Pamart Grenoble-inp Ensimag Alternance

# This program automates export of ade calendar to ics when :
# - HTTP (or Apache) authentification is needed.
# - exportation to ics file manually need to be possible.
#
# It's work for Ensimag school at January 2, 2018.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# To works, this program need the packets: perl & libwww-mechanize-perl

use POSIX qw/strftime/;
use strict;
use warnings;
use utf8;
use WWW::Mechanize;
use HTTP::Cookies;
use Time::Local;
use Getopt::Long;
use open ':encoding(utf-8)';
binmode STDOUT, ':encoding(utf-8)';

my $day = int(strftime("%d", localtime())); # The number of the current day
my $mounth = int(strftime("%m", localtime())); # The number of the current mounth
my $year = int(strftime("%Y", localtime())); # The current year

#----------------------Beginning Configuration----------------------
my %default_config;
# Url of ade calendar.
$default_config{'url'} = 'my_url';
# Arguments of the ade calendar.
$default_config{'arguments'} = 'my_args';
# Login for HTTP authentification.
$default_config{'login'} = '';# my_login
# Password for HTTP authentification.
$default_config{'password'} = '';# my_password
# Destination of output file.  set "file_name.ics" to have the file in the local folder.
$default_config{'destination'} = 'my_calendar.ics';
# Default interval of time, by default is for one year
$default_config{'startDate'}{'day'} = 1; # start Day
$default_config{'startDate'}{'mounth'} = 8; # start Mounth
$default_config{'endDate'}{'day'} = 1; # end Day
$default_config{'endDate'}{'mounth'} = 8; # start Mounth
# take into account the new year
if($mounth < $default_config{'startDate'}{'mounth'}){
  $default_config{'startDate'}{'year'} = $year - 1; # start year
  $default_config{'endDate'}{'year'} = $year; # start Year
}else{
  $default_config{'startDate'}{'year'} = $year; # start year
  $default_config{'endDate'}{'year'} = $year + 1; # start Year
}


# Exemple
# If your direct url for ade calendar is : https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag?resources=8530,13157,13169,13183,13191,13164,13165,13163,13153,13152,13151,13175,13149,13177,13179,13185,13181,13171,13189,13147,13155,13145,13159,13167,13173,13142,13141,13143,13187
# set "https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag" for the URL.
# and set "8530,13157,13169,13183,13191,13164,13165,13163,13153,13152,13151,13175,13149,13177,13179,13185,13181,13171,13189,13147,13155,13145,13159,13167,13173,13142,13141,13143,13187" for arguments.
# For more details on arguments go to https://ensiwiki.ensimag.fr/index.php/Emplois_du_temps_en_ligne_avec_ADE , in the rubric "Créer son URL personnelle".
#
#----------------------End Configuration----------------------

my %opts=();
GetOptions(\%opts, 'u=s', 'a=s', 'l=s', 'p=s', 'd=s' ,'t=i', 'help');

if(defined $opts{help}){
  print "Welcome in the help of the Ade_to_ics_Ensimag script. \n";
  print "To use this script please change the default config in the script file or use the followings options \n";
  print "\n";
  print "-u your_url           with your_url the url of the ade calendar\n";
  print "-a your_args          with your_args the arguments of the ade calendar\n";
  print "-l your_login         with your_login your login for the ade calendar\n";
  print "-p your_password      with your_password your password for the ade calendar\n";
  print "-d your_destination   with your_destination the location where the .ics file should be saved. By default it's will be my_calendar.ics \n";
  print "-t number_of_day      with number_of_day the number of days from now that you want for the ics calendar. Without this option the ics calendar is from 1st of August of this year to the 1st of August of next year .\n";
  print "\n";
  print "Exemple : \n";
  print "if your direct url for ade calendar is : https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag?resources=8530,13157,13169 \n";
  print "option -u will be https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag \n";
  print "option -a will be 8530,13157,13169 \n";
  print "For more details on arguments go to https://ensiwiki.ensimag.fr/index.php/Emplois_du_temps_en_ligne_avec_ADE , in the rubric \"Créer son URL personnelle\" \n";
  print "\n";
  print "Complete exemple : \n";
  print "Ade_to_ics_Ensimag.pl -u https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag -a 8530,13157,13169 -l mylogin -p mypassword -d mycalendar.ics \n";
  print "\n";
  exit;
}

if($default_config{'url'} eq 'my_url' & ! defined $opts{u} ){
  print "use opion --help to get help \n";
  exit;
}


$default_config{'url'} = $opts{u} if defined $opts{u};
$default_config{'arguments'} = $opts{a} if defined $opts{a};
$default_config{'login'} = $opts{l} if defined $opts{l};
$default_config{'password'} = $opts{p} if defined $opts{p};
$default_config{'destination'} = $opts{d} if defined $opts{d};

if(defined $opts{t}){
  die "Error : option -t must be bigger than 0." if ($opts{t} < 1);
  $default_config{'startDate'}{'day'} = $day; # start Day
  $default_config{'startDate'}{'mounth'} = $mounth; # start Mounth
  $default_config{'startDate'}{'year'} = $year; # start year
  my $timestamp = time;
  $timestamp = $timestamp+(($opts{t}-1)*3600);
  $default_config{'endDate'}{'day'} = int(strftime("%d", localtime($timestamp))); # end Day
  $default_config{'endDate'}{'mounth'} = int(strftime("%m", localtime($timestamp))); # start Mounth
  $default_config{'endDate'}{'year'} = int(strftime("%Y", localtime($timestamp))); # start Year
}

my $mech = WWW::Mechanize->new(agent => 'ADEicsEnsimag 0.1', cookie_jar => {});

if(! $default_config{'login'} eq ""){
  $mech->credentials( $default_config{'login'},$default_config{'password'}); # Auth HTTP
}

$mech->get($default_config{'url'});
die "Error : failed to load page. Check if url works." if (!$mech->success());

$mech->get($default_config{'url'}.'/jsp/custom/modules/plannings/direct_planning.jsp');
die "Error : failed to load page. Check if url works." if (!$mech->success());

my $uri = $mech->uri();

$mech->get($uri.'?resources='.$default_config{'arguments'});
die "Error :  Impossible to get the asked ressouces." if (!$mech->success());

# Transform direct_planning.jsp url to ical.jsp url
my $find = "direct_planning.jsp";
my $replace = "ical.jsp";
$find = quotemeta $find; # escape regex metachars if present
$uri =~ s/$find/$replace/g;

# Request to get the ics calendar with the time you want.
$mech->post($uri,
[startDay => $default_config{'startDate'}{'day'},
startMonth => $default_config{'startDate'}{'mounth'},
startYear => $default_config{'startDate'}{'year'},
endDay => $default_config{'endDate'}{'day'},
endMonth => $default_config{'endDate'}{'mounth'},
endYear => $default_config{'endDate'}{'year'},
calType => 'ical',
x => 20, # not important
y => 10, # not important
clearTree => 'false'
]
);
die "Error : Impossible to get the ics file." if (!$mech->success());


# Save the file that contains the calendar.
open(FILE, ">".$default_config{'destination'}) or die "Can't open file";
print FILE $mech->content."\n";
close(FILE);





__END__
