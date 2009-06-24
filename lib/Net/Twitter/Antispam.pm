package Net::Twitter::Antispam;

our $VERSION = '0.01';

use Moose;
use Module::Pluggable require => 1;
use List::Util 'first', 'sum';

has twitter => (
    isa => 'Net::Twitter',
    is => 'ro',
    lazy_build => 1,
);

has username => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has password => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has active_plugins => (
    isa => 'Str',
    is => 'rw',
    default => sub{[]},
);

sub _build_twitter {
    my ($self) = @_;

    Net::Twitter->new({username => $self->username, password => $self->password}) or die("Could not create twitter!");
}

sub is_user_spammy {
    my ($self,$user) = @_;
    my ($avg,@percentages);
    
    @percentages = map { $self->run_plugin('is_user_spammy',$_,$user) } $self->_user_plugins;
    $avg = (sum @percentages) / scalar @percentages;
    
    $avg > 50;
}

sub is_message_spammy {
    my ($self,$message) = @_;
    my @percentages;

    @percentages = map { $self->run_plugin('is_message_spammy',$_,$message) } $self->_message_plugins;
    $avg = (sum @percentages) / scalar @percentages;
    
    $avg > 50;
}

sub run_plugin {
    my ($self,$subname,$name,@params) = @_;

    &{$name . '::' . $subname}($self,$self->twitter,@params);
}

sub _active_plugins {
    my ($self) @_;

    grep { 
        my $modname = $_;
        $modname =~ s/^Net::Twitter::Antispam::Plugin:://;
        $modname = lc $modname;
        first {
	    lc $_ eq $modname;
        } @{$self->active_plugins};
    } $self->plugins;
}

sub _user_plugins {
    my ($self) = @_;
    
    grep {UNIVERSAL::can($_,'is_user_spammy')} $self->_active_plugins;
}

sub _message_plugins {
    my ($self) = @_;
    
    grep {UNIVERSAL::can($_,'is_message_spammy')} $self->_active_plugins;
}

1;
__END__

=head1 NAME

 Net::Twitter::Antispam - Making Twitter usable

=head1 VERSION

 Version 0.01

=head1 SYNOPSIS

 A module to oust spammers.

Perhaps a little code snippet.

 use Net::Twitter::Antispam;

 my $foo = Net::Twitter::Antispam->new();

=head1 FUNCTIONS

=head2 new

Constructs the object, Moose-style

=head1 MEMBER VARIABLES

=head2 twitter :: Net::Twitter

=head2 username :: Str

=head2 password :: Str

=head1 AUTHOR

James Laver, C<< <sprintf(qw(%s at %s.%s cpan jameslaver com))> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-twitter-antispam at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Twitter-Antispam>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Twitter-Antispam>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Twitter-Antispam>

=back

=head1 ACKNOWLEDGEMENTS

An anti-thankyou to all of the twitter spammers who made me write this.

=head1 COPYRIGHT & LICENSE

Copyright 2009 James Laver, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
