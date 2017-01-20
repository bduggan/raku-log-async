use v6;
use Test;

my @testcases =
# args, keepargs,
# trace, debug, info,  warning, error, fatal, color
[], [], 
  False, False, False, True,    True,  True,  False,

[<--trace>], [],
  True,  True,  True,  True,    True,  True,  False,

[<--debug>], [],
  False, True,  True,  True,    True,  True,  False,

[<--info>], [],
  False, False, True,  True,    True,  True,  False,

[<-v>], [],
  False, False, True,  True,    True,  True,  False,

[<--warning>], [],
  False, False, False, True,    True,  True,  False,

[<--error>], [],
  False, False, False, False,   True,  True,  False,

[<--fatal>], [],
  False, False, False, False,   False, True,  False,

[<-q>], [],
  False, False, False, False,   False, False, False,

[<--silent>], [],
  False, False, False, False,   False, False, False,

# Don't mess with arguments that aren't mine
[<foo -q bar mine --this --that>], [<foo bar mine --this --that>],
  False, False, False, False,   False, False, False,

[<--logcolor>], [],
  False, False, False, True,    True,  True,  True,
;

plan @testcases.elems / 9;

for @testcases -> @args, @keepargs,
                  $trace, $debug, $info, $warning, $error, $fatal, $color
{
    subtest @args.Str,
    {
        plan 8;
        diag @args;

        my $out = run('perl6', 't/command-line-test.pl',
                      |@args, :out).out.slurp-rest;

        like $out, (@keepargs.elems 
                    ?? /ARGS: {@keepargs.join(',')}/
                    !! /ARGS: /), 'Right ARGS';

        if $trace
        {
            like $out, /trace/, 'TRACE logged';
        }
        else
        {
            unlike $out, /trace/, 'TRACE not logged';
        }

        if $debug
        {
            like $out, /debug/, 'DEBUG logged';
        }
        else
        {
            unlike $out, /debug/, 'DEBUG not logged';
        }

        if $info
        {
            like $out, /info/, 'INFO logged';
        }
        else
        {
            unlike $out, /info/, 'INFO not logged';
        }

        if $warning
        {
            like $out, /warning/, 'WARNING logged';
        }
        else
        {
            unlike $out, /warning/, 'WARNING not logged';
        }

        if $error
        {
            like $out, /error/, 'ERROR logged';
        }
        else
        {
            unlike $out, /error/, 'ERROR not logged';
        }

        if $fatal
        {
            like $out, /fatal/, 'FATAL logged';
        }
        else
        {
            unlike $out, /fatal/, 'FATAL not logged';
        }

        if $color && $fatal
        {

            like $out, /\e\[\d\d\;1m/, 'Colorized';
        }
        else
        {
            unlike $out, /\e\[\d\d\;1m/, 'Not Colorized';
        }
    }
}
