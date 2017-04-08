use strict;
use warnings;
use 5.014;
use WWW::Mechanize;
use Encode;
use Mojo::File 'path';

my $mech = WWW::Mechanize->new;

$mech->get('https://design.perl6.org/');

my $brain = '';
my @urls = grep {
    $_->url =~ /S\d+/ and ($_->url !~ /^http/ or $_->url =~ /design.perl6.org/)
}$mech->links;
say $_->url_abs for @urls;
for my $url (@urls) {
    say "Processing " . $url->text;
    $mech->get($url->base('https://design.perl6.org/'));
    my @words = $mech->text =~ /[^\s()\[\]]{1,30}/g;
    $brain .=  join "\n", map "$_.", split /\.+\s*/, join ' ',
        grep { /^\d+\.?$/ or /^[a-zA-Z]+\.?$/ }
            split ' ', join ' ', map { s/([a-z])([A-Z])/$1 $2/gr } @words;
}

path('brain.txt')->spurt(encode 'utf8', $brain);
say "Done";
