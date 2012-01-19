package Soundgarden::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::SimpleLogin::Controller::Login'; }

after 'login' => sub {
    my ($self, $c) = @_;
    if ($c->user_exists && defined $self->login_form->field('submit_edit')->input) {
        $c->session(edit => 1);
    }
    else {
        $c->session(edit => 0);
    }
};

__PACKAGE__->meta->make_immutable;

1;
