unit class ZofBot::Plugin::Tau;
use Games::TauStation::DateTime;
use Number::Denominate;

multi method irc-privmsg-channel ($ where /^ :i '|gct' \s+ $<gct>=.+/ ) { gct $/ }
multi method irc-to-me           ($ where /^ :i   gct  \s* $<gct>=.+/ ) { gct $/ }

sub gct {
    my $gtc := $<gct>.Str.lc.trim.ends-with('gct') ?? ~$<gct> !! "$<gct> GCT";
    with (try GCT.new: $gtc) {
        "{.OE}; which is {denominate (.Instant - now).Rat} from now"
    }
    else {
        "Failed to parse GCT time: $!.message().trans("\n" => "␤")"
    }
}

