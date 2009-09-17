#!perl

use 5.006;
use strict;
use warnings;
use Test::More tests => 4;
use File::Slurp;

use WWW::Freshmeat 0.12;

my $fm = WWW::Freshmeat->new();
isa_ok($fm,'WWW::Freshmeat');

my $xml=read_file('t/mojomojo.xml');
my $project = $fm->project_from_xml($xml);

isa_ok($project,'WWW::Freshmeat::Project');
is($project->name(),'MojoMojo');
is($project->date_add(),'2009-01-22 14:58:27');
