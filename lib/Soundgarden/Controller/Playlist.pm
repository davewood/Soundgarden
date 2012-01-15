package Soundgarden::Controller::Playlist;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Resource::Controller::Resource' }

sub auto : Private {
    my ( $self, $c ) = @_;
    # do not display navigation menu
    $c->stash(no_nav => 1)
        if $c->action->name eq 'show';
    1;
}

1;
