#!/usr/bin/env perl

# Author: Etienne Barbier

# This program automates export of ade calendar to ics when :
# - HTTP (or Apache) authentification is needed.
# - exportation to ics file manually need to be possible.
#
# It's work for Ensimag school at October 10, 2016.

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
binmode STDOUT, ':encoding(utf-8)';

#----------------------Beginning Configuration----------------------
my %default_config;
# Url of ade calendar.
$default_config{'url'} = 'my_url';
# Arguments of the ade calendar.
$default_config{'arguments'} = 'my_args';
# Login for HTTP authentification.
$default_config{'login'} = 'my_login';
# Password for HTTP authentification.
$default_config{'password'} = 'my_password';
# Destination of output file.  set "file_name.ics" to have the file in the local folder.
$default_config{'destination'} = 'my_calendar.ics';

# Exemple
# If your direct url for ade calendar is : https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag?resources=8530,13157,13169,13183,13191,13164,13165,13163,13153,13152,13151,13175,13149,13177,13179,13185,13181,13171,13189,13147,13155,13145,13159,13167,13173,13142,13141,13143,13187
# set "https://edt.grenoble-inp.fr/2016-2017/etudiant/ensimag" for the URL.
# and set "8530,13157,13169,13183,13191,13164,13165,13163,13153,13152,13151,13175,13149,13177,13179,13185,13181,13171,13189,13147,13155,13145,13159,13167,13173,13142,13141,13143,13187" for arguments.
# For more details on arguments go to https://ensiwiki.ensimag.fr/index.php/Emplois_du_temps_en_ligne_avec_ADE , in the rubric "Créer son URL personnelle".
#
#----------------------End Configuration----------------------

my $mech = WWW::Mechanize->new(agent => 'ADEicsEnsimag 0.1', cookie_jar => {});

$mech->credentials( $default_config{'login'},$default_config{'password'}); # Auth HTTP
$mech->get($default_config{'url'});
die "Error : failed to load page. Check if url works." if (!$mech->success());

$mech->get($default_config{'url'}.'/jsp/custom/modules/plannings/direct_planning.jsp?resources='.$default_config{'arguments'});
die "Error :  Impossible to get the asked ressouces." if (!$mech->success());

my $year = int(strftime("%Y", localtime()));

# Request to get the ics calendar with the time you want.
$mech->post('https://edt.grenoble-inp.fr/2016-2017/ensimag/etudiant/jsp/custom/modules/plannings/ical.jsp',
[startDay => 1,
 startMonth => 8,
 startYear => $year,
 endDay => 1,
 endMonth => 8,
 endYear => $year+1,
 calType => 'ical',
 x => 20, # not important
 y => 10, # not important
 clearTree => 'false'
 ]
 );
die "Error : Impossible to get the ics file." if (!$mech->success());

print $mech->content;

# Save the file that contains the calendar.
open(FILE, ">/".$default_config{'destination'}) or die "Can't open file";
print FILE $mech->content."\n";
close(FILE);

__END__
