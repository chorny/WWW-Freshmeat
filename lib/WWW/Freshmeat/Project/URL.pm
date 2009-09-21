package WWW::Freshmeat::Project::URL;
use Mouse;
use Carp;
has 'url' => (is => 'rw', isa => 'Str', 'builder'=>'_find_url','lazy'=>1);
has 'label' => (is => 'rw', isa => 'Str',required=>1);
has 'redirector' => (is => 'rw', isa => 'Str');
has 'host' => (is => 'rw', isa => 'Str');
has 'www_freshmeat' => (is => 'rw', isa => 'WWW::Freshmeat',required=>1);

no Mouse;

sub _find_url {
  my $self=shift || die;
  croak "No 'redirector' field" unless $self->redirector;
  return $self->www_freshmeat->redir_url($self->redirector);
}

1;
