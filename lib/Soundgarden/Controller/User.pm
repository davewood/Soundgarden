package Soundgarden::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Resource::Controller::Resource' }

sub edit_with_password : Method('GET') Method('POST') Chained('base_with_id')
    PathPart('edit_with_password') Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(activate_form_fields => [qw/ password password_repeat /]);
    $c->forward($self->action_for('edit'));
}

1;
