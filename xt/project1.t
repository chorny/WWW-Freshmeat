#!perl

use strict;
use warnings;
use LWP::Online ':skip_all';
use Test::More tests => 7;

use WWW::Freshmeat;

my $fm = WWW::Freshmeat->new;
isa_ok($fm,'WWW::Freshmeat');

my $project = $fm->retrieve_project('proc_reliable');

isa_ok($project,'WWW::Freshmeat::Project');
is($project->name(),'Proc::Reliable');
is($project->url(),'http://www.zblob.com/software/dan_soft.html');
is($project->license(),'Perl License');
my @trove=@{$project->trove_id()};
my %hash;
@hash{@trove}=();
#902 - OSI Approved :: Perl License
#176 - Perl
#910 - Software Development :: Libraries :: Perl Modules
is($project->projectname_short(),'proc_reliable');
is_deeply({$project->branches()},{'38190'=>'Default'});
