package Soundgarden::Schema::Result::Song;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/
    InflateColumn::FS
    Core
/);

__PACKAGE__->table('song');
__PACKAGE__->add_columns(
    id => {
        data_type => 'int',
        is_numeric => 1,
        is_auto_increment => 1
    },
    name => {
        data_type => 'varchar',
    },
    'file',
    {
        data_type       => 'varchar',
        is_fs_column    => 1,
        #fs_column_path => '/tmp', # we set this value in config in lib/MyApp.pm
    },
    'file_content_type',
    {
        data_type   => 'varchar',
        size        => 32,
        is_nullable => 0,
    },
);

__PACKAGE__->set_primary_key ('id');

__PACKAGE__->has_many(
    'song_playlists',
    'Soundgarden::Schema::Result::PlaylistSong',
    'song_id',
);

1;
