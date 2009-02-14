#!perl

use strict;
use warnings;
use LWP::Online ':skip_all';
use Test::More tests => 17;

use WWW::Freshmeat;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $project = $fm->retrieve_project('hook_lexwrap');

isa_ok($project,'WWW::Freshmeat::Project');
is($project->name(),'Hook::LexWrap');
#is($project->url(),'http://search.cpan.org/dist/Hook-LexWrap/');
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
is($project->projectname_short(),'hook_lexwrap');
is_deeply({$project->branches()},{'77120'=>'Default'},'branches');
#%hash=$project->url_list;
is_deeply({$project->url_list()},{
'url_homepage'=>'http://search.cpan.org/dist/Hook-LexWrap/',
'url_bugtracker'=>'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Hook-LexWrap',
},'URLs');
my %pop=$project->popularity();
cmp_ok($pop{'record_hits'},'>=',442);
cmp_ok($pop{'url_hits'},'>=',216);
cmp_ok($pop{'subscribers'},'>=',0);
