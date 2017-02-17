use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 2;

my $out = "";
$*OUT = IO::Handle but role { method say($arg) { $out ~= $arg } };
set-logger(Log::Async.new);

info 'first';
info 'second';

logger.done;

like $out, /first/, 'found first in output';
like $out, /second/, 'found second in output';
