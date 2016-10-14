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

By default a single tap is created which prints the timestamp,
level and message to stdout.

Exports
=======

**trace, debug, info, warning, error, fatal**: each of these
asynchronously emits a message at that level.

**enum LogLevels**: TRACE DEBUG INFO WARNING ERROR FATAL

**class Log::Async**: Does the real work.

**sub logger**: return or create a logger singleton.

**sub set-logger**: set a new logger singleton.

Log::Async Methods
==========

**add-tap(Code $code,:$level,:$msg)**
```
logger.add-tap({ say $^m<msg> ~ '!!!!!' },  :level(FATAL));
logger.add-tap({ $*ERR.say $^m<msg> },      :level(DEBUG | ERROR));
logger.add-tap({ say "not serious",         :level(* < ERROR) });
logger.add-tap({ say "maybe serious",       :level(INFO..WARNING) });
logger.add-tap({ say "meow: " ~ $^m<msg> }, :msg(rx/cat/));
```

Add a tap, optionally filtering by the level or by the message.
`$code` receives a hash with the keys `msg`, `level`, and `when`
(a timestamp).  `$level` and `$msg` are filters: they will be
smartmatched against the level and msg keys respectively.

**send-to(Str $filename, |args)**
```
send-to(IO::Handle $handle)
logger.send-to('/tmp/out.log');
```
Add a tap that prints timestamp, level and message to a file or filehandle.

Additional args (filters) are sent to add-tap.

**close-taps**
```
logger.close-taps
```
Close all the taps.

