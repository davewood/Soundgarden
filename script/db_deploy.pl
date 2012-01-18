#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Soundgarden::Schema;

my $schema = Soundgarden::Schema->connect(
            'dbi:SQLite:dbname=soundgarden.db'
    ) or die "Unable to connect\n";


say "Enter 'Y' to deploy the schema. This will delete all data in soundgarden.db";
my $ui = <>;
chomp $ui;

if ($ui eq 'Y') {
    $schema->deploy({ add_drop_table => 1 });

    my $user = $schema->resultset('User')->create({ name => "admin", password => "foo" });

    my @rolenames = qw/
        can_list_users
        can_create_users
        can_edit_users
        can_delete_users
    /;

    for my $rolename (@rolenames) {
        my $role = $schema->resultset('Role')->create({ name => $rolename });
        $user->add_to_roles($role);
    }
}
else {
    say "schema deployment aborted.";
    exit;
}
