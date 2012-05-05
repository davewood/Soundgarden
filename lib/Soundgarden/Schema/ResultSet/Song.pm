package Soundgarden::Schema::ResultSet::Song;

use strict;
use warnings;
use 5.010;
use base 'DBIx::Class::InflateColumn::FS::ResultSet';

sub filter_unused {
    my $self = shift;
    return $self->search(
        {
            'me.id' => { -not_in => $self->result_source->schema->resultset('PlaylistSong')->get_column('song_id')->as_query },
        },
    );
}

1;
