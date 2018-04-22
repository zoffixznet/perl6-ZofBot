use IRC::Client;
unit class ZofBot::Plugin::AI does IRC::Client::Plugin;
use ZofBot::Config;
use Text::Markov;

my $Brain-File = conf<brain>.IO;
my $Brain = do with Text::Markov.new(:10order) -> $b {
    $b.feed: $_ for $Brain-File.slurp.split: '.', :skip-empty;
    $b
}

multi method irc-addressed ($e where {.?channel eq '#perl6-dev'|'#zofbot' or .?nick eq 'Zoffix'}) {
    feed-brain $e.text.trim;
    $Brain.read.substr(0, 300).subst(:g, /\s+/, ' ').trim;
}

multi method irc-privmsg-channel ($e where .channel eq '#perl6-dev'|'#zofbot') {
    feed-brain $e.text.trim;
    $.NEXT;
}

sub feed-brain ($text) {
    $Brain-File.spurt: "$text\n", :append;
    $Brain.feed: $text;
    $text;
}
