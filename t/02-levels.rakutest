use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 2;

cmp-ok DEBUG, '>', TRACE, 'level order';
cmp-ok TRACE, '~~', ( DEBUG | TRACE | ERROR ), "smart match";
