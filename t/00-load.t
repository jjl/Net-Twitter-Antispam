#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::Twitter::Antispam' );
}

diag( "Testing Net::Twitter::Antispam $Net::Twitter::Antispam::VERSION, Perl $], $^X" );
