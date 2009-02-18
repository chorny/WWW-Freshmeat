package WWW::Freshmeat;

use 5.008;
use strict;
use warnings;

=head1 NAME

WWW::Freshmeat - automates searches on Freshmeat.net

=head1 VERSION

Version 0.12

=cut

our $VERSION = '0.12';

use XML::Simple qw();

=head1 SYNOPSIS

    use WWW::Freshmeat;

    my $fm = WWW::Freshmeat->new;

    my $project = $fm->retrieve_project('project_id');

    foreach my $p ( @projects, $project ) {
        print $p->name(), "\n";
        print $p->url(), "\n";
        print $p->version(), "\n";
        print $p->description(), "\n";
    }

=cut

package WWW::Freshmeat::Project;

sub new {

    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self = bless shift, $class;
    $self->{www_freshmeat} = shift;
    return $self;
}

foreach my $field ( qw( url_project_page url_homepage projectname_full desc_short desc_full license www_freshmeat projectname_short) ) {
    no strict 'refs';
    *$field = sub {
        my $self = shift;
        my $value = $self->{$field};
        if ( ref($value) && ref($value) eq 'HASH' && !(keys %$value) ) {
            return undef;
        }
        else {
            return $value;
        }
    }
}

sub name        { $_[0]->projectname_full(@_) || $_[0]->projectname_short(@_) } 
sub description { $_[0]->desc_full(@_) || $_[0]->desc_short(@_) } 
sub version     { $_[0]{latest_release}{latest_release_version} }
sub trove_id    { $_[0]{descriminators}{trove_id} }

sub url {
    my $self = shift;
    return $self->{url} if $self->{url};
    my $freshmeat_url = $self->{url_project_page};

    my $url = $self->url_homepage() or return;

    $self->{url} = $self->www_freshmeat()->redir_url($url);
    return $self->{url};
}

sub init_html {
    my $self = shift;
    my $html = shift;
    require HTML::TreeBuilder::XPath;
    $self->{_html}=HTML::TreeBuilder::XPath->new_from_content($html);
}

sub _html_tree {
    my $self = shift;
    if (!$self->{_html}) {
      my $id=$self->projectname_short();
      my $url = "http://freshmeat.net/projects/$id/";
      $self->www_freshmeat()->agent('User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.8.1.19) Gecko/20081201 Firefox/2.0.0.19');
      my $response = $self->www_freshmeat()->get($url);
      my $html = $response->content();
      if ($response->is_success) {
        $self->init_html($html);
      } else {
        die "Could not GET $url (".$response->status_line.", $html)";
      }
    }
    return $self->{_html};
}

