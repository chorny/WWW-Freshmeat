package WWW::Freshmeat::Project::URL;
use Mouse;
has 'url' => (is => 'rw', isa => 'Str', 'builder'=>'find_url','lazy'=>1);
has 'label' => (is => 'rw', isa => 'Str',required=>1);
has 'redirector' => (is => 'rw', isa => 'Str');
has 'host' => (is => 'rw', isa => 'Str');
has 'www_freshmeat' => (is => 'rw', isa => 'WWW::Freshmeat',required=>1);

no Mouse;

sub find_url {
  my $self=shift || die;
}

1;
