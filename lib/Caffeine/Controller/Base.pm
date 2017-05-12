package Caffeine::Controller::Base;

=head1 DESCRIPTION

    This class provides base functionality for other controllers

=cut

use Mojo::Base 'Mojolicious::Controller';

sub render_ok {
    my ($self, %rsp) = @_;
    return $self->render(json => \%rsp);
}

sub render_err {
    my ($self, $http_status, $error_code, $error_text, %rsp) = @_;
    $http_status = 400 if !$http_status || $http_status < 400;
    $rsp{error_code} = $error_code || $http_status;
    $rsp{error_text} = $error_text || 'Unknown error';
    return $self->render(json => \%rsp, status => $http_status);
}

sub render_model_err {
    my ($self, $err) = @_;
    $err = {} if !$err;
    my $error = delete($err->{error}) || {};
    return $self->render_err(delete($err->{status}), delete($error->{error_code}), delete($error->{error_text}), %$err);
}

1;
