#!/usr/bin/env perl6
sub MAIN(IO() $raw-brain where .e) {
    "brain.txt".IO.spurt: $raw-brain.slurp.subst: :g, 
    /
          «<.upper>+»
        | <:letter>+<:digit>+
        | <:digit>+<:letter>+
        | <:digit>+<:punctuation>+
        | <:punctuation>+<:digit>+
    /,
    ''
}
