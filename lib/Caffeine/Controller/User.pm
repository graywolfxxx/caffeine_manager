package Caffeine::Controller::User;

=head1 DESCRIPTION

    This class provides actions for user's router

=cut

use Mojo::Base 'Caffeine::Controller::Base';
use Data::Dumper;

=head1 METHODS

=head2 register

    Add new user

=cut

sub register {
    my ($self) = @_;

    my $p = {map {$_ => $self->req->json->{$_}} qw(login password email)};

    my ($new_id, $err) = $self->model('User')->insert($p);
    return $self->render_model_err($err) if $err;
    return $self->render_err(500, 500, "Can't add user: unknown error") if !$new_id;

    return $self->render_ok(id => $new_id);
}

1;
