use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 2;

logger.close-taps;

my $message;
logger.add-tap({ sleep 1; $message = $^m<msg> });

info 'hi';
ok !$message, 'no message yet';
sleep 2;
is $message, 'hi', 'now there is a message';

