unit class ZofBot::Plugin::IgnoreList;
use ZofBot::Config;

my SetHash $ignore-list  .= new: |conf<ignore-list>;
my Set     $admin-list   .= new: |conf<admin-list>;
subset AdminMessage where { .host ∈ $admin-list  }
subset Ignored      where {
    .nick ∈ $ignore-list
    or .text.starts-with: any <m: u: c: bisect: commit:>
    or .channel eq '#zofbot'
}

multi method irc-to-me           (Ignored) {}
multi method irc-privmsg-channel (Ignored) {}
multi method irc-notice-channel  (Ignored) {}

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
