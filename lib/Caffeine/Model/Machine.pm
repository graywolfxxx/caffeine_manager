package Caffeine::Model::Machine;

use Mojo::Base 'Caffeine::Model::Base';

sub tname {'Caffeine_Machine'}
sub entity_name {'machine'}
sub entity_name_plur {'machines'}

sub insert {
    my ($self, $p) = @_;

    $p = {} if !$p;
    %$p = map {$_ => $p->{$_}} qw(name caffeine);

    return $self->error(400, 2401, '"caffeine" is mandatory') if !length($p->{caffeine} // '');
    #return $self->error(400, 2402, '"name" is mandatory')    if !length($p->{name} // '');

    return $self->SUPER::insert($p);
}

1;
