unit module Log::CommandLine;

use Log::Async;
use Terminal::ANSIColor;

sub parse-log-args
{
    my @keepargs;

    my $loglevel = WARNING;
    my $logfh = $*OUT;
    my $color = False;

    for @*ARGS
    {
        when /^'--'(trace|debug|info|warning|error|fatal)$/
        {
            $loglevel = Loglevels::{$0.uc};
        }
        when /^'--logfile='(.+)$/
        {
            $logfh = open($0.Str, :a);
        }
        when '--logcolor'
        {
            $color = True;
        }
        default
        {
            push @keepargs, $_;
        }
    }

    logger.close-taps;
    logger.add-tap(($color ?? -> $m
                   {
                       state %colors = 
                           TRACE   => 'bold magenta',
                           DEBUG   => 'bold blue',
                           INFO    => 'bold green',
                           WARNING => 'bold yellow',
                           ERROR   => 'bold red',
                           FATAL   => 'bold red';

                       $logfh.say($m<when> ~ ' ' ~
                           color(%colors{$m<level>}) ~ $m<level>.lc ~
                           (color('reset') unless $m<level> ~~ ERROR|FATAL) ~
                           ': ' ~ $m<msg> ~ color('reset'));
                   }
                   !! -> $m
                   {
                       $logfh.say("$m<when> $m<level>.lc(): $m<msg>");
                   }),
                   :level(* >= $loglevel));

    @*ARGS = @keepargs;
}

INIT
{
    parse-log-args;
}

=begin pod

=head1 NAME

Log::CommandLine

=head1 SYNOPSIS

use Log::CommandLine;

    ./someprogram [--trace]
                  [--debug]
                  [--info]
                  [--warning]  # Default
                  [--error]
                  [--fatal]

    ./someprogram [--logcolor] # Colorize log output

    ./someprogram [--logfile=/var/log/mylogfile]

=head1 DESCRIPTION

A tiny wrapper around Log::Async to set some basic logging
configuration stuff from the commandline.

It will log either to $*OUT or the specified logfile messages with a
level >= the specified level (or warning by default).

Adding the '--logcolor' option will colorize the log output a little.

=end pod
