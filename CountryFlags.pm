package Geo::CountryFlags;

use vars qw($VERSION);
$VERSION = do { my @r = (q$Revision: 0.01 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r };
use strict;

=head1 NAME

  Geo::CountryFlags - methods to fetch flag gif's

=head1 SYNOPSIS

  use Geo::CountryFlags

  $gf = new Geo::CountryFlags(	# optional
	['cia_url',
	 \%country_code => cia_code,
	dir_umask,	# default 0775
	file_umask,	# default 0664
	]

  defaults:
  http://www.cia.gov/cia/publications/factbook/flags/
  %cc2cia current as of 1-24-03

  # return a local path to the flag file
  # fetch the file from CIA if necessary
  $flag_path = $gf->get_flag($country_code,[flag_dir])

  default:
  flag_dir = ./flags

  # return the CIA country code (non-iso)
  # used mostly internally
  $cia_code = $gf->cc2cia($country_code)

=cut

my $CIAurl = 'http://www.cia.gov/cia/publications/factbook/flags/';

# country code to cia flag prefix hash
# if CIA changes codes, update this

my %cc2cia = (
AS	=> 'AQ',
AQ	=> undef,
AU	=> 'AS',
AT	=> 'AU',
BS	=> 'BF',
BY	=> 'BO',
BF	=> 'UV',
TD	=> 'CD',
AP	=> undef,
EU	=> undef,	# it's Europa Island @CIA
AD	=> 'AN',
AE	=> 'TC',
AN	=> 'NT',
TC	=> 'TK',
AI	=> 'AV',
AW	=> 'AA',
AZ	=> 'AJ',
BI	=> 'BY',
BO	=> 'BL',
BJ	=> 'BN',
BN	=> 'BX',
BW	=> 'BC',
BZ	=> 'BH',
BH	=> 'BA',
BA	=> 'BK',
CC	=> 'CK',
CK	=> 'CW',
CG	=> 'CF',
CF	=> 'CT',
CD	=> 'CG',
CL	=> 'CI',
CI	=> 'IV',
CR	=> 'CS',
CX	=> 'KT',
CZ	=> 'EZ',
DE	=> 'GM',
GM	=> 'GA',
GA	=> 'GB',
GB	=> 'UK',
DK	=> 'DA',
DM	=> 'DO',
DO	=> 'DR',
DZ	=> 'AG',
AG	=> 'AC',
EE	=> 'EN',
EH	=> undef,
FX	=> 'FR',
GD	=> 'GJ',
'GE'	=> 'GG',
GF	=> 'FG',
GN	=> 'GV',
GS	=> 'SX',
GU	=> 'GQ',
GQ	=> 'EK',
GW	=> 'PU',
HN	=> 'HO',
HT	=> 'HA',
IE	=> 'EI',
IL	=> 'IS',
IS	=> 'IC',
IQ	=> 'IZ',
JP	=> 'JA',
KH	=> 'CB',
KI	=> 'KR',
KR	=> 'KS',
KP	=> 'KN',
KN	=> 'SC',
SC	=> 'SE',
SE	=> 'SW',
KM	=> 'CN',
CN	=> 'CH',
CH	=> 'SZ',
SZ	=> 'WZ',
KW	=> 'KU',
KY	=> 'CJ',
LB	=> 'LE',
LC	=> 'ST',
ST	=> 'TP',
SN	=> 'SG',
SG	=> 'SN',
LK	=> 'CE',
LR	=> 'LI',
LI	=> 'LS',
LS	=> 'LT',
'LT'	=> 'LH',
LV	=> 'LG',
MG	=> 'MA',
MA	=> 'MO',
MO	=> 'MC',
MM	=> 'BM',
MQ	=> 'MB',
MU	=> 'MP',
MP	=> 'CQ',
BM	=> 'BD',
BD	=> 'BG',
BG	=> 'BU',
MC	=> 'MN',
MN	=> 'MG',
MS	=> 'MH',
MH	=> 'RM',
MW	=> 'MI',
NA	=> 'WA',
NI	=> 'NU',
'NE'	=> 'NG',
NG	=> 'NI',
NU	=> 'NE',
OM	=> 'MU',
PF	=> 'FP',
PG	=> 'PP',
PH	=> 'RP',
PN	=> 'PC',
PR	=> 'RQ',
PT	=> 'PO',
PW	=> 'PS',
PS	=> undef,
PY	=> 'PA',
PA	=> 'PM',
PM	=> 'SB',
SB	=> 'BP',
RU	=> 'RS',
SD	=> 'SU',
SJ	=> 'SV',
SV	=> 'ES',
ES	=> 'SP',
SK	=> 'LO',
SR	=> 'NS',
TF	=> 'FS',
TK	=> 'TL',
TG	=> 'TO',
TO	=> 'TN',
TN	=> 'TS',
TJ	=> 'TI',
TM	=> 'TX',
TP	=> 'TT',
TR	=> 'TU',
TT	=> 'TD',
UA	=> 'UP',
UM	=> undef,
VG	=> 'VI',
VI	=> 'VQ',
VN	=> 'VM',
VU	=> 'NH',
YE	=> 'YM',
YT	=> 'MF',
VA	=> 'VT',
VT	=> 'MF',
YU	=> 'YI',
ZM	=> 'ZA',
ZA	=> 'SF',
ZR	=> 'CG',
ZW	=> 'ZI',
A1	=> undef,
A2	=> undef,
);

=head1 DESCRIPTION

Provides methods to display / retrieve flag gifs from the web
site of the Central Intelligence Agency. Permanently caches a
local copy of the flag if it is not already present.

The flags for all country codes as of module publication are included
in the ./flags directory should you wish to install them. However,
If LWP::Simple is installed, Geo::CountryFlags will fetch them as needed
and store them in ./flags [default] or the directory of you choice.

To fetch a single flag PATH the usage is simply:

  my $cc = 'US';	# country code

  my $flag_path = Geo::CountryFlags->new->get_flag($cc);

  for multiple flags:

  $gf = new Geo::CountryFlags;
  for (blah.... blah) {
    my $cc = function_of(blah...);
    my $flag_path = $gf->get_flag($cc);
    ....
  }

=head1 METHODS

=over 4

=item $gf = new Geo::CountryFlags('cia_url',\%cc2cia,$dm,$um);

  input:	fetch flags from (optional)
		conversion hash (optional)

  output:	path_to/img.file
		or undef on failure

=cut

sub new {
  my ($proto,$cia_url,$cc2cia,$dm,$fm) = @_;
  my $class = ref($proto) || $proto;
  my $self  = {
	cia_url	=> $cia_url || $CIAurl,
	cc2cia	=> $cc2cia || \%cc2cia,
	dmask	=> $dm || 02,
	fmask	=> $fm || 0113,
	};
  $self->{cia_url} .= '/' unless
	$self->{cia_url} =~ m|/$|;
  bless ($self, $class);
  return $self;
}

=item $flag_path=$gf->get_flag($country_code,[flag_dir]);

  input:	country code,
		flag directory (optional)
		  default = ./flags

  output:	path_to/flag.image
		or undef if the country 
		flag is not available

  $@	:	clear on normal return
		set to error if unable to 
		connect or retrieve file
		from target flag server
		(only set on undef return)
=cut

sub get_flag {
  my ($self,$cc,$fd) = @_;
  $fd = './flags' unless $fd;
  unless ( -e $fd ) {
    umask $self->{dmask};
    mkdir $fd;
  }
  local $_ = eval {"${fd}/${cc}-flag.gif"};	# clear $@
  return $_ if -e $_;		# return flag if it exists
  return undef unless ($_ = &cc2cia($self,$cc));
  $_ = lc $_;
  eval {require LWP::Simple};
  return undef if $@;
  umask $self->{fmask};
  return undef unless eval {		# response must be 200, OK
	200 == ($_ = &LWP::Simple::getstore(
		$self->{cia_url}."$_-flag.gif",
		"${fd}/${cc}-flag.gif")) ||
		die $_
	};
  return "${fd}/${cc}-flag.gif";
}

=item $cia_code=$gf->cc2cia($country_code);

  input:	country code
  output:	cia code
		  or
		undef is cia code
		is known absent

=cut

sub cc2cia {
  my ($self,$cc) = @_;
  my $cia     = $cc;
  if (exists $self->{cc2cia}{$cc}) {
    return undef unless ($cia = $self->{cc2cia}{$cc});
  }
  return $cia;
}
1
__END__

=cut

=back

=head1 UTILITIES

The ./util directory contains two utility programs

  get_flags.pl

    retrieves all flags from CIA and stores 
    in local directory ./flags

  get_flags.pl names {any text}

    lists all flags by: {sorted by name}
      country-code, CIA-code, country-name

  make_htm.pl

    prints the text for an html page containing all
    the flags sorted by country name from a 
    local ./flags directory

=head1 SEE ALSO

Geo::IP::PurePerl

=head1 AUTHORS

Michael Robinton michael@bizsystems.com

=head1 COPYRIGHT and LICENSE

  Copyright 2003 Michael Robinton, BizSystems.

This module is free software; you can redistribute it and/or modify it
under the terms of either:

  a) the GNU General Public License as published by the Free Software
  Foundation; either version 1, or (at your option) any later version,
  
  or

  b) the "Artistic License" which comes with this module.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

You should have received a copy of the Artistic License with this
module, in the file ARTISTIC.  If not, I'll be glad to provide one.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

=cut
