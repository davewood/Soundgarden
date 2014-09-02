package Soundgarden::Form::User;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Table';

has '+item_class' => ( default => 'User' );
sub build_form_element_class { ['container' ] }

has_field 'name' => (
    type => 'Text',
    required => 1,
    unique => 1,
    size => 10,
);

has_field 'password' => (
    type => 'Password',
    required => 1,
    size => 10,
    inactive => 1,
);

has_field 'password_repeat' => (
    type => 'PasswordConf',
    required => 1,
    size => 10,
    noupdate => 1,
    inactive => 1,
);

has_field 'edit_with_password' => (
    type => 'Display',
    inactive => 1,
);
sub html_edit_with_password {
    my ( $self, $field ) = @_;
    my $user_id = $self->item->id;
    # TODO: create URI with c->uri_for ...
    return qq{<label class="label">Password: </label></td><td><a class="button" href="/users/$user_id/edit_with_password">edit</a></td>};
}

has_field 'roles' => (
    type => 'Multiple',
    widget => 'checkbox_group',
);

has_field 'submit' => ( type => 'Submit', value => 'Submit' );

no HTML::FormHandler::Moose;
1;
