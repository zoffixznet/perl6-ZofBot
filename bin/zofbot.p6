#!/usr/bin/env perl6
use lib <
    /home/zoffix/CPANPRC/IRC-Client/lib
    /home/zoffix/services/lib/IRC-Client/lib
    lib
>;

use IRC::Client;
use ZofBot::Plugin::Twitter;

class ZofBot::Info {
    multi method irc-to-me ($ where /^\s* help \s*$/) {
        "I replaced Zoffix";
    }
    multi method irc-to-me ($ where /^\s* source \s*$/) {
        "See: https://github.com/zoffixznet/perl6-ZofBot";
    }

    multi method irc-to-me ($ where /'bot' \s* 'snack'/) { "om nom nom nom"; }
}

.run with IRC::Client.new:
    :nick<ZofBot>,
    :username<zofbot-zofbot>,
    :host(%*ENV<ZOFBOT_IRC_HOST> // 'irc.freenode.net'),
    :channels( %*ENV<ZOFBOT_DEBUG> ?? '#zofbot' !! |<#perl6  #perl6-dev  #zofbot>),
#    |(:password(conf<irc-pass>)
 #       if conf<irc-pass> and not %*ENV<BUGGABLE_DEBUG>
  #  ),
    :debug,
    :plugins(
        ZofBot::Info.new,
        ZofBot::Plugin::Twitter.new,
    );
