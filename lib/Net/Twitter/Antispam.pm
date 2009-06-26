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
    my $avg = (sum @percentages) / scalar @percentages;
    
    $avg > 50;
}

sub run_plugin {
    my ($self,$subname,$name,@params) = @_;

    &{$name . '::' . $subname}($self,$self->twitter,@params);
}

sub _active_plugins {
    my ($self) = @_;

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

 use Net::Twitter::Antispam;

 my $spam = Net::Twitter::Antispam->new(username=>'foo',password=>'bar', active_plugins => [
     'Example', # Example module that ships with N::T::A, counters a previous spam attack
     'LessThan20', #Hypothetical other module that regards people with less than 20 tweets as spam
 ];

 # Gets a Net::Twitter
 my $t = $spam->twitter;
 foreach my $follower (@{$t->followers}) {
     say "Spammer: " . $follower->{screen_name} if $spam->is_user_spammy($follower);
     # You have the full power of Net::Twitter, but I'd question whether auto-blocking is a good strategy ;)
 }

=head1 FUNCTIONS

=head2 new

Constructs the object, Moose-style. Required attributes: username, password, active_plugins

=head2 is_message_spammy (Str) => Bool

Runs all active message plugins, gets the mean and returns whether that is over 50%

=head2 is_user_spammy (HashRef) => Bool

Runs all active user plugins, gets the mean and returns whether that is over 50%

=head2 run_plugin ( $plugin_sub_name :: Str, $plugin_name :: Str, Array )

The array at the end (not a ref!) contains args to pass to the plugin. For message plugins, it should get the message body. For user plugins it should get the user hashref returned from Net::Twitter.

Useful if your plugin depends on the result of other plugins.

e.g. run_plugin('is_message_spammy','ContextFreeLinks',$message);

=head1 MEMBER VARIABLES

=head2 twitter :: Net::Twitter

=head2 username :: Str

Your twitter username

=head2 password :: Str

Your twitter password

=head2 active_plugins :: ArrayRef

List of plugins (without the Net::Twitter::Antispam::Plugin:: prefix) that you want to activate

=head1 AUTHOR

James Laver, C<< <sprintf(qw(%s@%s.%s cpan jameslaver com))> >>

=head1 SEE ALSO

L<Net::Twitter> - This wraps part of the API, you'll want to know how to work it.
L<Net::Twitter::Antispam::Plugin::Example> - An example plugin that blocks a previous twitter spam tactic.

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
