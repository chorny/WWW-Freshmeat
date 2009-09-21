package WWW::Freshmeat::Project::URL;
use Mouse;
has 'url' => (is => 'rw', isa => 'Str', 'builder'=>'find_url','lazy'=>1);

no Mouse;

sub find_url {
  my $self=shift || die;
}

1;
