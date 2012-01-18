package Soundgarden::Controller::Song;
use Moose;
use namespace::autoclean;
use JSON qw/to_json/;

BEGIN {
    extends 'CatalystX::Resource::Controller::Resource';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Form';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Edit';
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

sub search : Method('GET') Chained('base') PathPart('search') Args {
    my ( $self, $c, $query ) = @_;

    my $search_params = defined $query ? { name => { -like => "%$query%" } } : {};
    my $song_rs = $c->stash->{songs_rs}->search($search_params);
    my @result;
    while ( my $song = $song_rs->next) {
        push @result, { id => $song->id, name => $song->name };
    }

    $c->res->body(to_json(\@result));
    $c->res->content_type('application/json');
    $c->res->status(200);
}

after 'edit' => sub {
    my ($self, $c) = @_;
    $c->session( redirect_after_edit => $c->req->referer )
        if $c->req->method eq 'GET';
};

override '_redirect' => sub {
    my ($self, $c) = @_;
    if (exists $c->session->{redirect_after_edit}) {
        $c->res->redirect($c->session->{redirect_after_edit});
        delete $c->session->{redirect_after_edit};
    }
};

1;
