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

}
