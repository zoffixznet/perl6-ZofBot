unit class ZofBot::Plugin::Twitter;
use ZofBot::Config;
use Twitter;

has Str:D   $!tweet-to     = conf<tweet-to>;
has Twitter $!twitter     .= new:
  |%(conf<consumer-key  consumer-secret  access-token  access-token-secret>:p);

my SetHash $ignore-list  .= new: |conf<ignore-list>;
my SetHash $admin-list   .= new: |conf<admin-list>;
my Bool:D  $is-tweeting   = True;
my Regex   $mention-regex = rx:i/«[ zoffix | IOninja | brokenchicken ]»/;
subset AdminMessage where {.host ∈ $admin-list};
subset ZoffixMention where {
    $is-tweeting
    and $_ ~~ $mention-regex
    and .nick ∉ $ignore-list;
}

multi method irc-privmsg-channel (
    $ where {$is-tweeting and .nick ~~ /^ <$mention-regex> $/}
) {
    say "Saw target speak. Turning off Twitter relay";
    $is-tweeting = False;
    Promise.in(10*60).then: {
        say "Target watch timer expired. Re-enabling Twitter relay";
        $is-tweeting = True;
    }
    Nil;
}

multi method irc-privmsg-channel (ZoffixMention $e) {
    my $text = "{$e.channel} <{$e.nick}> $e";
    say "Tweeting `$text`";
    $!twitter.direct-message: $text, :name($!tweet-to);
    Nil;
}

multi method irc-to-me (AdminMessage $ where /«ignore \s+ $<who>=\S+/) {
    ~$<who> ∈ $ignore-list and return "$<who> is already ignored";
    $ignore-list{~$<who>}++;
    "Placed $<who> on ignore list";
}

multi method irc-to-me (AdminMessage $ where /«unignore \s+ $<who>=\S+/) {
    ~$<who> ∉ $ignore-list and return "$<who> is not being ignored";
    $ignore-list{~$<who>}--;
    "Removed $<who> from ignore list";
}

multi method irc-to-me (AdminMessage $ where /«start»/) {
    $is-tweeting = True;
    'Turned on Twitter relay';
}

multi method irc-to-me (AdminMessage $ where /«stop»/) {
    $is-tweeting = False;
    'Turned off Twitter relay';
}
