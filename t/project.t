#!perl -T

use strict;
use warnings;
use Test::More tests => 5;

use WWW::Freshmeat;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $project = $fm->retrieve_project('hook_lexwrap');

isa_ok($project,'WWW::Freshmeat::Project');
is($project->name(),'Hook::LexWrap');
is($project->url(),'http://search.cpan.org/dist/Hook-LexWrap/');
is($project->license(),'Perl License');

