use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::Twitter::Antispam',
    license             => 'perl',
    dist_author         => 'James Laver <sprintf(qw(%s@%s.%s cpan jameslaver com))>',
    dist_version_from   => 'lib/Net/Twitter/Antispam.pm',
    dist_abstract       => "Twitter has been getting more an more full of Spam. Enough is enough, lets make it readable again.",
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Net-Twitter-Antispam-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
