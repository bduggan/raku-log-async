use v6;
use Test;
use Log::Async;

plan 12;

my $out;
$*OUT = IO::Handle but role { method say($arg) { $out ~= $arg } };

set-logger(Log::Async.new);

trace "albatross";
sleep 0.1;
like $out, /albatross/, 'found message';
like $out, /trace/, 'found level';

debug "soup";
sleep 0.1;
like $out, /soup/, 'found message';
like $out, /debug/, 'found level';

info "logic";
sleep 0.1;
like $out, /logic/, 'found message';
like $out, /info/, 'found level';

warning "problem";
sleep 0.1;
like $out, /problem/, 'found message';
like $out, /warning/, 'found level';

error "danger";
sleep 0.1;
like $out, /danger/, 'found message';
like $out, /error/, 'found level';

fatal "will robinson";
sleep 0.1;
like $out, /'will robinson'/, 'found message';
like $out, /fatal/, 'found level';


