use Log::Async;
use Log::Async::CommandLine;
use TestModule;

trace   'log trace';
debug   'log debug';
info    'log info';
warning 'log warning';
error   'log error';
fatal   'log fatal';

say "ARGS: {@*ARGS.join(',')}";

if '--testsubs' ∈ @*ARGS
{
    sub_a;
    sub_b;
}
