#!/usr/bin/env perl6

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
