use v6;
use Test;
use Log::Async;

plan 7;

logger.close-taps;
my $last = "my";
logger.add-tap({ $last = $^message<msg> }, :level(TRACE));

trace "name";
is $last, 'name', 'got trace message';

debug 'is';
is $last, 'name', 'debug message not sent to trace log';

warning 'Inigo';
is $last, 'name', 'warning message not sent to trace log';

error 'Montoya';
is $last, 'name', 'error message not sent to trace log';

my $debug-or-error;
my $severe;
logger.add-tap({ $debug-or-error ~= $^m<msg> }, level => (DEBUG | ERROR) );
logger.add-tap({ $severe ~= $^m<msg> }, level => (* >= ERROR) );
info '1';
trace '2';
debug '3';
error '4';
fatal '5';
is $debug-or-error, "34", 'filter with junction';
is $severe, '45', 'filter with whatever';

my $cat;
logger.add-tap({ $cat = $^m<msg> }, :msg(rx/cat/));
error 'cat alert';
debug 'dog alog';
is $cat, 'cat alert', 'filtered by msg';

