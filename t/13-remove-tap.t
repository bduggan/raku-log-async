use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 1;

my @lines;
my $out = IO::Handle but role { method say($arg) { @lines.push: $arg } };

logger.close-taps;
my $one = logger.send-to($out, formatter => -> $m, :$fh { @lines.push: "one" } );
my $two = logger.send-to($out, formatter => -> $m, :$fh { @lines.push: "two" } );
my $three = logger.send-to($out, formatter => -> $m, :$fh { @lines.push: "three" } );
logger.remove-tap($two);

info "hello";

is-deeply @lines, [ "one", "three" ], "two out of three taps still there";
