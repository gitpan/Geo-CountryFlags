use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Geo::CountryFlags',
    'PREREQ_PM'		=> {	'LWP::Simple'	=> '0',
			},
    'VERSION_FROM'	=> 'CountryFlags.pm', # finds $VERSION
    'PM'		=> {'CountryFlags.pm' => '$(INST_LIBDIR)/CountryFlags.pm'},
    'dist'		=> {COMPRESS=>'gzip', SUFFIX=>'gz'}
);
