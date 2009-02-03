#!perl

use strict;
use warnings;
use LWP::Online ':skip_all';
use Test::More tests => 2;

use WWW::Freshmeat;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $project = $fm->retrieve_project('nonexistingproject');
ok(!defined($project));
