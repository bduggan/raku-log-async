
use Test;
use lib 'lib';
use Log::Async::Context;

plan 5;

ok 1, 'no compilation errors';

my $ctx = Log::Async::Context.new.generate;
my $line = $?LINE - 1;

ok $ctx, 'contructor';

like $ctx.file, / { $?FILE } $$/, "current file ($?FILE)";
is $ctx.line, $line, "right line ($line)";

my @stack;

class SomeClass {
  method some-method {
    @stack.unshift("line $?LINE"); return Log::Async::Context.new.generate.stack;
  }
}

sub some-sub {
  @stack.unshift("line $?LINE"); return SomeClass.some-method;
}
@stack.unshift("line $?LINE"); my @trace = some-sub;
my @trace-strings = @trace.map( -> $s {"line {$s.line}"} );
is-deeply @stack, @trace-strings, 'stack trace looks good';
