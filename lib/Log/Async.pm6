enum Loglevels <<:TRACE(1) DEBUG INFO WARNING ERROR FATAL>>;

#-------------------------------------------------------------------------------
# From MARTIMM https://github.com/bduggan/p6-log-async/issues/4
# preparations of code to be provided to log()
sub search-callframe ( $type --> CallFrame ) {

  # Skip callframes for
  # 0  search-callframe(method)
  # 1  log(method)
  # 2  *-message(sub) helper functions
  # 3  if where
  #
  my $fn = 4;
  while my CallFrame $cf = callframe($fn++) {
    # End loop with the program that starts on line 1 and code object is
    # a hollow shell.
    if ?$cf and $cf.line == 1  and $cf.code ~~ Mu {

      $cf = Nil;
      last;
    }

    # Cannot pass sub THREAD-ENTRY either
    if ?$cf and $cf.code.^can('name') and $cf.code.name eq 'THREAD-ENTRY' {

      $cf = Nil;
      last;
    }

    # Try to find a better place instead of dispatch, BUILDALL etc:...
    next if $cf.code ~~ $type and $cf.code.name ~~ m/dispatch/;
    last if $cf.code ~~ $type;
  }

  return $cf;
}

class Log::Async:ver<0.0.1>:auth<github:bduggan> {
    has Bool $.where is rw;
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

        if $!where
        {
            my Str $method = '';
            my Int $line = 0;           # Line number where Message is called
            my Str $file = '';          # File in which that happened
            my Str $module = '';

            my CallFrame $cf = search-callframe(Method)    //
                               search-callframe(Submethod) //
                               search-callframe(Sub)       //
                               search-callframe(Block);

            with $cf {
                $line = .line.Int // 1;
                $file = .file // '';
                $file ~~ s/$*CWD/\./;
                $method = .code.name // '';
                $method = '' if $method ~~ '<unit>';
                $file ~~ /(<-[/(\s]>+)? \s* [\((.+)\)]?$/;
                $module = (~$1 if $1) || (~$0 if $0) || '';
            }

            $m<where> = {:$file, :$line, :$method, :$module};
        }

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
   return { }
}

INIT {
    set-logger(Log::Async.new) unless logger;
}
END {
    Log::Async.instance.done if Log::Async.instance;
}
