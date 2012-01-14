use strict;
use warnings;

use Soundgarden;

my $app = Soundgarden->apply_default_middlewares(Soundgarden->psgi_app);
$app;

