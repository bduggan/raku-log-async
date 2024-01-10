use v6;
use Test;

my @testcases =
    # args, keepargs, trace, debug, info, warning, error, fatal, color, thread
    [], [],            False, False, False, True,  True,  True,  False, False,
    [<--trace>],   [], True,  True,  True,  True,  True,  True,  False, False,
    [<--debug>],   [], False, True,  True,  True,  True,  True,  False, False,
    [<--info>],    [], False, False, True,  True,  True,  True,  False, False,
    [<-v>],        [], False, False, True,  True,  True,  True,  False, False,
    [<--warning>], [], False, False, False, True,  True,  True,  False, False,
    [<--error>],   [], False, False, False, False, True,  True,  False, False,
    [<--fatal>],   [], False, False, False, False, False, True,  False, False,
    [<-q>],        [], False, False, False, False, False, False, False, False,
    [<--silent>],  [], False, False, False, False, False, False, False, False,
    [<--logcolor>],[], False, False, False, True, True,   True,  True,  False,

    [<--logthreadid -v>], [],
                       False, False, True,  True, True,   True,  False, True,

    # Don't mess with arguments that aren't mine
    [<foo -q bar mine --this --that>], [<foo bar mine --this --that>],
                       False, False, False, False, False, False, False, False,
;

plan @testcases.elems / 10;

for @testcases -> @args, @keepargs,
                  $trace, $debug, $info, $warning, $error, $fatal,
                  $color, $thread {
    subtest @args.Str, {
        plan 9;

        my $lib = $*PROGRAM.parent.parent.child('lib');
        my $t = $*PROGRAM.parent.parent.child('t');
        my $perl6 = ~$*EXECUTABLE;

        my $out = run($perl6,"-I$lib,$t", ~$t.child('command-line-test.pl'),
                      |@args, :out).out.slurp-rest;

        like $out, (@keepargs.elems
                    ?? /ARGS: {@keepargs.join(',')}/
                    !! /ARGS: /), 'Right ARGS';

        if $trace {
            like $out, /trace/, 'TRACE logged';
        } else {
            unlike $out, /trace/, 'TRACE not logged';
        }

        if $debug {
            like $out, /debug/, 'DEBUG logged';
        } else {
            unlike $out, /debug/, 'DEBUG not logged';
        }

        if $info {
            like $out, /info/, 'INFO logged';
        } else {
            unlike $out, /info/, 'INFO not logged';
        }

        if $warning {
            like $out, /warning/, 'WARNING logged';
        } else {
            unlike $out, /warning/, 'WARNING not logged';
        }

        if $error {
            like $out, /error/, 'ERROR logged';
        } else {
            unlike $out, /error/, 'ERROR not logged';
        }

        if $fatal {
            like $out, /fatal/, 'FATAL logged';
        } else {
            unlike $out, /fatal/, 'FATAL not logged';
        }

        if $color && $fatal {
            like $out, /\e\[\d\d\;1m/, 'Colorized';
        } else {
            unlike $out, /\e\[\d\d\;1m/, 'Not Colorized';
        }

        if $thread  {
            like $out, /\(\d+\)/, 'Thread ID';
        } else {
            unlike $out, /\(\d+\)/, 'No Thread ID';
        }

    }
}
