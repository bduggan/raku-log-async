use v6;

use Log::Async;

unit module TestModule;

sub sub_a is export
{
    trace   'sub_a';
    debug   'sub_a';
    info    'sub_a';
    warning 'sub_a';
    error   'sub_a';
    fatal   'sub_a';
}

sub sub_b is export
{
    trace   'sub_b';
    debug   'sub_b';
    info    'sub_b';
    warning 'sub_b';
    error   'sub_b';
    fatal   'sub_b';
}
