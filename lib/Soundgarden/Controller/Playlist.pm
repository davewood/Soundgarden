package Soundgarden::Controller::Playlist;
use Moose;
use namespace::autoclean;

BEGIN { 
    extends 'CatalystX::Resource::Controller::Resource';
    with 'CatalystX::Resource::TraitFor::Controller::Resource::Show';
}

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

sub remove_song : Method('POST') Chained('base_with_id') PathPart('remove_song') Args(1) {
    my ( $self, $c, $song_id ) = @_;

    my $playlist = $c->stash->{playlist};

    my $playlist_song = $playlist->playlist_songs->search({ song_id => $song_id })->first;
    if (!$playlist_song) {
        $c->res->body('Song with id ' . $song_id . ' does not exist in playlist.');
        $c->res->status(404);
        $c->detach;
    }

    $c->res->body($playlist_song->song->name . " removed from playlist.");
    $playlist_song->delete;
    $c->res->status(200);
}

after "show" => sub {
    my ( $self, $c ) = @_;
    $c->log->debug("foo");
    $c->stash(
        no_nav => 1,
        playlists => [ $c->stash->{playlists_rs}->all ],
    );
};

1;
