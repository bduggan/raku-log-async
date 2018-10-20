#!/usr/bin/env perl6

=begin pod
Run this from the upper directory using:

    perl6 -Ilib eg/json.p6 | jq "."

You don't need to have C<jq> installed; if you do, you'll get nicely formatted JSON output
=end pod

use Log::Async;
use JSON::Fast;

sub json-formatter ( $m, :$fh ) {
    $fh.say: to-json
        $m<level msg when>:kv.Hash
}

logger.send-to($*OUT, formatter => &json-formatter );

trace 'innie';
debug 'minnie';
warning 'moe';
info 'oe';
fatal 'e';
