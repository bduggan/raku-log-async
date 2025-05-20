#!/usr/bin/env raku

use Log::Async <use-args>;

sub MAIN(Str $arg,
:$foo #= this is foo
) {
  info 'hi';
  debug 'there';
  trace 'tracer';
  warning 'this is a warning';
  info 'just fyi';
  fatal 'just a flesh wound';
}
