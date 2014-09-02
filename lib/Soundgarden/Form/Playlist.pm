package Soundgarden::Form::Playlist;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has '+item_class' => ( default => 'Playlist' );
sub build_form_element_class { ['container' ] }

has_field 'name' => (
    type => 'Text',
    required => 1,
    size => 30,
    unique => 1,
);

has_field 'submit' => ( type => 'Submit', value => 'Submit' );

no HTML::FormHandler::Moose;
1;
