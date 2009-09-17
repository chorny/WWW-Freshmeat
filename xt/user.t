#!perl

use strict;
use warnings;
use LWP::Online ':skip_all';
use Test::More tests => 4;

use WWW::Freshmeat 0.12;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $user = $fm->retrieve_user('chorny');

isa_ok($user,'WWW::Freshmeat::User');
my @projects=$user->projects();
cmp_ok(scalar(@projects),'>',10);
ok((grep {$_ eq 'hook_lexwrap'} @projects),'hook_lexwrap present');
