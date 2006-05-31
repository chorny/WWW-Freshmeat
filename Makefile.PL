use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Freshmeat',
    AUTHOR              => 'Cedric Bouvier <cbouvi@cpan.org>',
    VERSION_FROM        => 'lib/WWW/Freshmeat.pm',
    ABSTRACT_FROM       => 'lib/WWW/Freshmeat.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'LWP::UserAgent' => 0,
        'XML::Simple' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Freshmeat-*' },
);
