enum Loglevels <<:TRACE(1) DEBUG INFO WARNING ERROR FATAL>>;

class Log::Async:ver<0.0.1>:auth<github:bduggan> {
    has $.source = Supplier.new;
    has Tap @.taps;
    has Supply $.messages;

    my $instance;
    method instance {
        return $instance;
    }
    method set-instance($i) {
        $instance = $i;
    }

    method new {
        my $self = callsame;
        $self.send-to($*OUT);
        $self;
    }

    method close-taps {
        .close for @.taps;
    }

    method add-tap(Code $c, :$level, :$msg) {
        $!messages //= self.source.Supply;
        my $supply = $!messages;
        $supply = $supply.grep( { $^m<level> ~~ $level }) with $level;
        $supply = $supply.grep( { $^m<msg> ~~ $msg }) with $msg;
        @.taps.push: $supply.act($c);
    }

    multi method send-to(IO::Handle $fh, |args) {
        self.add-tap: -> $m {
            $fh.say: "{ $m<when> } ({$m<THREAD>.id}) { $m<level>.lc }: { $m<msg> }",
        }, |args
    }

    multi method send-to(Str $path, |args) {
        my $fh = open($path,:a) or die "error opening $path";
        self.send-to($fh, |args);
    }

    method log(:$msg, Loglevels :$level, :$when = DateTime.now) {
        my $m = { :$msg, :$level, :$when, :$*THREAD };
        (start $.source.emit($m))
          .then({ say $^p.cause unless $^p.status == Kept });
    }

    method done() {
        start { sleep 0.1; $.source.done };
        $.source.Supply.wait;
    }
}

sub set-logger($new) is export {
    Log::Async.set-instance($new);
}
sub logger is export {
    Log::Async.instance;
}

sub trace($msg)   is export { logger.log( :$msg, :level(TRACE) ); }
sub debug($msg)   is export { logger.log( :$msg, :level(DEBUG) ); }
sub info($msg)    is export { logger.log( :$msg, :level(INFO) );  }
sub error($msg)   is export { logger.log( :$msg, :level(ERROR) ); }
sub warning($msg) is export { logger.log( :$msg, :level(WARNING) ); }
sub fatal($msg)   is export { logger.log( :$msg, :level(FATAL) ); }

sub EXPORT {
   set-logger(Log::Async.new) unless logger;
   return { }
}

END {
    Log::Async.instance.done;
}
