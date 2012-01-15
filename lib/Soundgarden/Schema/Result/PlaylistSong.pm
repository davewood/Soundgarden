package Soundgarden::Schema::Result::PlaylistSong;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('playlist_song');
__PACKAGE__->add_columns(
    'id',
    {
        data_type => 'integer',
        is_nullable => 0,
        is_auto_increment => 1,
        is_numeric => 1,
    },
    'playlist_id',
    {
        data_type => 'integer',
        is_nullable => 0,
        is_numeric => 1,
    },
    'song_id',
    {
        data_type => 'integer',
        is_numeric => 1,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( [qw/playlist_id song_id/] );

__PACKAGE__->belongs_to(
    'playlist',
    'Soundgarden::Schema::Result::Playlist',
    'playlist_id'
);

__PACKAGE__->belongs_to(
    'song',
    'Soundgarden::Schema::Result::Song',
    'song_id'
);

1;
