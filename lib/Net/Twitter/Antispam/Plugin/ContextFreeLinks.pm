package Net::Twitter::Antispam::Plugin::ContextFreeLinks;

sub is_message_spammy {
    my ($antispam,$twitter,$message) = @_;
    # Has a shortened url?    
    if ($message =~ m(http://(bit\.ly|tr\.im|is\.gd|bitly\.com|tinyurl\.com)/\S+)) {
        # Has other content? (at least 10 non-whitespace characters)
        my $other = $` . $'); #'
	return ((scalar $other=~ /\S/) > 10 ? 20 : 90);
    }
    return 50;
}

1;
__END__

=head1 NAME

Net::Twitter::Antispam::Plugin::ContextFreeLinks - a plugin that marks messages with shortened links and no content as spam

=head1 DESCRIPTION

A lot of tweeters post shortened links with no explanation of what they are. This is annoying. This plugin counteracts this.

=head1 FUNCTIONS

=head2 is_message_spammy :: (Net::Twitter::Antispam, Net::Twitter, Str) => Int

=head1 SEE ALSO

L<Net::Twitter::Antispam> - The anti-spam system for twitter

=cut
