use v6;
use Test;
use lib 'lib';

plan 2;

use-ok 'Log::Async', "Use Log::Async";

use Log::Async;

cmp-ok Log::Async.^ver, '>', v0.0.0, 'version is > 0.0.0';

diag "Version { Log::Async.^ver }";
diag "Author { Log::Async.^auth }";
