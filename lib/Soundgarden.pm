package Soundgarden;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# ABSTRACT: A collaborative music listening service

=head1 DESCRIPTION

Upload songs and create playlists shared with all other users.
At logintime you can choose between 'play' and 'edit' mode.

Mode 'play' only displays playlists you can listen to.

In 'edit' mode you can create/edit/delete playlists and songs.

=head1 INSTALLATION

creates a default user 'admin' password 'foo'
    ./script/db_deploy.pl

=head2 X-Sendfile / X-Accel-Redirect
If you deploy with Apache you'll need the X-Sendfile module.
Nginx users need to configure X-Accel-Redirect.

=cut

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    +CatalystX::SimpleLogin
    Authentication
    ConfigLoader
    Static::Simple
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Unicode::Encoding
    +CatalystX::Resource
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in soundgarden.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Soundgarden',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    session                  => { flash_to_stash => 1 },
    encoding                 => 'UTF-8',
    'Plugin::Authentication' => {
        default => {
            store => {
                class         => 'DBIx::Class',
                user_model    => 'DB::User',
                role_relation => 'roles',
                role_field    => 'name',
            },
            credential => {
                class          => 'Password',
                password_field => 'password',
                password_type  => 'self_check',
            },
        },
    },
    'Controller::Login' => {
        traits => [qw/ -RenderAsTTTemplate /],
        login_form_args => {
            field_list => [
                '+remember' => { inactive => 1, required => 0 },
                '+username' => { size     => 10 },
                '+password' => { size     => 10 },

                # hide default submit button
                # add submit buttons for play and edit mode
                '+submit'   => { inactive => 1 },
                'submit_play' => { type => 'Submit' },
                'submit_edit' => { type => 'Submit' },
            ],
            authenticate_username_field_name => 'name',
        },
    },
    'View::HTML' => {
        INCLUDE_PATH       => [ __PACKAGE__->path_to( 'root', 'templates' ) ],
        WRAPPER            => 'wrapper.tt',
        ENCODING           => 'UTF-8',
        TEMPLATE_EXTENSION => '.tt',
        render_die         => 1,
    },
    'Model::DB' => {
        schema_class => 'Soundgarden::Schema',
        fs_path      => __PACKAGE__->path_to( qw/ root files / ),
        connect_info => {
            dsn            => 'dbi:SQLite:dbname=' . __PACKAGE__->path_to( qw/  soundgarden.db / ),
            sqlite_unicode => 1,
        }
    },
    'Controller::User' => {
        resultset_key          => 'users_rs',
        resources_key          => 'users',
        resource_key           => 'user',
        form_class             => 'Soundgarden::Form::User',
        model                  => 'DB::User',
        redirect_mode          => 'list',
        traits                 => [qw/ -Show /],
        activate_fields_create => [qw/ password password_repeat /],
        activate_fields_edit   => [qw/ edit_with_password /],
        actions                => {
            base => {
                Does     => 'NeedsLogin',
                PathPart => 'users',
            },
            list => {
                Does         => 'ACL',
                RequiresRole => 'can_list_users',
                ACLDetachTo  => '/denied',
            },
            create => {
                Does         => 'ACL',
                RequiresRole => 'can_create_users',
                ACLDetachTo  => '/denied',
            },
            edit => {
                Does         => 'ACL',
                RequiresRole => 'can_edit_users',
                ACLDetachTo  => '/denied',
            },
            delete => {
                Does         => 'ACL',
                RequiresRole => 'can_delete_users',
                ACLDetachTo  => '/denied',
            },
        },
    },
    'Controller::Song' => {
        resultset_key          => 'songs_rs',
        resources_key          => 'songs',
        resource_key           => 'song',
        form_class             => 'Soundgarden::Form::Song',
        model                  => 'DB::Song',
        redirect_mode          => 'list',

        # the Create,Edit and Form trait are manually included in Controller:Song
        traits                 => [qw/ -Create -Edit -Form -Delete -Show -List MergeUploadParams /],

        activate_fields_create => [qw/ file /],
        activate_fields_edit   => [qw/ edit_with_file /],
        actions                => {
            base => {
                Does     => 'NeedsLogin',
                PathPart => 'songs',
            },
        },
    },
    'Controller::Playlist' => {
        resultset_key          => 'playlists_rs',
        resources_key          => 'playlists',
        resource_key           => 'playlist',
        form_class             => 'Soundgarden::Form::Playlist',
        model                  => 'DB::Playlist',
        redirect_mode          => 'show',

        # remove Show trait here and include it manually
        # in Soundgarden::Controller::Playlist because else
        # method modifier "after => 'show'" does not work
        traits                 => [qw/ -Show -List -Delete /],

        actions                => {
            base => {
                Does     => 'NeedsLogin',
                PathPart => 'playlists',
            },
        },
    },
    #'CatalystX::Resource' => { controllers => [qw/ /] },
);

# Start the application
__PACKAGE__->setup();

1;
