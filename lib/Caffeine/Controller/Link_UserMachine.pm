package Caffeine::Controller::Link_UserMachine;

=head1 DESCRIPTION

    This class provides actions for buying coffee

=cut

use Mojo::Base 'Caffeine::Controller::Base';
use Data::Dumper;

=head1 METHODS

=head2 buy

    Buy coffee in specific machine

=cut

sub buy {
    my ($self) = @_;

    my $p = {
        user_id    => scalar($self->stash('user')),
        machine_id => scalar($self->stash('machine')),
    };
    if ($self->req->method eq 'PUT' && $self->req->json && $self->req->json->{timestamp}) {
        $p->{timestamp} = $self->req->json->{timestamp};
    }

    my ($res, $err) = $self->model('Link_UserMachine')->insert($p);
    return $self->render_model_err($err) if $err;
    return $self->render_err(500, 500, "Can't buy coffee: unknown error") if !$res;

    return $self->render_ok(ok => 1);
}

1;
