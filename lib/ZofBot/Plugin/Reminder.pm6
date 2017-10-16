use IRC::Client;
unit class ZofBot::Plugin::Reminder does IRC::Client::Plugin;
use ZofBot::Config;
use OO::Monitors;

my IO::Path $db-file         =  conf<reminder-db-file>.IO;
my SetHash $admin-list .= new: |conf<admin-list>;
subset AdminMessage where {.host ∈ $admin-list};
my $Reminder-New-RE = /:i ^
    \s* rem \s* new \s+
        $<when>=($<v>=[\d+ ['.'\d+]?] $<mult>=<[shdwmM]>)+
    \s+ $<what>=.+
/;

my class Rem { … }
my $db := my monitor Db {
    has IO::Path $.file is required;
    method save (Rem $rem) {
        $!file.spurt: :append, ~$rem;
    }
    method cleanup {
        say "Cleaning up reminder database";
        my Set $to-toss := set $!file.lines.grep(
            *.ends-with: "\x[0]1"
        ).map(*.substr: 0, *-2);
        $!file.spurt: ($!file.lines.grep({
            not *.ends-with: "\x[0]1" and not $to-toss{$_}
        }).join: "\n")~"\n";
    }
    method lines { eager $!file.lines }
}.new: :file($db-file);

my class Rem {
    has Instant:D $.when is required;
    has     Str:D $.what is required;
    has    Bool:D $.sent is rw = False;
    method parse ($str) {
        my ($when, $what, $sent) = $str.split: "\x[0]";
        self.new: :$what, :when(Instant.from-posix: $when), :sent($sent.so);
    }
    method Str {
        "$!when.to-posix.head()\x[0]$!what" ~ ("\x[0]1" if $!sent) ~ "\n"
    }
    method save { $db.save: self; self }
    method schedule(IRC::Client $irc) {
        sub send {
            self.sent = True;
            $db.save: self;
            $irc.send: :where<#zofbot>, :text("Zoffix: reminder: $!what");
        }
        if $!when - 6 < now { send }
        else { Promise.at($!when).then: { send } }
    }
}

method irc-started {
    # wait until we join in and stuff
    $db.cleanup;
    Promise.in(5).then: {
        Rem.parse($_).schedule: $.irc for $db.lines;
    }
}


multi method irc-to-me     ($ where $Reminder-New-RE) { self!set-new-reminder: $/ }
multi method irc-addressed ($ where $Reminder-New-RE) { self!set-new-reminder: $/ }

method !set-new-reminder ($_) {
    my $when = now + .<when>.map({
        .<v> * ({
            :1s, :60m, :3600h, :d(3600*24), :w(3600*24*7), :M(3600*24*30)
        }{.<mult>} // return 'Invalid time specifier. Use s, m, h, d, w, or M')
    }).sum;

    (my $what = ~.<what>).match: /\S/
        or return 'Cannot use empty reminder';

    Rem.new(:$when, :$what).save.schedule($.irc);
    return "Will remind out on $when.DateTime().local() about $what";
}
