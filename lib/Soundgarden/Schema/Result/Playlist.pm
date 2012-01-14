package Soundgarden::Schema::Result::Playlist;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table('playlist');
__PACKAGE__->add_columns(
    id => {
        data_type => 'int',
        is_numeric => 1,
        is_auto_increment => 1
    },
    name => {
        data_type => 'varchar',
    },
);

__PACKAGE__->set_primary_key ('id');

1;
