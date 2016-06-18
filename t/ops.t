use v6;
use Test;

use Git::Version;

my @same = (
    < 0.99.9l 1.0rc4 >,
    < 1.0.0                v1.0.0  1.0 >,
    < 1.0.0a               1.0.1 >,
    < 1.0.0b               v1.0.0b 1.0.2 >,
    < 1.0.rc2              0.99.9i >,
    < 1.7.1                v1.7.1  1.7.1.0 >,
    < 1.7.1.1.gc8c07       1.7.1.1.g5f35a >,
    < 1.7.2.rc0.13.gc9eaaa 1.7.2.rc0.13.gc9eaaa >,
    [ 'git version 2.7.0', '2.7', '2.7.0', '2.7.0.0' ],
);

my @sorted = (
  <
    0.99                   0.99.7a
    0.99.7c                0.99.7d
    0.99.8                 0.99.9c
    0.99.9g                1.0
    1.0.0a                 1.0.2
    1.0.3                  1.3.0
    1.3.GIT                1.3.1
    1.3.2                  1.4.0.rc1
    1.4.1                  v1.5.3.7-976-gcd39076
    v1.5.3.7-1198-g467f42c 1.6.6
    1.7.0.2.msysgit.0      1.7.0.4
    1.7.1.rc0              1.7.1.rc1
    1.7.1.rc2              v1.7.1
    1.7.1.1.gc8c07         1.7.1.209.gd60ad81
    1.7.1.211.g54fcb21     1.7.1.236.g81fa0
    1.7.1.1                1.7.1.1.1.g66bd8ab
    1.7.2.rc0              1.7.2.rc0.1.g078e
    1.7.2.rc0.10.g1ba5c    1.7.2.rc0.13.gc9eaaa
    1.9.4.msysgit.0
  >,
   'git version 1.9.5.msysgit.1',
  < v2.8.0.2
  >,
).flat;
;

# the plan
my $shuffle = 3;

plan $shuffle                       # sorted shuffled lists
   + 8 * @same».elems»².sum         # self-equality for @same
   + 8 * @sorted                    # self-equality for @sorted
   + 8 * @sorted * ( @sorted - 1 ); # compare with all successors
;

my sub test_same(@versions) {
    for ( @versions X @versions ) -> @v {
        my $v1 = Git::Version.new(@v[0]);
        my $v2 = Git::Version.new(@v[1]);
        ok( not $v1 < $v2, "not $v1 < $v2" );
        ok( not $v1 > $v2, "not $v1 > $v2" );
        ok( $v1 <= $v2, "$v1 <= $v2" );
        ok( $v1 >= $v2, "$v1 >= $v2" );
        ok( $v1 == $v2, "$v1 == $v2" );
        ok( not $v1 != $v2, "not $v1 != $v2" );
        is( $v1 <=> $v2, Order::Same, "$v1 <=> $v2" );
        is( $v1 cmp $v2, Order::Same, "$v1 cmp $v2" );
    }
}

# test shuffling and sorting
is-deeply(
    @sorted.map({Git::Version.new($_)}).pick(*).sort,
    @sorted.map({Git::Version.new($_)}),
    "sort() a list of Git::Version"
) for ^$shuffle;

# test identical versions against each other
test_same($_) for @same;

# test different versions against each other
while @sorted {
    my $v1 = Git::Version.new( shift @sorted );
    test_same( [$v1] );

    for @sorted.map({Git::Version.new($_)}) -> $v2 {

        ok( $v1 < $v2, "$v1 < $v2" );
        ok( not $v1 > $v2, "not $v1 > $v2" );
        ok( $v1 <= $v2, "$v1 <= $v2" );
        ok( not $v1 >= $v2, "not $v1 >= $v2" );
        ok( not $v1 == $v2, "not $v1 == $v2" );
        ok( $v1 != $v2, "$v1 != $v2" );
        is( $v1 <=> $v2, Order::Less, "$v1 <=> $v2" );
        is( $v1 cmp $v2, Order::Less, "$v1 cmp $v2" );

        # reverse
        ok( not $v2 < $v1, "not $v2 < $v1" );
        ok( $v2 > $v1, "$v2 > $v1" );
        ok( not $v2 <= $v1, "not $v2 <= $v1" );
        ok( $v2 >= $v1, "$v2 >= $v1" );
        ok( not $v2 == $v1, "not $v2 == $v1" );
        ok( $v2 != $v1, "$v2 != $v1" );
        is( $v2 <=> $v1, Order::More, "$v2 <=> $v1" );
        is( $v2 cmp $v1, Order::More, "$v2 cmp $v1" );
    }
}
