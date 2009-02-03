use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Freshmeat',
    license             => 'perl',
    dist_author         => 'Cedric Bouvier <cbouvi@cpan.org>',
    dist_version_from   => 'lib/WWW/Freshmeat.pm',
    requires => {
        'LWP::UserAgent' => 0,
        'XML::Simple' => 0,
        'perl' => 5.006,
    },
    build_requires => {
        'Test::More' => 0,
        'LWP::Online' => 1.06,
    },
    add_to_cleanup      => [ 'WWW-Freshmeat-*' ],
);

$builder->create_build_script();
