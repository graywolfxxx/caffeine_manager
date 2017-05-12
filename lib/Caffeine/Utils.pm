package Caffeine::Utils;

=head1 DESCRIPTION

    Project utils.

=cut

use Time::HiRes;

use Exporter 'import';

our @EXPORT_OK = qw(
    timeout
);

=head1 METHODS

=head2 timeout

    Waits $sec seconds called subroutine and interrupt it.
    Returns the result of subroutine call.

=cut

sub timeout {
    my ($sec, $s) = @_;
    return unless defined($sec) && $sec =~ /^\d+(?:\.\d+)?$/ && defined($s) && ref($s) eq 'CODE';
    my $wantarray = wantarray;
    my ($res, @res, $to_error);
    eval {
        local $SIG{__DIE__} = 'IGNORE';
        local $SIG{ALRM} = sub { $to_error = 1; die "alarm_special_die"; };
        Time::HiRes::alarm($sec);
        if ($wantarray) {
            @res = $s->();
        } else {
            $res = $s->();
        }
        alarm(0);
    };
    alarm(0);
    if ($to_error) {
        my ($pkg, $file, $line) = caller();
        warn "Timeout $sec sec at $file line $line\n";
        return;
    } elsif ($@ && $@ !~ /alarm_special_die/) {
        warn $@;
        return;
    }
    return $wantarray ? @res : $res;
}

1;