sub branches {
    my $self = shift;
    my $tree=$self->_html_tree();
    my $nodes=$tree->findnodes(q{//table/tr/th/b[text()='Branch']/../../following-sibling::tr/td[1]/a});
    my %list;
    while (my $node=$nodes->shift) {
      if ($node->attr('href') =~m#/branches/(\d+)/#) {
        $list{$1}=$node->as_text();
      } else {
        die;
      }
    }
    return %list;
}

our $project_re=qr/[a-z0-9_\-\.]+/;
sub url_list {
    my $self = shift;
    my $real=(@_>0?1:0);
    my $tree=$self->_html_tree();
    my $nodes=$tree->findnodes(q{/html/body/div/table/tr/td/table/tr/td/p/a[@href=~/\/redir/]}); #/
    my %list;
    while (my $node=$nodes->shift) {
      if ($node->attr('href') =~m#/redir/$project_re/\d+/(url_\w+)/#) {
        my $type=$1;
        my $text=$node->as_text();
        if ($text=~/\Q[..]\E/) {
          if ($real) {
            $list{$type}=$self->www_freshmeat()->redir_url('http://freshmeat.net'.$node->attr('href'));
          } else {
            $list{$type}=$node->attr('href');
          }
        } else {
          $list{$type}=$text;
        }
      } else {
        die "bad link:".$node->attr('href');
      }
    }
    return %list;
}

my %popularity_conv=('Record hits'=>'record_hits','URL hits'=>'url_hits','Subscribers'=>'subscribers');
sub popularity {
    my $self = shift;
    my $tree=$self->_html_tree();
    my $nodes=$tree->findnodes(q{/html/body/div[1]/table/tr/td[2]/table/tr[3]/td[3]/table[2]/tr/td/small});
    my %list;
    if (my $node=$nodes->shift) {
      my $text=$node->as_text();
      $text=~s/ / /g;
      my @list=grep {$_} split /<br(?: \/)?>|\s{4}/,$text;
      foreach my $s (@list) {
        $s=~s/^(?:^&nbsp;|\s)+//s;
        $s=~s/\s+$//s;
        #print "F:$s\n";
        if ($s=~/(\w[\w\s]+\w):\s+([\d,]+)/ and exists $popularity_conv{$1}) {
          my $type=$popularity_conv{$1};
          my $num=$2;
          $num=~s/,//g;
          $list{$type}=$num;
        } else {
          die "Cannot find popularity record: '$s'";
        }
        
      }
    } else {
      die "Cannot find popularity data";
    }
    return %list;
}

sub real_author {
    my $self = shift;
    my $tree=$self->_html_tree();
    my $nodes=$tree->findnodes(q{/html/body/div[1]/table/tr/td[2]/table/tr[3]/td[1]/p[2]/b/..});
    my %list;
    if (my $node=$nodes->shift) {
      my $text=$node->as_text;
      $text=~s/^Author:\s+//s;
      $text=~s/\s+\Q[contact developer]\E\s*$//s;
      $text=~s/\s+<[^<>]+>\s*$//s;
      return $text;
    }
}


package WWW::Freshmeat;

use base qw( LWP::UserAgent );

=head1 DESCRIPTION

C<WWW::Freshmeat> derives from C<LWP::UserAgent>, so it accepts all the methods
that C<LWP::UserAgent> does, notably C<timeout>, C<useragent>, C<env_proxy>...

=head2 Methods

=over 4

=item B<retrieve_project> I<STRING>

Query the freshmeat.net site for the project I<STRING> (should be the Freshmeat
ID of the requested project) and returns a C<WWW::Freshmeat::Project> object or
undef if the project entry cannot be found.

=cut

sub retrieve_project {

    my $self = shift;
    my $id   = shift;

    my $url = "http://freshmeat.net/projects-xml/$id/$id.xml";
    my $response = $self->get($url);
    if ($response->is_success) {
      my $xml = $response->content();
      return $self->project_from_xml($xml);
    } else {
      die "Could not GET $url";
    }
}

=item B<project_from_xml> I<STRING>

Receives Freshmeat project XML record and returns a C<WWW::Freshmeat::Project>
object or undef if the project entry cannot be found.

=cut

sub project_from_xml {
    my $self = shift;
    my $xml  = shift;

    if ($xml eq 'Error: project not found.') {
      return undef;
    }

    my $data = XML::Simple::XMLin($xml);

    return WWW::Freshmeat::Project->new($data->{'project'}, $self);
}


=item B<redir_url> I<STRING>

Receives URL and returns URL which it redirects to.

=cut

sub redir_url {
    my $self = shift;
    my $url=shift;
    $self->requests_redirectable([]);
    my $response = $self->get($url) or return $url;
    if ($response->is_redirect) {
      #http://www.perlmonks.org/?node_id=147608
      my $referral_uri = $response->header('Location');
      {
          # Some servers erroneously return a relative URL for redirects,
          # so make it absolute if it not already is.
          local $URI::ABS_ALLOW_RELATIVE_SCHEME = 1;
          my $base = $response->base;
          $referral_uri = $HTTP::URI_CLASS->new($referral_uri, $base)
                      ->abs($base);
      }
      return $referral_uri;
    } else {
      return $url;
    }
}

=back

=head2 WWW::Freshmeat::Project methods

The C<WWW::Freshmeat::Project> object provides some of the fields from the
freshmeat.net entry through the following methods

=over 4

=item B<url_project_page>

=item B<url_homepage>

=item B<projectname_full>

=item B<desc_short>

=item B<desc_full>

=item B<license>

=item B<trove_id>

=item B<projectname_short>

=item B<www_freshmeat>

=back

Additionally, it provides the following "higher-level" methods:

=over 4

=item B<name>

=item B<description>

Return either C<projectname_full> (respectively C<desc_full>) or
C<projectname_short> (respectively C<desc_short>) if the former is empty.

=item B<version>

Returns the version of the latest release.

=item B<url>

C<url_homepage> returns a freshmeat.net URL that redirects to the actual
project's home page. This url() method tries to follow the redirection and
returns the actual homepage URL if it can be found, or the URL to the
freshmeat.net entry for the project.

=item B<branches>

List of branches for project. Returns hash in form of (branch id => branch name).

=item B<popularity>

Freshmeat popularity data for project. Returns hash with keys
record_hits, url_hits, subscribers

=item B<url_list>

Returns list of URLs for project. You may need to use redir_url to get real link
or just pass 1 as argument.

=item B<real_author>

Returns name of author (not maintainer).

=back



=head1 SEE ALSO

L<LWP::UserAgent>.

=head1 AUTHOR

Cedric Bouvier, C<< <cbouvi at cpan.org> >>

=head1 BUGS

This is very alpha code. It does not even support searching!

Please report any bugs or feature requests to
C<bug-www-freshmeat at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Freshmeat>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Freshmeat

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Freshmeat>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Freshmeat>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Freshmeat>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Freshmeat>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Cedric Bouvier.
Copyright 2009 Alexandr Ciornii.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WWW::Freshmeat
