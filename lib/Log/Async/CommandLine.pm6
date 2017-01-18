unit module Log::Async::CommandLine;

use Log::Async;

sub parse-log-args
{
    my @keepargs;

    my $loglevel = WARNING;
    my $logfh = $*OUT;
    my $silent;

    my &print-log = sub ($logfh, $m)
    {
	$logfh.say("$m<when> $m<level>.lc(): $m<msg>");
    };

    for @*ARGS
    {
	when '--silent'|'-q'
	{
	    $silent = True;
	}
	when '-v'
	{
	    $loglevel = INFO;
	}
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
	    use Terminal::ANSIColor;

	    &print-log = sub ($logfh, $m)
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
	    };
        }
        default
        {
            push @keepargs, $_;
        }
    }

    logger.close-taps;
    logger.add-tap(-> $m { &print-log($logfh, $m) }, :level(* >= $loglevel))
	unless $silent;

    @*ARGS = @keepargs;
}

INIT
{
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
                  [--silent | -q]

    ./someprogram [--logcolor] # Colorize log output

    ./someprogram [--logfile=/var/log/mylogfile]

=head1 DESCRIPTION

A tiny wrapper around Log::Async to set some basic logging
configuration stuff from the commandline.

It will log either to $*OUT or the specified logfile messages with a
level >= the specified level (or warning by default).

Adding the '--logcolor' option will colorize the log output a little.

=end pod
