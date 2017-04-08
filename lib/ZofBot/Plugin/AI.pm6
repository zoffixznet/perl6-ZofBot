unit class ZofBot::Plugin::AI;
use ZofBot::Config;
use Text::Markov;

constant $Brain-File = conf<brain>.IO;
constant $Brain = do with Text::Markov.new(:4order) -> $b {
    $b.feed: $_ for $Brain-File.slurp.split: '.', :skip-empty;
    $b
}

multi method irc-to-me ($e) {
    feed-brain $e.text;
    $Brain.read.substr: 0, 300;
}

multi method irc-privmsg-channel ($e) {
    feed-brain $e.text
}

sub feed-brain ($text) {
    $Brain-File.spurt: "$text\n", :append;
    $Brain.feed: $text;
    $text;
}
