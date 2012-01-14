package Soundgarden::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    # do not display navigation menu
    $c->stash(no_nav => 1);
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->stash( error_msg => 'Page not found' );
    $c->detach('/error404');
}

sub denied :Private {
    my ($self, $c) = @_;
    $c->stash(error_msg => 'access denied');
    $c->res->status('403');
    $c->detach('/error');
}

sub error404 : Private {
    my ( $self, $c ) = @_;
    unless ($c->stash->{error_msg}) {
        $c->stash(error_msg => 'Page not found. 404');
    }
    $c->res->status(404);
    $c->detach('/error');
}

sub error : Private {
    my ( $self, $c ) = @_;
    unless ($c->stash->{error_msg}) {
        $c->stash(error_msg => 'Unkown error.');
    }
    $c->stash(template => 'error.tt');
}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

1;
