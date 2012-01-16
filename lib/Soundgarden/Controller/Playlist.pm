package Soundgarden::Controller::Playlist;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Resource::Controller::Resource' }

sub move_song_to_pos : Method('POST') Chained('base_with_id') PathPart('move_song_to_pos') Args(2) {
    my ( $self, $c, $song_id, $pos ) = @_;

    my $playlist = $c->stash->{playlist};
    my $count = $playlist->playlist_songs->count;

    if ( $pos <= 0 || $pos > $count) {
        $c->res->body('Invalid position in playlist.');
        $c->res->status(400);
        $c->detach;
    }

    my $playlist_song = $playlist->playlist_songs->search({ song_id => $song_id })->first;
    if (!$playlist_song) {
        $c->res->body('Song with id ' . $song_id . ' does not exist in playlist.');
        $c->res->status(404);
        $c->detach;
    }

    $playlist_song->move_to($pos);
    $c->res->body($playlist_song->song->name . " moved to position $pos.");
    $c->res->status(200);
}

sub add_song_at_pos : Method('POST') Chained('base_with_id') PathPart('add_song_at_pos') Args(2) {
    my ( $self, $c, $song_id, $pos ) = @_;

    my $playlist = $c->stash->{playlist};

    my $playlist_song = $playlist->playlist_songs->search({ song_id => $song_id })->first;
    if ($playlist_song) {
        $c->res->body('Song with id ' . $song_id . ' already exists.');
        $c->res->status(400);
        $c->detach;
    }

    my $song = $c->model('DB::Song')->find($song_id);
    if (!$song) {
        $c->res->body('Song with id ' . $song_id . ' does not exist.');
        $c->res->status(404);
        $c->detach;
    }

    $playlist->add_to_songs($song);
    $c->forward('move_song_to_pos', [ $song_id, $pos ]);
    $c->res->body($song->name . " added to playlist at position $pos.");
    $c->res->status(200);
}

sub auto : Private {
    my ( $self, $c ) = @_;
    # do not display navigation menu
    $c->stash(no_nav => 1)
        if $c->action->name eq 'show';
    1;
}

1;
