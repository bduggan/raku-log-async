use v6;

use Log::Async;
use Log::Async::CommandLine;

trace   'log trace';
debug   'log debug';
info    'log info';
warning 'log warning';
error   'log error';
fatal   'log fatal';

say "ARGS: {@*ARGS.join(',')}";
