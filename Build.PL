use 5.008;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Freshmeat',
    license             => 'perl',
    dist_author         => 'Alexandr Ciornii <alexchorny@gmail.com>',
    dist_version_from   => 'lib/WWW/Freshmeat.pm',
    requires => {
        'LWP::UserAgent' => 0,
        'XML::Simple' => 0,
        'perl' => 5.008,
        'HTML::TreeBuilder::XPath' => 0.09,
    },
    build_requires => {
        'Test::More' => 0.17, #isa_ok
        'LWP::Online' => 1.06,
    },
    add_to_cleanup      => [ 'WWW-Freshmeat-*' ],
);

$builder->create_build_script();
