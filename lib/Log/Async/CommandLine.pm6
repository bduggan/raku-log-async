unit module Log::Async::CommandLine;

use Log::Async;

sub parse-log-args {
    my @keepargs;

    my $loglevel = WARNING;
    my $logfh = $*OUT;
    my $silent;
    my $color;
    my $threadid;
    my @logwhere;
    my %modulefilters;

    for @*ARGS {
        when '--silent'|'-q' {
            $silent = True;
        }
        when '-v' {
            $loglevel = INFO;
        }
        when /^'--'(trace|debug|info|warning|error|fatal)$/ {
            $loglevel = Loglevels::{$0.uc};
        }
        when /^'--'(trace|debug|info|warning|error|fatal)
               '=' (.+)$/ {
            %modulefilters{~$1} = Loglevels::{$0.uc};
        }
        when /^'--logfile='(.+)$/ {
            $logfh = open($0.Str, :a);
        }
        when '--logcolor' {
            $color = True;
        }
        when '--logthreadid' {
            $threadid = True;
        }
        when /^'--'logwhere['='(trace|debug|info|warning|error|fatal)]?$/ {
            @logwhere.push: $0 ?? Loglevels::{$0.uc}
                               !! |(TRACE,DEBUG,INFO,WARNING,ERROR,FATAL);
        }
        default {
            push @keepargs, $_;
        }
    }

    my &print-log = $color
      ?? sub ($logfh, $m, $threadid, $logwhere, $loglevel, %modulefilters) {
             state %colors =
                 TRACE   => "\e[35;1m", # magenta
                 DEBUG   => "\e[34;1m", # blue
                 INFO    => "\e[32;1m", # green
                 WARNING => "\e[33;1m", # yellow
                 ERROR   => "\e[31;1m", # red
                 FATAL   => "\e[31;1m"; # red

             my $minlevel = %modulefilters{"$m<where><module>.$m<where><method>"}
                         // %modulefilters{"$m<where><module>"}
                         // $loglevel;

             return unless $m<level> >= $minlevel;

             $logfh.say("$m<when> " ~
                         ("($m<THREAD>.id()) " if $threadid) ~
                         ("($m<where><module>" ~
                             (".$m<where><method>" if $m<where><method>.chars) ~
                             ') ' if $m<level> ∈ $logwhere) ~
                         "%colors{$m<level>}$m<level>.lc()" ~
                         ("\e[0m" unless $m<level> ~~ ERROR|FATAL) ~
                         ": $m<msg>\e[0m");
         }
      !! sub ($logfh, $m, $threadid, $logwhere, $loglevel, %modulefilters) {
             my $minlevel = %modulefilters{"$m<where><module>.$m<where><method>"}
                         // %modulefilters{"$m<where><module>"}
                         // $loglevel;

             return unless $m<level> >= $minlevel;

             $logfh.say("$m<when> " ~
                        ("($m<THREAD>.id()) " if $threadid) ~
                         ("($m<where><module>" ~
                             (".$m<where><method>" if $m<where><method>.chars) ~
                             ') ' if $m<level> ∈ $logwhere) ~
                        "$m<level>.lc(): $m<msg>");
         };

    logger.close-taps;

    unless $silent
    {
        logger.where = True;
        logger.add-tap(-> $m { &print-log($logfh, $m, $threadid, set(@logwhere),
                                          $loglevel, %modulefilters) })
    }

    @*ARGS = @keepargs;
}

INIT {
    parse-log-args;
}

=begin pod

=head1 NAME

Log::Async::CommandLine

=head1 SYNOPSIS

    use Log::Async::CommandLine;

    ./someprogram [--trace]
                  [--debug]
                  [--info | -v]
                  [--warning]  # Default
                  [--error]
                  [--fatal]

    ./someprogram [--silent | -q] # Never output any message, overrides all

    ./someprogram --trace=Foo  # Set log level to trace just for module Foo

    ./someprogram --trace=Foo.method # Set log level for a specific method

    ./someprogram --logcolor # Colorize log output

    ./someprogram --logthreadid # Include thread id in log msg

    ./someprogram --logwhere # Include the module/method in log msg

    ./someprogram --logwhere=trace # Include module/method just for trace

    ./someprogram --logfile=/var/log/mylogfile

=head1 DESCRIPTION

A tiny wrapper around Log::Async to set some basic logging
configuration stuff from the commandline.

It will log either to $*OUT or the specified logfile messages with a
level >= the specified level (or warning by default).

Adding the '--logcolor' option will colorize the log output a little.

Adding '--logthreadid' will include the thread id in the logged message.

Adding '--logwhere' or '--logwhere=<level>' will also log the calling
module/method.

You can also set the log level for a specific module or module+method with
'--trace=Foo' or '--trace=Foo.method'.

You can control things to the right level, for example:

   --info --debug=Foo --trace=Foo.something

will make the general level INFO, but DEBUG within the Foo module, and
TRACE within the something() subroutine or method within Foo.

=end pod
