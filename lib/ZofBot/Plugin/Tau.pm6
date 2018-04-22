unit class ZofBot::Plugin::Tau;
use Games::TauStation::DateTime;

multi method irc-to-me ($ where /^ :i gct \s* $<gct>=.+/ ) {
    with (try GCT.new: ~$<gct>) {
        .gist;
    }
    else {
        "Failed to parse GCT time: $!.message()"
    }
}
