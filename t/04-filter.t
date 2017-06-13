use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 8;

my $last = "my";
logger.add-tap({ $last = $^message<msg> }, :level(TRACE));

trace "name";
sleep 0.1;
is $last, 'name', 'got trace message';

debug 'is';
sleep 0.1;
is $last, 'name', 'debug message not sent to trace log';

warning 'Inigo';
sleep 0.1;
is $last, 'name', 'warning message not sent to trace log';

error 'Montoya';
sleep 0.1;
is $last, 'name', 'error message not sent to trace log';

my $debug-or-error;
my $severe;
my $not-severe;
logger.add-tap({ $debug-or-error ~= $^m<msg> }, level => (DEBUG | ERROR) );
logger.add-tap({ $severe ~= $^m<msg> }, :level(* >= ERROR) );
logger.add-tap({ $not-severe ~= $^m<msg> }, :level(TRACE..INFO) );
info '1';
trace '2';
debug '3';
error '4';
fatal '5';
sleep 0.1;
is $debug-or-error.comb.sort.join, "34", 'filter with junction';
is $severe.comb.sort.join, '45', 'filter with whatever';
is $not-severe.comb.sort.join, '123', 'not severe';

my $cat;
logger.add-tap({ $cat = $^m<msg> }, :msg(rx/cat/));
error 'cat alert';
debug 'dog alog';
sleep 0.1;
is $cat, 'cat alert', 'filtered by msg';

