#!perl -T

use strict;
use warnings;
use LWP::Online ':skip_all';
use Test::More tests => 12;

use WWW::Freshmeat;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $project = $fm->retrieve_project('hook_lexwrap');

isa_ok($project,'WWW::Freshmeat::Project');
is($project->name(),'Hook::LexWrap');
is($project->url(),'http://search.cpan.org/dist/Hook-LexWrap/');
is($project->license(),'Perl License');
my @trove=@{$project->trove_id()};
my %hash;
@hash{@trove}=();
foreach my $t (11,3,902,235,176,809,910) {
  ok(exists $hash{$t},"id $t is present");
}
#902 - OSI Approved :: Perl License
#176 - Perl
#910 - Software Development :: Libraries :: Perl Modules
