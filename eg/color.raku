#!/usr/bin/env raku

use Log::Async;
use Terminal::ANSI::OO 't';

my %colors =
   trace   => '#7bb274',  # Sage green
   debug   => '#6b8ba4',  # Dusty blue
   info    => '#cba560',  # Goldenrod
   warning => '#ab6ca2',  # Wisteria
   error   => '#d9544d',  # Coral red
   ;


sub color-formatter ( $m, :$fh ) {
    $fh.say: t.color( %colors{$m<level>.lc} // '#ff0000' )
    ~ ' ' ~ $m<when>
    ~ ' ' ~ ('[' ~ $m<level>.lc ~ ']').fmt('%-10s')
    ~ $*THREAD.id.fmt('%3s')
    ~ ' ' ~ $m<msg> ~ t.text-reset;
}

logger.send-to: $*ERR, formatter => &color-formatter;

trace 'innie';
debug 'minnie';
warning 'moe';
info 'oe';
fatal 'e';
