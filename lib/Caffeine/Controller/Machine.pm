package Caffeine::Controller::Machine;

=head1 DESCRIPTION

    This class provides actions for coffee machine's router

=cut

use Mojo::Base 'Caffeine::Controller::Base';

=head1 METHODS

=head2 register

    Add new coffee machine

=cut

sub register {
    my ($self) = @_;

    my $p = {map {$_ => $self->req->json->{$_}} qw(name caffeine)};

    my ($new_id, $err) = $self->model('Machine')->insert($p);
    return $self->render_model_err($err) if $err;
    return $self->render_err(500, 500, "Can't add machine: unknown error") if !$new_id;

    return $self->render_ok(id => $new_id);
}

1;
