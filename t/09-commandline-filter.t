use v6;
use Test;

plan 21;

my $lib = $*PROGRAM.parent.parent.child('lib');
my $t = $*PROGRAM.parent;
my $perl6 = ~$*EXECUTABLE;

sub run-test(*@args) {
    run($perl6, "-I$lib,$t", 't/command-line-test.pl',
        |@args, :out).out.slurp-rest;
}

my $out = run-test(<--testsubs>);
 
unlike $out, /:s trace\: sub_a/, 'Sub No trace';
unlike $out, /:s debug\: sub_a/, 'Sub No debug';
unlike $out, /:s info\: sub_a/, 'Sub No info';
like $out, /:s warning\: sub_a/, 'Sub Warning';
like $out, /:s error\: sub_a/, 'Sub Error';
like $out, /:s fatal\: sub_a/, 'Sub Fatal';

$out = run-test(<--logwhere --testsubs>);

like $out, /:s \(command\-line\-test.pl\) warning\: log warning/, 'where main';
like $out, /:s \(TestModule.sub_a\) warning\: sub_a/, 'where sub_a';
like $out, /:s \(TestModule.sub_b\) warning\: sub_b/, 'where sub_b';

$out = run-test(<--logwhere=error --testsubs>);

unlike $out, /:s \(command\-line\-test.pl\) warning\: log warning/,
    'no where main';
unlike $out, /:s \(TestModule.sub_a\) warning\: sub_a/, 'no where sub_a';
unlike $out, /:s \(TestModule.sub_b\) warning\: sub_b/, 'no where sub_b';

like $out, /:s \(command\-line\-test.pl\) error\: log error/, 'where main';
like $out, /:s \(TestModule.sub_a\) error\: sub_a/, 'where sub_a';
like $out, /:s \(TestModule.sub_b\) error\: sub_b/, 'where sub_b';

$out = run-test(<--fatal --info=TestModule --debug=TestModule.sub_b --testsubs>);

unlike $out, /:s error\: log error/, 'main no error';
like $out, /:s fatal\: log fatal/, 'main fatal';

unlike $out, /:s debug\: sub_a/, 'sub_a no debug';
like $out, /:s info\: sub_a/, 'sub_a info';

unlike $out, /:s trace\: sub_b/, 'sub_b no trace';
like $out, /:s debug\: sub_b/, 'sub_b debug';
