unit class ZofBot::Plugin::Twitter;
use ZofBot::Config;
use Twitter;

has Str:D   $!tweet-to     = conf<tweet-to>;
has Twitter $!twitter     .= new:
  |%(conf<consumer-key  consumer-secret  access-token  access-token-secret>:p);

my SetHash $ignore-list  .= new: |conf<ignore-list>;
my SetHash $admin-list   .= new: |conf<admin-list>;
my Bool:D  $is-tweeting   = True;
my Instant $seen         .= from-posix: 0;
my Regex   $mention-regex = rx:i/«[
    | zoffix        | zoffix_        | zoffix__        | zoffix___
    | IOninja       | IOninja_       | IOninja__       | IOninja___
    | brokenchicken | brokenchicken_ | brokenchicken__ | brokenchicken___
    | eveo          | 'eveo-'        | 'eveo--'
    | lollercopter  | DeadDelta
]»/;

subset AdminMessage where {.host ∈ $admin-list};
subset ZoffixMention where {
    $is-tweeting
    and (now - $seen > 10*60 or (.?channel||'') eq '#perl6')
    and $_ ~~ $mention-regex
    and .nick ∉ $ignore-list;
}

multi method irc-privmsg-channel (
    $ where {
        $is-tweeting and .nick ~~ /^ <$mention-regex> $/
        and .channel ne '#zofbot'
    }
) {
    say "[{DateTime.now}] Saw target speak. Turning off Twitter relay";
    $seen = now;
    Nil;
}

multi method irc-privmsg-channel (ZoffixMention $e) {
    my $text = "{$e.channel} <{$e.nick}> $e";
    say "Tweeting `$text`";
    $!twitter.direct-message: $text, :name($!tweet-to);
    Nil;
}

multi method irc-to-me (AdminMessage $ where /«start»/) {
    $is-tweeting = True;
    $seen = Instant.from-posix: 0;
    'Turned on Twitter relay';
}

multi method irc-to-me (AdminMessage $ where /«stop»/) {
    $is-tweeting = False;
    'Turned off Twitter relay';
}

multi method irc-privmsg-channel (
    AdminMessage $e where /^"\x[1]ACTION" \s+ '&'/
) {
    $is-tweeting = True;
    $seen = Instant.from-posix: 0;
    $e.reply: 'Turned on Twitter relay', :where($e.nick);
}
