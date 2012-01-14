package Soundgarden::Form::Playlist;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has '+item_class' => ( default => 'Playlist' );

has_field 'name' => (
    type => 'Text',
    required => 1,
    size => 10,
);

has_field 'submit' => ( type => 'Submit', value => 'Submit' );

no HTML::FormHandler::Moose;
1;
