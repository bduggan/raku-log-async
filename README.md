Log::Async
==========
Asynchronous logging with a supplies and taps.

[![Build Status](https://travis-ci.org/bduggan/p6-log-async.svg)](https://travis-ci.org/bduggan/p6-log-async)

Synopsis
========

```
use Log::Async;

trace 'how';
debug 'now';
warning 'brown';
info 'cow';
fatal 'ow';

my $when = now + 1;

for ^100 {
     Promise.at($when)
         .then({ debug "come together"})
         .then({ debug "right now"})
         .then({ debug "over me"});
}

logger.send-to("/var/log/hal.errors", :level(ERROR));
error "I'm sorry Dave, I'm afraid I can't do that";

Description
===========

`Log::Async` provides asynchronous logging using
the supply and tap semantics of Perl 6.

The default logger prints the level, timestamp, and
message to stdout.

Subroutines
===========

`logger` returns a logger singleton (a `Log::Async` instance)

`set-logger` sets a new one.

Methods
=======

```
add-tap(Code,:$level,:$msgs)
logger.add-tap({ say $^m<msg> ~ '!!!!!' }, :level(FATAL));
logger.add-tap({ $\*ERR.say $^m<msg> }, :level(DEBUG | ERROR));
logger.add-tap({ say "cat message: " ~ $^m<msg> }, :msg(rx/cat/));
```

Add a tap, optionally filtering by the level or by the message.
The level argument is smartmatched against the level.  The message
argument is smartmatched against the message.  The code receives
a hash with `msg` and `level`.

```
send-to(Str $filename)
send-to(IO::Handle $handle)
logger.send-to('/tmp/out.log');
```
Add a tap that prints messages to a filehandle, or opens a file
and sends message to that file.

```
close-taps;
logger.close-taps
```
Close all the taps.

These log levels are available as constants (for use in filters):
`TRACE DEBUG INFO WARNING ERROR FATAL`

