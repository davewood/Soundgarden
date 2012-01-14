package Soundgarden::Controller::Song;
use Moose;
use namespace::autoclean;

BEGIN {
    extends 'CatalystX::Resource::Controller::Resource';
    with 'Catalyst::TraitFor::Controller::Sendfile';
}

sub edit_with_file : Method('GET') Method('POST') Chained('base_with_id')
    PathPart('edit_with_file') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(activate_form_fields => [qw/ file /]);
    $c->forward($self->action_for('edit'));
}

sub file : Chained('base_with_id') PathPart('file') Args(0) {
    my ( $self, $c ) = @_;
    my $file = $c->stash->{song}->file;
    my $content_type = $c->stash->{song}->file_content_type;
    $self->sendfile($c, $file, $content_type);
}

1;
