#!/usr/bin/perl

use strict;
use warnings;

use WWW::Freshmeat 0.13;
  use Getopt::Long;
  my $user;
  my $date;
  my $fp;
  my $result = GetOptions ("user=s" => \$user,
                           "added_after=s" => \$date, #only projects added after this date
                           "first-page=s" => \ $fp,
                           #Number on front page, name\tvalue\n
  );
die "Please specify user\n" unless $user;

my $fm = WWW::Freshmeat->new;

my $user_p = $fm->retrieve_user('chorny');

my @projects=$user_p->projects();
my @proj=map {$fm->retrieve_project($_)} @projects;
my %fp_num;
if ($fp) {
  open my $fp_in,'<',$fp or die "Cannot open $fp\n";
  while (my $str=<$fp_in>) {
    $str=~s/\s+$//s;
    next unless $str;
    if ($str=~/^\s*([^\t]+)\t([^\t\r\n]+)$/) {
      $fp_num{$1}=$2;
    } else {
      die "Bad string in $fp: '$str'";
    }
  }
}

open my $out,'>','popularity.html';
print $out <<EOT;
<title>Freashmeat popularity data for user '$user'</title>
<style>
table.fm_stat tr td:first-child + td + td,
table.fm_stat tr td:first-child + td + td + td ,
table.fm_stat tr td:first-child + td + td + td + td,
table.fm_stat tr td:first-child + td + td + td + td + td
{
 text-align: right;
}
</style>

<table border=1 class="fm_stat">
 <tr>
  <th>Name</th>
  <th>Creation date</th>
  <th>Record hits</th>
  <th>URL hits</th>
  <th>Subscribers</th>
  <th>Number on front page</th>
 </tr>
EOT

my $total_record_hits=0;
my $total_url_hits=0;
my $total_subscribers=0;
foreach my $project (@proj) {
  if ($date) {
    next if $date ge $project->date_add();
  }
  my %pop=$project->popularity();
  my $fp_p=
   exists $fp_num{$project->name()}?
     $fp_num{$project->name()}:
   exists $fp_num{$project->projectname_short()}?
     $fp_num{$project->projectname_short()}:
   '?';
  $total_record_hits+=$pop{'record_hits'};
  $total_url_hits+=$pop{'url_hits'};
  $total_subscribers+=$pop{'subscribers'};
  print $out "
 <tr>
   <td><a href='http://freshmeat.net/project-stats/view/".$project->{project_id}."/'>".
    $project->name()."</a></td>
   <td>".$project->date_add()."</td>
   <td>$pop{'record_hits'}</td>
   <td>$pop{'url_hits'}</td>
   <td>$pop{'subscribers'}</td>
   <td>$fp_p</td>
 </tr>
\n";
}
  print $out "
 <tr>
   <td>Total</td>
   <td>-</td>
   <td>$total_record_hits</td>
   <td>$total_url_hits</td>
   <td>$total_subscribers</td>
   <td>-</td>
 </tr>
\n";

print $out <<'EOT';
</table>
EOT
