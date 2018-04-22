#!/usr/bin/env perl6
use lib <lib>;

use IRC::Client;
use ZofBot::Plugin::AI;
use ZofBot::Plugin::Tau;
use ZofBot::Plugin::IgnoreList;
use ZofBot::Plugin::Reminder;
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
    :channels( %*ENV<ZOFBOT_DEBUG> ?? '#zofbot' !! |<#perl6 #perl6-dev  #moarvm  #zofbot  #perl6-toolchain>),
#    |(:password(conf<irc-pass>)
 #       if conf<irc-pass> and not %*ENV<BUGGABLE_DEBUG>
  #  ),
    :debug,
    :plugins(
        ZofBot::Plugin::Reminder.new,
        ZofBot::Plugin::IgnoreList.new,
        ZofBot::Info.new,
        ZofBot::Plugin::Tau.new,
        ZofBot::Plugin::Twitter.new,
#        ZofBot::Plugin::AI.new,
    );
