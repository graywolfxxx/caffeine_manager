package Caffeine::Model::Link_UserMachine;

use Mojo::Base 'Caffeine::Model::Base';

sub tname {'Caffeine_Link_UserMachine'}
sub entity_name {'purchase'}
sub entity_name_plur {'purchases'}

sub insert {
    my ($self, $p) = @_;

    $p = {} if !$p;
    %$p = map {exists($p->{$_}) ? ($_ => $p->{$_}) : ()} qw(user_id machine_id timestamp);

    return $self->error(400, 3401, '"user_id" is mandatory')    if !length($p->{user_id} // '');
    return $self->error(400, 3402, '"machine_id" is mandatory') if !length($p->{machine_id} // '');

    if (exists($p->{timestamp})) {
        if ($p->{timestamp} =~ /^(\d{4}\-\d\d\-\d\d)(?:\s|T|t)(\d\d:\d\d:\d\d)\D*$/) {
            $p->{timestamp} = "$1 $2";
        } else {
            return $self->error(400, 3403, '"timestamp" is incorrect');
        }
    }

    return $self->SUPER::insert($p, 1);
}

1;
