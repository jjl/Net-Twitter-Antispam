package Net::Twitter::Antispam::Plugin::Example;

sub is_user_spammy {
    my ($antispam,$twitter,$user) = @_;
    
    if ($user->{screen_name} =~ /^[A-Z][a-z]+[A-Z]\d{4}$/) {
        # We may have a live one. ~463 followers?
        if ($user->{friends_count} > 450 && $user->{friends_count} < 480) {
            #They may indeed be a cock. Are they being followed?
            if ($user->{followers_count} < 20) {
                # But do they have but one tweet?
                if (scalar @{$twitter->user_timeline({id => $user->{id}, count => 2})} <= 1) {
                    # 100%, they are a spammer
                    return 100;
                }
            }
        }
    }
    #As far as we're aware, we have no clue whether they're a spammer
    return 50;
}

1;
__END__

=head1 NAME

Net::Twitter::Antispam::Plugin::Example - an example plugin for Net::Twitter::Antispam that blocks an old twitter tactic

=head1 DESCRIPTION

To implement a plugin, you need to decide whether your plugin tests for a user being a spammer or an individual message being spamlike.

There are two predefined method names you can user: C<is_user_spammy> and C<is_message_spammy>.

You need only implement one of these, this module only implements C<is_user_spammy>

Each function should return a percentage value of spam likelihood with 100% being 'definitely spam', 0% being 'definitely not spam' and 50% being 'no clue'.

The results from every module being used will be averaged to guess whether it is spam or not.

=head1 INTERFACE

=head1 is_user_spammy

receives three arguments: a Net::Twitter::Antispam, a Net::Twitter, and a hashref representing the user that was returned from Net::Twitter.

It is expected to return a percentage spam likelihood.

=head2 is_message_spammy

receives three arguments: a Net::Twitter::Antispam, a Net::Twitter, and a copy of the message

It is expected to return a percentage spam likelihood.

=head1 FUNCTIONS

=head2 is_user_spammy :: (Net::Twitter::Antispam, Net::Twitter, HashRef) => Int

This is a method called automatically by Net::Twitter::Antispam. In this case it combats an old spamming tactic.

=head1 SEE ALSO

L<Net::Twitter::Antispam> - The anti-spam system for twitter
L<Net::Twitter> - You'll be passed one of these implementing

=cut
