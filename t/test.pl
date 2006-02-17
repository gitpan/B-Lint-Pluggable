sub _where {
    my @caller = caller($Level);
    return "at $caller[1] line $caller[2]";
}

# runperl - Runs a separate perl interpreter.
# Arguments :
#   switches => [ command-line switches ]
#   nolib    => 1 # don't use -I../lib (included by default)
#   prog     => one-liner (avoid quotes)
#   progs    => [ multi-liner (avoid quotes) ]
#   progfile => perl script
#   stdin    => string to feed the stdin
#   stderr   => redirect stderr to stdout
#   args     => [ command-line arguments to the perl program ]
#   verbose  => print the command line

my $is_mswin   = $^O eq 'MSWin32';
my $is_netware = $^O eq 'NetWare';
my $is_macos   = $^O eq 'MacOS';
my $is_vms     = $^O eq 'VMS';

sub _quote_args {
    my ( $runperl, $args ) = @_;

    foreach (@$args) {

        # In VMS protect with doublequotes because otherwise
        # DCL will lowercase -- unless already doublequoted.
        $_ = q(") . $_ . q(") if $is_vms && !/^\"/ && length($_) > 0;
        $$runperl .= ' ' . $_;
    }
}

sub _create_runperl {    # Create the string to qx in runperl().
    my %args    = @_;
    my $runperl = $^X =~ m/\s/ ? qq{"$^X"} : $^X;

    #- this allows, for example, to set PERL_RUNPERL_DEBUG=/usr/bin/valgrind
    if ( $ENV{PERL_RUNPERL_DEBUG} ) {
        $runperl = "$ENV{PERL_RUNPERL_DEBUG} $runperl";
    }
    unless ( $args{nolib} ) {
        if ($is_macos) {
            $runperl .= ' -I::lib';

            # Use UNIX style error messages instead of MPW style.
            $runperl .= ' -MMac::err=unix' if $args{stderr};
        }
        else {
            $runperl .= ' "-I../lib"';    # doublequotes because of VMS
        }
    }
    if ( $args{switches} ) {
        local $Level = 2;
        die "test.pl:runperl(): 'switches' must be an ARRAYREF " . _where()
            unless ref $args{switches} eq "ARRAY";
        _quote_args( \$runperl, $args{switches} );
    }
    if ( defined $args{prog} ) {
        die "test.pl:runperl(): both 'prog' and 'progs' cannot be used "
            . _where()
            if defined $args{progs};
        $args{progs} = [ $args{prog} ];
    }
    if ( defined $args{progs} ) {
        die "test.pl:runperl(): 'progs' must be an ARRAYREF " . _where()
            unless ref $args{progs} eq "ARRAY";
        foreach my $prog ( @{ $args{progs} } ) {
            if ( $is_mswin || $is_netware || $is_vms ) {
                $runperl .= qq ( -e "$prog" );
            }
            else {
                $runperl .= qq ( -e '$prog' );
            }
        }
    }
    elsif ( defined $args{progfile} ) {
        $runperl .= qq( "$args{progfile}");
    }
    else {

        # You probaby didn't want to be sucking in from the upstream stdin
        die "test.pl:runperl(): none of prog, progs, progfile, args, "
            . " switches or stdin specified"
            unless defined $args{args}
            or defined $args{switches}
            or defined $args{stdin};
    }
    if ( defined $args{stdin} ) {

        # so we don't try to put literal newlines and crs onto the
        # command line.
        $args{stdin} =~ s/\n/\\n/g;
        $args{stdin} =~ s/\r/\\r/g;

        if ( $is_mswin || $is_netware || $is_vms ) {
            $runperl
                = qq{$^X -e "print qq(} . $args{stdin} . q{)" | } . $runperl;
        }
        elsif ($is_macos) {

            # MacOS can only do two processes under MPW at once;
            # the test itself is one; we can't do two more, so
            # write to temp file
            my $stdin
                = qq{$^X -e 'print qq(} . $args{stdin} . qq{)' > teststdin; };
            if ( $args{verbose} ) {
                my $stdindisplay = $stdin;
                $stdindisplay =~ s/\n/\n\#/g;
                print STDERR "# $stdindisplay\n";
            }
            `$stdin`;
            $runperl .= q{ < teststdin };
        }
        else {
            $runperl
                = qq{$^X -e 'print qq(} . $args{stdin} . q{)' | } . $runperl;
        }
    }
    if ( defined $args{args} ) {
        _quote_args( \$runperl, $args{args} );
    }
    $runperl .= ' 2>&1'          if $args{stderr}  && !$is_macos;
    $runperl .= " \xB3 Dev:Null" if !$args{stderr} && $is_macos;
    if ( $args{verbose} ) {
        my $runperldisplay = $runperl;
        $runperldisplay =~ s/\n/\n\#/g;
        print STDERR "# $runperldisplay\n";
    }
    return $runperl;
}

sub runperl {
    die "test.pl:runperl() does not take a hashref"
        if ref $_[0]
        and ref $_[0] eq 'HASH';
    my $runperl = &_create_runperl;
    my $result  = `$runperl`;
    $result =~ s/\n\n/\n/ if $is_vms;    # XXX pipes sometimes double these
    return $result;
}

1;
