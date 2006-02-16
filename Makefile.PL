use 5.6.0;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'B::Lint::Pluggable',
    AUTHOR        => 'Joshua ben Jore <jjore@cpan.org>',
    VERSION_FROM  => 'lib/B/Lint/Pluggable.pm',
    ABSTRACT_FROM => 'lib/B/Lint/Pluggable.pm',
    PREREQ_PM     => {
        'Test::More' => 0,

        #         strict       => 0,
        #         warnings     => 0,
        #         'File::Spec' => 0,
        #         'B::Lint'    => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'B-Lint-Pluggable-*' },
);
