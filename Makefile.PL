use DBI 1.03;
use DBI::DBD;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
        'NAME'	=> 'DBD::JDBC',
        'VERSION_FROM' => 'JDBC.pm',
        'NO_META' => 1,
        'dist' => { COMPRESS => 'gzip', SUFFIX => 'gz', },
        'AUTHOR'    => 'Gennis Emerson <gemerson@vizdom.com>',
        'ABSTRACT'  => 'DBI proxy driver using JDBC',
); 


package MY;
sub postamble { return main::dbd_postamble(@_); }
sub libscan {
    my ($self, $path) = @_;
    ($path =~ m/\~$/) ? undef : $path;
}


