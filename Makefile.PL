use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME	=> 'DBD::JDBC',
    VERSION_FROM => 'JDBC.pm', # finds $VERSION
    dist => { COMPRESS => 'gzip', SUFFIX => 'gz', },

    ($] >= 5.00503)
              ? (AUTHOR    => 'Gennis Emerson <gemerson@vizdom.com>',
                 ABSTRACT  => 'DBI proxy driver using JDBC',
                 )  
              : (),
);
