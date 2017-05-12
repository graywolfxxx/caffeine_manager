package Caffeine::DB;

=head1 DESCRIPTION

    DBI wrappers

=cut

use Time::HiRes;
use DBI;
use Caffeine::Utils qw(timeout);

=head1 METHODS

=head2 new

    Constructor

=cut

sub new {
    my ($class, %p) = @_;
    return undef unless $p{db_name} && $p{db_host} && $p{db_login};
    my $self = bless({
        _db_dbms              => $p{db_dbms} || 'mysql',
        _db_name              => $p{db_name},
        _db_host              => $p{db_host},
        _db_port              => $p{db_port} || 3306,
        _db_login             => $p{db_login},
        _db_pass              => $p{db_pass},
        _db_client_found_rows => $p{db_client_found_rows},
        _db_raise_error       => $p{db_raise_error}   || 0,
        _connect_timeout      => $p{connect_timeout}  || 1,
        _connect_attempts     => $p{connect_attempts} || 1,
    }, ref($class) || $class);
    $self->{_is_mysql} = lc($self->{_db_dbms}) eq 'mysql' ? 1 : 0;
    return $self;
}

=head2 connect

    Connects to DBMS

=cut

sub connect {
    my $self = shift;
    return if $self->{_dbh};
    my $conn_str = "dbi:$self->{_db_dbms}:database=$self->{_db_name}:host=$self->{_db_host}:port=$self->{_db_port}";
    $conn_str .= ";mysql_client_found_rows=" . ($self->{_db_client_found_rows} ? 1 : 0) if $self->{_is_mysql};
    for my $count (1 .. ($self->{_connect_attempts} || 1)) {
        warn("Connect retry " . ($count - 1)) if $count > 1;
        $self->{_dbh} = timeout(
            $self->{_connect_timeout} || 1,
            sub {
                DBI->connect(
                    $conn_str,
                    $self->{_db_login},
                    $self->{_db_pass},
                    {   PrintError           => 1,
                        RaiseError           => $self->{_db_raise_error},
                        ShowErrorStatement   => 1,
                        ($self->{_is_mysql} ? (mysql_auto_reconnect => 1, mysql_enable_utf8 => 1) : ()),
                    }
                ) or do {warn $DBI::err; return};
            }
        );
        if ($self->{_dbh}) {
            $self->{_dbh}->do("SET NAMES 'UTF8'");
            last;
        }
    }
    return;
}

=head2 disconnect

    Disonnects from DBMS

=cut

sub disconnect {
    my $self = shift;
    return if !$self->{_dbh};
    $self->{_dbh}->disconnect();
    undef $self->{_dbh};
    return;
}

sub _err {
    my $self = shift;

#   Error: 2006 (CR_SERVER_GONE_ERROR)
#   Error: 2013 (CR_SERVER_LOST)
    if (($DBI::err // '') =~ /^2006$|^2013$/) {
        $self->disconnect();
        $self->connect();
    } elsif (!$self->{_dbh}) {
        $self->connect();
    }

    return;
}

=head2 last_insert_id

    Returns id of last inserted row

=cut

sub last_insert_id {
    my $self = shift;
    return undef if !$self->{_dbh};
    return $self->{_is_mysql} ? $self->{_dbh}->{'mysql_insertid'} : undef;
}

=head2 do

    Just like DBI->do() method

=cut

sub do {
    my ($self, $query, $attr, @bind) = @_;
    $self->connect();
    return 0 if !$self->{_dbh};
    my $sth = $self->{_dbh}->prepare($query, $attr) or do { $self->_err(); return 0; };
    my $res = $sth->execute(@bind) or do { $self->_err(); return 0; };
    my $affected_rows = $sth->rows();
    return ($affected_rows == 0 ? "0E0" : $affected_rows);
}

sub select {
    my ($self, $query, @bind) = @_;
    $self->connect();
    return undef if !$self->{_dbh};
    my $sth = $self->{_dbh}->prepare($query) or do { $self->_err(); return undef; };
    my $res = $sth->execute(@bind) or do { $self->_err(); return undef; };
    my $rows = $sth->fetchall_arrayref({});
    return $rows;
}

1;
