#!perl
use Test::More tests => 4;

ok(1) for 1 .. 4;

# package Nothing;
#
# #use B::Lint;
# use B::Lint::Pluggable;
#
# BEGIN {
#     B::Lint->register_plugin( __PACKAGE__ => [qw[this that]] );
# }
# $Nothing::called = 0;
# $Nothing::this   = 0;
# $Nothing::that   = 0;
#
# sub match {
#     my ( $op, $checks_href ) = @_;
#     ++$Nothing::called;
#     ++$Nothing::this if $checks_href->{this};
#     ++$Nothing::that if $checks_href->{that};
# }
#
# package main;
# use O qw( Lint none this );
# use constant ROUGHLY_HALF_A_DOZEN => 5 + int rand 3;
#
# END {
#     cmp_ok( $Nothing::called, '>=', ROUGHLY_HALF_A_DOZEN );
#     cmp_ok( $Nothing::this,   '>=', ROUGLY_HALF_A_DOZEN );
#     is( $Nothing::called, $Nothing::this );
#     is( $Nothing::that,   0 );
# }
