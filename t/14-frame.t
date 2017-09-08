use v6;
use Test;
use lib 'lib';
use Log::Async;
plan 6;          # NB: line numbers are hard coded below, modify with care


my @all;
my $out = IO::Handle but role { method say($str) { @all.push: $str }; method flush { } };

logger.send-to($out,
  formatter => -> $m, :$fh {
    $fh.say: "{ $m<frame>.file } { $m<frame>.line } { $m<frame>.code.name }: $m<msg>"
  });

sub foo {
  trace "hello";
  trace "hello 1";
  trace "hello 2";
}

class Foo {
  method bar {
    trace "very";
    trace "nice";
  }
}

foo();
Foo.bar();
trace "world";

logger.done;
@all .= sort;

is @all[0], "t/14-frame.t 17 foo: hello", 'right frame output in sub';
is @all[1], "t/14-frame.t 18 foo: hello 1", 'right frame output in sub';
is @all[2], "t/14-frame.t 19 foo: hello 2", 'right frame output in sub';
is @all[3], "t/14-frame.t 24 bar: very", 'right frame output in method';
is @all[4], "t/14-frame.t 25 bar: nice", 'right frame output in method';
is @all[5], "t/14-frame.t 31 <unit>: world", 'right frame output in main';

