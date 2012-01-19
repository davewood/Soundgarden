package Soundgarden::Form::Song;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';
use List::MoreUtils qw/ any /;

has '+item_class' => ( default => 'Song' );
has '+css_class' => ( default => 'container' );
has '+enctype' => ( default => 'multipart/form-data');

has 'upload_fields' => (
    is          => 'ro',
    isa         => 'ArrayRef',
    lazy_build  => 1,
);
sub _build_upload_fields {
    return [qw/ file /];
}

has_field 'name' => (
    type => 'Text',
    required => 1,
    size => 10,
    unique => 1,
);

has_field 'file' => ( 
    type => 'Upload',
    required => 1,
    max_size => 25000000,
    inactive    => 1,
);

has_field 'edit_with_file' => (
    type        => 'Display',
    inactive    => 1,
);
sub html_edit_with_file {
    my ( $self, $field ) = @_;
    my $song_id = $self->item->id;
    # TODO: create URI with c->uri_for ...
    return qq{<label class="label">File: </label></td><td><a class="button" href="/songs/$song_id/edit_with_file">edit</a></td>};
}

# make sure the file has a valid file extension
sub validate_file {
    my ( $self, $field ) = @_;
    my @file_extensions = qw/ mp3 /;
    my $ext = substr($field->value->basename, -4);
    $field->add_error("File must be a mp3 file. (not " . $field->value->basename . ")")
        unless any { ".$_" eq lc($ext) } @file_extensions;
}

after 'validate' => sub {
    my $self = shift;

    for my $upload_field (@{$self->upload_fields}) {
        my $field = $self->field($upload_field);
        next if $field->is_inactive;
        next if $field->has_errors;

        # store content_type sent by user client
        my $upload = $self->params->{$upload_field};

        # for each upload field we expect a content_type field
        # e.g.: file => file_content_type
        my $content_type_field = $upload_field . '_content_type';
        $self->item->$content_type_field($upload->{type});

        # DBIx::Class::InflateColumn::FS expects { upload => $filehandle }
        # instead of { upload => $catalyst_request_upload }
        $field->value($field->value->fh);
    }
};

has_field 'submit' => ( type => 'Submit', value => 'Submit' );

no HTML::FormHandler::Moose;
1;
