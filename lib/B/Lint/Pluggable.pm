package B::Lint::Pluggable;

use 5.6.0;

=head1 NAME

B::Lint::Pluggable - Adds plugin support to B::Lint

=head1 VERSION

Version 0.01_02

=cut

our $VERSION = '0.01_02';

=head1 SYNOPSIS

L<B::Lint> 1.04 is the first version to support the
C<B::Lint-E<gt>register_plugin(...)>. This module patches all earlier
versions of L<B::Lint> to add plugin support. It has no interface on
its own and requires no action other than loading it.

Your L<B::Lint> will be patched only if it needs it.

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

=cut

use strict;
use warnings;
use File::Spec ();

# Read B/Lint.pm, wherever it exists.
local $_ = do {
    local @ARGV;
    for (@INC) {
        local $_ = File::Spec->catfile( $_, "B", "Lint.pm" );
        if (-e) {
            @ARGV = $_;
            $INC{'B/Lint.pm'} = $_;
            last;
        }
    }

    local $/;
    <>;
};

unless ( B::Lint->can('register_plugin') or /register_plugin/ ) {

    ###########################################################################
    # This was added for 5.8.0, B::Lint 1.01.
    s/^\s*our\s+\$VERSION\s+=\s+\'[^\']+\'/our \$VERSION = '@{[~0]}'/smx
        or warn;

    ###########################################################################
    s/^\s*use\s+B\s+qw\(([^\)]+)/use B qw($1 class/smx
        or warn;

    ###########################################################################
    s[(.+?\n\n)][
    local $_ = $1;
    /\$line/sxm and /\$file/sxm
		 ? "$_
sub line { \$line }
sub file { \$file }
" : $_
    ]sex
        or warn;

    ###########################################################################
    s/(^\s*my\s+%valid_check[^\r\n]+[\r\n]+)/${1}my %plugin_valid_check;\n/smx
        or warn;

    ###########################################################################
    s/^\s*sub\s+B::OP::lint\s*\{\s*\}[^\r\n]*[\r\n]+/
my \@plugins;
sub B::OP::lint {
    my \$op = shift;
    my \$m;
    \$m = \$_->can('match'), \$op->\$m( \\ %check ) for \@plugins;
    return;
}

*\$_ = *B::op::lint
  for \\ ( *B::PADOP::lint,
          *B::LOGOP::lint,
          *B::BINOP::lint,
          *B::LISTOP::lint );
/sxm
        or warn;

    ###########################################################################
    s/(?sm)^(sub \s+ compile \s* \{ .+? ^\})/
        local $_ = $1;
        #######################################################################
        s[%check\s*=\s*%valid_check][%check = ( %valid_check, %plugin_valid_check )]smx
          or warn;

        #######################################################################
        s[(warn\s*"No\s+such\s+check[^;]+);][$1 or defined \$plugin_valid_check{\$opt};]smx
          or warn;

        "$_

sub register_plugin {
    my ( undef, \$plugin, \$new_checks ) = \@_;

    # Register the plugin
    for my \$check ( \@\$new_checks ) {
        defined \$check
          or warn \"Undefined value in checks.\";
        not \$valid_check{ \$check }
          or warn \"\$check is already registered as a B::Lint feature.\";
        not \$plugin_valid_check{ \$check }
          or warn \"\$check is already registered as a \$plugin_valid_check{\$check} feature.\";
    }

    push \@plugins, \$plugin;

    return;
}
"
    /sex
        or warn;

    ###########################################################################
    # This patches perl +5.8, B::Lint +1.01.
    s/svref_2object\(\\*glob\)->EGV->lintcv/
        # When is EGV a special value?
        my \$gv = svref_2object(\\*glob->EGV;
        next if class( \$gv ) eq 'SPECIAL';
        \$gv->lintsv;
    /smx;

    for my $subtopatch (qw( COP UNOP PMOP LOOP SVOP )) {
        #######################################################################
        s/(^sub\s+B::${subtopatch}::lint\s*.+?^\})/
            local $_ = $1;

            ###################################################################
            s[(?=^\})][
                my \$m;
                \$m = \$_->can('match'), \$op->\$m( \\ %check ) for \@plugins;
                return;
            ]smx
              or warn;
            $_
        /semx
            or warn;
    }

    ###########################################################################
    {

        package B::Lint;
        eval "#line " . __LINE__ . " \"" . __FILE__ . "\"\n$_";
    }
    die $@ if $@;

}

=head1 AUTHOR

Joshua ben Jore, C<< <jjore@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-b-lint-pluggable@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=B-Lint-Pluggable>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Joshua ben Jore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# This quote blatantly copied from Michael Poe's web comic, Errant
# Story at http://www.errantstory.com

qq[

Arr... That be as fine a booty as a pirate's ever laid eye on. Mind if I stick me pegleg up your poopdeck, matey?

'Okay... new rule, there shall be no more pirate talk during sex, understand?'

Arrr...

];
