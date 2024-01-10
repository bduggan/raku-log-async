use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 3;

my $when = now + 1;

my @messages;
logger.add-tap({ push @messages, $^message });

my $string;
logger.add-tap({ $string ~= $^message<msg> });

for ^100 {
     Promise.at($when)
         .then({ debug "a" x 10 })
         .then({ debug "b" x 10 })
         .then({ debug "c" x 10 })
         .then({ debug "d" x 10 })
         ;
}

sleep 2;

is +@messages, 400, 'four hundred messages';
is $string.chars, 4000, '4000 characters';
like $string, /^ ('aaaaaaaaaa' | 'bbbbbbbbbb' | 'cccccccccc' | 'dddddddddd' )+ $/,
    'messages are all separate';
