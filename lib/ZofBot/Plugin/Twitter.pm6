unit class ZofBot::Plugin::Twitter;
use Twitter;

has Str $.tweet-to;
has Str $.consumer-key;
has Str $.consumer-secret;
has Str $.access-token;
has Str $.access-token-secret;
has $!twitter = Twitter.new: :$!consumer-key, :$!consumer-secret,
                             :$!access-token, :$!access-token-secret;

subset ZoffixMention where {
    $_ ~~ m:i/«[ zoffix | IOninja | brokenchicken ]»/
    and .nick ne 'Geth'
}

method irc-privmsg-channel (ZoffixMention $e) {
    my $text = "<{$e.nick}> $e";
    say "Tweeting `$text`";
    $!twitter.direct-message: $text, :name($!tweet-to);
    Nil;
}
