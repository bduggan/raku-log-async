Log::Async
==========
Thread-safe asynchronous logging using supplies.

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

(start debug 'one')
  .then({ debug 'two' });
(start debug 'buckle')
  .then({ debug 'my shoe' });
sleep 1;

my $when = now + 1;

for ^100 {
     Promise.at($when)
         .then({ debug "come together"})
         .then({ debug "right now"})
         .then({ debug "over me"});
}

logger.send-to("/var/log/hal.errors", :level(ERROR));
error "I'm sorry Dave, I'm afraid I can't do that";
```

Description
===========

`Log::Async` provides asynchronous logging using
the supply and tap semantics of Perl 6.  Log messages
are emitted asynchronously to a supply.  Taps are
only executed by one thread at a time.

The default logger prints the level, timestamp, and
message to stdout.

Exports
=======

Constants (an enum): TRACE DEBUG INFO WARNING ERROR FATAL

Log::Async: A logger instance.

logger: return or create a logger singleton.

set-logger: set a new logger singleton.

trace, debug, info, warning, error, fatal: each of these
takes a single argument: a log message.  The message is
added to the supply of messages.

Log::Async Methods
==========

*add-tap(Code,:$level,:$msgs)*
```
logger.add-tap({ say $^m<msg> ~ '!!!!!' }, :level(FATAL));
logger.add-tap({ $\*ERR.say $^m<msg> }, :level(DEBUG | ERROR));
logger.add-tap({ say "not serious", :level(* < ERROR) });
logger.add-tap({ say "maybe serious", :level(INFO..WARNING) });
logger.add-tap({ say "meow: " ~ $^m<msg> }, :msg(rx/cat/));
```

Add a tap, optionally filtering by the level or by the message.
The level argument is smartmatched against the level.  The message
argument is smartmatched against the message.  The code in the
tap receives a hash with `msg`, `level`, and `when` (a timestamp).

*send-to(Str $filename)*
```
send-to(IO::Handle $handle)
logger.send-to('/tmp/out.log');
```
Add a tap that prints timestamp, level and message to a file or filehandle.

*close-taps;*
```
logger.close-taps
```
Close all the taps.

