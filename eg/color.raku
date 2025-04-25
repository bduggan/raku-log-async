#!/usr/bin/env raku

use Log::Async;
use Terminal::ANSI::OO 't';

my %colors =
   TRACE   => '#7bb274',  # Sage green
   DEBUG   => '#6b8ba4',  # Dusty blue
   INFO    => '#cba560',  # Goldenrod
   WARNING => '#ab6ca2',  # Wisteria
   ERROR   => '#d9544d',  # Coral red
   ;


sub color-formatter ( $m, :$fh ) {
    $fh.say: t.color( %colors{$m<level>} // '#ff0000' )
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
