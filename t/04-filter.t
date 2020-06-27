use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 10;

my $last = "my";
my $last-channel = Channel.new;
sub wait-for-out {
    react {
        whenever $last-channel  { $last = $_;  done }
        whenever Promise.in(20) { $last = Nil; done }
    }
}

logger.add-tap({ $last-channel.send: $^message<msg> }, :level(TRACE));

trace "name";
wait-for-out;
is $last, 'name', 'got trace message';

debug 'is';
trace "trace1";
wait-for-out;
is $last, 'trace1', 'debug message not sent to trace log';

warning 'Inigo';
trace "trace2";
wait-for-out;
is $last, 'trace2', 'warning message not sent to trace log';

error 'Montoya';
trace "trace3";
wait-for-out;
is $last, 'trace3', 'error message not sent to trace log';

my $debug-or-error = Channel.new;
my $severe = Channel.new;
my $not-severe = Channel.new;
logger.add-tap({ $debug-or-error.send: $^m<msg> }, level => (DEBUG | ERROR) );
logger.add-tap({ $severe        .send: $^m<msg> }, :level(* >= ERROR) );
logger.add-tap({ $not-severe    .send: $^m<msg> }, :level(TRACE..INFO) );
info '1';
trace '2';
debug '3';
error '4';
fatal '5';
error '6';

wait-for-out;
is $last, '2', 'trace messages are still sent';

sub wait-for-channel($channel) {
    gather react {
        my $count = 0;
        whenever $channel { take $_; done if ++$count == 3 }
        whenever Promise.in(20) { done }
    }
}
is (wait-for-channel $debug-or-error), <3 4 6>, 'filter with junction';
is (wait-for-channel $severe        ), <4 5 6>, 'filter with whatever';
is (wait-for-channel $not-severe    ), <1 2 3>, 'not severe';

logger.add-tap({ $last-channel.send: $^message<msg> }, :msg(rx/cat/));
debug 'cat alert1';
debug 'dog alog';
error 'cat alert2';
wait-for-out;
is $last, 'cat alert1', 'filtered by msg';
wait-for-out;
is $last, 'cat alert2', 'filtered by msg';
