package Caffeine::Model::Base;

use Mojo::Base -base;

has 'app';

sub tname {
    my ($self) = @_;
    warn "You must redefine method 'tname' in '" . (ref($self) || $self) . "'";
    return '';
}

sub entity_name {'entity'}
sub entity_name_plur {'entities'}

sub insert {
    my ($self, $p, $no_insert_id) = @_;

    $p = {} if !$p;

    my ($stmt, @bind) = $self->app->sql->insert($self->tname(), $p);
    my $res = $self->app->db->do($stmt, undef, @bind);
    return $self->error(500, 500, "Can't add new " . $self->entity_name() . " to DB") if !$res;

    return $no_insert_id ? $res : $self->app->db->last_insert_id();
}

sub select {
    my ($self, $fields, $where, $order, $limit) = @_;
    my ($stmt, @bind) = $self->app->sql->select($self->tname(), $fields || '*', $where, $order);
    if ($limit && !ref($limit)) {
        $stmt .= ' LIMIT ' . $limit;
    } elsif ($limit && ref($limit) eq 'ARRAY') {
        if (@$limit == 1) {
            $stmt .= ' LIMIT ' . $limit->[0];
        } elsif (@$limit == 2) {
            $stmt .= ' LIMIT ' . $limit->[0] . ', ' . $limit->[1];
        }
    }
    my $res = $self->app->db->select($stmt, @bind);
    return $self->error(500, 500, "Can't select " . $self->entity_name_plur() . " from DB") if !$res;
    return $res;
}

sub count {
    my ($self, $where) = @_;
    my ($stmt, @bind) = $self->app->sql->select($self->tname(), 'count(*) AS cnt', $where);
    my $res = $self->app->db->select($stmt, @bind);
    return $self->error(500, 500, "Can't select count of " . $self->entity_name_plur() . " from DB") if !$res;
    return $res && @$res ? $res->[0]->{cnt} : 0;
}

sub error {
    my ($self, $http_status, $error_code, $error_text, %rsp) = @_;
    $http_status = 400 if !$http_status || $http_status < 400;
    $rsp{error_code} = $error_code || $http_status;
    $rsp{error_text} = $error_text || 'Unknown error';
    return undef, {error => \%rsp, status => $http_status};
}

1;
