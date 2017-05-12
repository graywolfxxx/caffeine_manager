package Caffeine::Model::User;

use Mojo::Base 'Caffeine::Model::Base';
use Digest::SHA qw(sha1_hex);

sub tname {'Caffeine_User'}
sub entity_name {'user'}
sub entity_name_plur {'users'}

sub insert {
    my ($self, $p) = @_;

    $p = {} if !$p;
    %$p = map {$_ => $p->{$_}} qw(login password email);

    return $self->error(400, 1401, '"login" is mandatory')    if !length($p->{login} // '');
    return $self->error(400, 1402, '"password" is mandatory') if !length($p->{password} // '');
    return $self->error(400, 1403, '"email" is mandatory')    if !length($p->{email} // '');

    my ($cnt, $err) = $self->count({login => $p->{login}});
    return (undef, $err) if $err;
    return $self->error(400, 1421, '"login" already exists') if $cnt;

    ($cnt, $err) = $self->count({email => $p->{email}});
    return (undef, $err) if $err;
    return $self->error(400, 1423, '"email" already exists') if $cnt;

    # Don't save opened passord. Save ONLY hash of passord!
    $p->{password} = sha1_hex($p->{password});

    return $self->SUPER::insert($p);
}

1;
