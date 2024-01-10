use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 12;

my $out;
my $out-channel = Channel.new;
sub wait-for-out {
    react {
        whenever $out-channel   { $out = $_;  done }
        whenever Promise.in(20) { $out = Nil; done }
    }
}
$*OUT = $*OUT but role { method say($arg) { $out-channel.send: $arg } };

set-logger(Log::Async.new);
logger.send-to($*OUT);

trace "albatross";
wait-for-out;
like $out, /albatross/, 'found message';
like $out, /trace/, 'found level';

debug "soup";
wait-for-out;
like $out, /soup/, 'found message';
like $out, /debug/, 'found level';

info "logic";
wait-for-out;
like $out, /logic/, 'found message';
like $out, /info/, 'found level';

warning "problem";
wait-for-out;
like $out, /problem/, 'found message';
like $out, /warning/, 'found level';

error "danger";
wait-for-out;
like $out, /danger/, 'found message';
like $out, /error/, 'found level';

fatal "will robinson";
wait-for-out;
like $out, /'will robinson'/, 'found message';
like $out, /fatal/, 'found level';
