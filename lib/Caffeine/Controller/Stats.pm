package Caffeine::Controller::Stats;

=head1 DESCRIPTION

    This class provides actions for getting statistics

=cut

use Mojo::Base 'Caffeine::Controller::Base';
use POSIX qw(strftime);

sub coffee {
    my ($self) = @_;

    my $where = {};
    $where->{machine_id} = $self->stash('machine') if $self->stash('machine');
    $where->{user_id}    = $self->stash('user')    if $self->stash('user');

    my ($purchases, undef) = $self->model('Link_UserMachine')->select(undef, $where, \'timestamp');
    return $self->render_err(500, 500, "Problems with getting purchases from DB") if !$purchases;

    my $user_by_id = {map {$_->{user_id} => 1} @$purchases};
    if (%$user_by_id) {
        my ($users, undef) = $self->model('User')->select('id, login', {id => {-in => [keys %$user_by_id]}});
        return $self->render_err(500, 500, "Problems with getting users from DB") if !$users;
        %$user_by_id = map {$_->{id} => $_} @$users;
    }
    return $self->reply->not_found() if $where->{user_id} && !$user_by_id->{$where->{user_id}};

    my $machine_by_id = {map {$_->{machine_id} => 1} @$purchases};
    if (%$machine_by_id) {
        my ($machine, undef) = $self->model('Machine')->select('id, name', {id => {-in => [keys %$machine_by_id]}});
        return $self->render_err(500, 500, "Problems with getting machines from DB") if !$machine;
        %$machine_by_id = map {$_->{id} => $_} @$machine;
    }
    return $self->reply->not_found() if $where->{machine_id} && !$machine_by_id->{$where->{machine_id}};

    my $stat = [];
    for my $l (@$purchases) {
        my $u = $user_by_id->{$l->{user_id}} or next;
        my $m = $machine_by_id->{$l->{machine_id}} or next;
        push @$stat, {user => $u, machine => $m, timestamp => $l->{timestamp}};
    }

    return $self->render_ok('stat' => $stat);
}

sub level {
    my ($self) = @_;

    my $user_id = $self->stash('user');
    return $self->reply->not_found() if !$user_id;

    my ($user, undef) = $self->model('User')->select('id, login', {id => $user_id});
    return $self->render_err(500, 500, "Problems with getting user from DB") if !$user;
    $user = @$user ? $user->[0] : undef;
    return $self->reply->not_found() if !$user;

    my $periods     = 24;
    my $period_size = 3600;

    my $caffeine_inc_period = 1 * 3600;
    my $caffeine_half_life  = 5 * 3600;

    my $cur_time = time();
    my $date_till = $cur_time - $cur_time % $period_size + $period_size;
    my $date_from = $date_till - $periods * $period_size;

    # Take purchases starting from several days ago because they affect statistics
    my $purchases_from = strftime('%Y-%m-%d %H:%M:%S', localtime($date_from - 17 * $caffeine_half_life));
    my $purchases_till = strftime('%Y-%m-%d %H:%M:%S', localtime($date_till));

    my ($stmt, @bind) = $self->app->sql->select(
        $self->model('Link_UserMachine')->tname() . ' l INNER JOIN ' . $self->model('Machine')->tname() . ' m ON l.machine_id = m.id',
        'unix_timestamp(l.timestamp) as ts, m.caffeine',
        {'l.user_id' => $user_id, 'l.timestamp' => {'>=' => $purchases_from, '<' => $purchases_till}},
        \'l.timestamp',
    );
    my $purchases = $self->app->db->select($stmt, @bind);
    return $self->render_err(500, 500, "Problems with getting user's purchases from DB") if !$purchases;

    my $levels = [map {0} (0 .. ($periods - 1))];

    for (my $i = 0; $i < @$levels; $i++) {
        my $lvl_till = $date_from + ($i + 1) * $period_size;

        # Not higher then current time
        $lvl_till = $cur_time + 1 if $lvl_till > $cur_time;

        for my $p (@$purchases) {
            last if $p->{ts} >= $lvl_till;

            # Caffeine increases till... (within current level's cell)
            my $increase_till = $p->{ts} + $caffeine_inc_period;

            if ($increase_till >= $lvl_till) {
                # Increase linearly
                $levels->[$i] += $p->{caffeine} * ($lvl_till - $p->{ts}) / $caffeine_inc_period;
            } else {
                # Increase linearly and reduce exponentially
                # Use formula for half-life in exponential reduce
                $levels->[$i] += $p->{caffeine} * 0.5 ** (($lvl_till - $increase_till) / $caffeine_half_life);
            }
        }

        last if $lvl_till > $cur_time;
    }

    return $self->render_ok('level' => $levels);
}

1;
