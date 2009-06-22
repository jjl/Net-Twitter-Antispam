use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::Twitter::Antispam',
    license             => 'perl',
    dist_author         => 'James Laver <sprintf(qw(%s@%s.%s cpan jameslaver com))>',
    dist_version_from   => 'lib/Net/Twitter/Antispam.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-Twitter-Antispam-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
