#!perl
use Test::More tests => 1;

use B::Lint;
use B::Lint::Pluggable;
ok( B::Lint->can('register_plugin'), "Can B::Lint->register_plugin" );
