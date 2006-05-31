package WWW::Freshmeat;

use warnings;
use strict;

=head1 NAME

WWW::Freshmeat - automates searches on Freshmeat.net

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use XML::Simple qw();

=head1 SYNOPSIS

    use WWW::Freshmeat;

    my $fm = new WWW::Freshmeat;

    my $project = $fm->retrieve_project('project_id');

    foreach ( @projects, $project ) {
        print $_->name(), "\n";
        print $_->url(), "\n";
        print $_->version(), "\n";
        print $_->description(), "\n";
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

foreach my $field ( qw( url_project_page url_homepage projectname_full desc_short desc_full license www_freshmeat ) ) {
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

sub url {

    my $self = shift;
    return $self->{url} if $self->{url};
    my $freshmeat_url = $self->{url_project_page};

    my $url = $self->url_homepage() or return;

    my $res = $self->www_freshmeat()->get($url) or return $self->{url} = $freshmeat_url;
    my $req = $res->request() or return $self->{url} = $freshmeat_url;
    my $uri = $req->uri() or return $self->{url} = $freshmeat_url;
    return $self->{url} = $uri->as_string();
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
dies if the project entry cannot be found.

=cut

sub retrieve_project {

    my $self = shift;
    my $id   = shift;

    my $url = "http://freshmeat.net/projects-xml/$id/$id.xml";
    my $res = $self->get($url) or die "Could not GET $url";
    my $xml = $res->content();

    my $data = XML::Simple::XMLin($xml);

    return WWW::Freshmeat::Project->new($data->{'project'}, $self);
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

=item B<www_freshmeat>

=back

Additionnally, it provides the following "higher-level" methods:

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

Copyright 2006 Cedric Bouvier, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WWW::Freshmeat
