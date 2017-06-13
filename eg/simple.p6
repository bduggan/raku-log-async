#!/usr/bin/env perl6

use Log::Async;
logger.send-to($*OUT);

trace 'how';
debug 'now';
warning 'brown';
info 'cow';
fatal 'ow';
