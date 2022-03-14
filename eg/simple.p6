#!/usr/bin/env raku

use Log::Async;
logger.send-to($*OUT);

trace 'how';
debug 'now';
warning 'brown';
info 'cow';
fatal 'ow';
