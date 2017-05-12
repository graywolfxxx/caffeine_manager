package Caffeine::Controller::Stats;

=head1 DESCRIPTION

    This class provides actions for getting statistics

=cut

use Mojo::Base 'Caffeine::Controller::Base';
use SQL::Abstract;

sub coffee {
    my ($self) = @_;

    my $where = {};
    $where->{machine_id} = $self->stash('machine') if $self->stash('machine');
    $where->{user_id}    = $self->stash('user')    if $self->stash('user');

    my $sql = SQL::Abstract->new;
    my ($stmt, @bind) = $sql->select($self->model('Link_UserMachine')->tname(), '*', $where, \'timestamp DESC');
    my $links = $self->app->db->select($stmt, @bind);
    return $self->render_err(500, 500, "Problems with getting purchases from DB") if !$links;

    my $user_by_id = {map {$_->{user_id} => 1} @$links};
    if (%$user_by_id) {
        ($stmt, @bind) = $sql->select($self->model('User')->tname(), 'id, login', {id => {-in => [keys %$user_by_id]}});
        my $users = $self->app->db->select($stmt, @bind);
        return $self->render_err(500, 500, "Problems with getting users from DB") if !$users;
        %$user_by_id = map {$_->{id} => $_} @$users;
    }
    return $self->reply->not_found() if $where->{user_id} && !$user_by_id->{$where->{user_id}};

    my $machine_by_id = {map {$_->{machine_id} => 1} @$links};
    if (%$machine_by_id) {
        ($stmt, @bind) = $sql->select($self->model('Machine')->tname(), 'id, name', {id => {-in => [keys %$machine_by_id]}});
        my $machine = $self->app->db->select($stmt, @bind);
        return $self->render_err(500, 500, "Problems with getting machines from DB") if !$machine;
        %$machine_by_id = map {$_->{id} => $_} @$machine;
    }
    return $self->reply->not_found() if $where->{machine_id} && !$machine_by_id->{$where->{machine_id}};

    my $stat = [];
    for my $l (@$links) {
        my $u = $user_by_id->{$l->{user_id}} or next;
        my $m = $machine_by_id->{$l->{machine_id}} or next;
        push @$stat, {user => $u, machine => $m, timestamp => $l->{timestamp}};
    }

    return $self->render_ok('stat' => $stat);
}

sub level {
    my ($self) = @_;

    my $user_id = $self->stash('user');

    my $sql = SQL::Abstract->new;
    my ($stmt, @bind) = $sql->select($self->model('User')->tname(), 'id, login', {id => $user_id});
    my $user = $self->app->db->select($stmt, @bind);
    return $self->render_err(500, 500, "Problems with getting user from DB") if !$user;

    $user = @$user ? $user->[0] : undef;
    return $self->reply->not_found() if !$user;

    ($stmt, @bind) = $sql->select(
        $self->model('Link_UserMachine')->tname(),
        '*, unix_timestamp(`timestamp`) as ts',
        # TODO: Get rid of NOW() - INTERVAL 1 DAY because it is VERY slow here
        {user_id => $user_id, timestamp => {'>' => \"NOW() - INTERVAL 1 DAY"}},
        \'timestamp',
    );
    my $links = $self->app->db->select($stmt, @bind);
    return $self->render_err(500, 500, "Problems with getting user's purchases from DB") if !$links;

    my $level = [map {0} (0 .. 23)];

    if (@$links) {
        my $day_ago = time() - 24 * 3600;
        for my $l (@$links) {
            my $diff_sec = $l->{ts} - $day_ago;
            my $hh = int($diff_sec / 3600);
            my $ss = $diff_sec % 3600;
            my $i  = $hh > 23 ? 0 : 23 - $hh; # $hh > 23 it is here just in case
            $level->[$i] += (3600 - $ss) / 3600;
            $level->[$i] = 1 if $level->[$i] > 1;
            if ($i) {
                $level->[$i - 1] += $level->[$i] + $ss / 3600 - 0.2 * ((3600 - $ss) / 3600);
                $level->[$i - 1] = 1 if $level->[$i - 1] > 1;
                $level->[$i - 1] = 0 if $level->[$i - 1] < 0;
                my $j = $i - 2;
                for (; $j >= 0 && $j <= ($i - 5); $j--) {
                    $level->[$j] += $level->[$j + 1] - 0.2;
                    $level->[$j] = 0 if $level->[$j] < 0;
                }
                if ($j) {
                    $level->[$j] += $level->[$j + 1] - 0.2 * ($ss / 3600);
                    $level->[$j] = 0 if $level->[$j] < 0;
                }
            }
        }
        for (my $i = 0; $i < @$level; $i++) {
            next if !$level->[$i];
            $level->[$i] = $level->[$i] >= 1 ? 100 : int($level->[$i] * 100 + 0.5);
        }
    }

    return $self->render_ok('level' => $level);
}

1;
