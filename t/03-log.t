use v6;
use Test;
use Log::Async;

plan 12;

my $out;
class Mock is IO::Handle {
  method say($str) {
     $out ~= $str;
  }
}
$*OUT = Mock.new;

set-logger(Log::Async.new);

trace "albatross";
like $out, /albatross/, 'found message';
like $out, /trace/, 'found level';

debug "soup";
like $out, /soup/, 'found message';
like $out, /debug/, 'found level';

info "logic";
like $out, /logic/, 'found message';
like $out, /info/, 'found level';

warning "problem";
like $out, /problem/, 'found message';
like $out, /warning/, 'found level';

error "danger";
like $out, /danger/, 'found message';
like $out, /error/, 'found level';

fatal "will robinson";
like $out, /'will robinson'/, 'found message';
like $out, /fatal/, 'found level';


