package Caffeine;

use Mojo::Base 'Mojolicious';
use Caffeine::DB;
use Caffeine::Model;

sub startup {
    my ($self) = @_;

    $self->mode('production');

    $self->secrets(['fljslfjkjadHlT;b665']);

    my $db = Caffeine::DB->new(
        db_name  => 'caffeine',
        db_host  => 'localhost',
        db_port  => 3306,
        db_login => 'root',
        db_pass  => '',
    );
    $self->helper(db => sub {$db});

    my $model = Caffeine::Model->new(app => $self);
    $self->helper(model => sub {
        my ($self, $model_name) = @_;
        return $model->get_model($model_name);
    });

    $self->hook(
        before_render => sub {
            my ($c, $args) = @_;
            return unless $c->accepts('json');
            my $template = $args->{template} || '';
            if ($template =~ /^not_found/) {
                $args->{json} = {error_code => 404, error_text => 'Resource not found'};
            } elsif ($template =~ /^exception/) {
                $args->{json} = {error_code => 500, error_text => ($self->mode() eq 'production' ? '' : $args->{exception}) || 'Internal server error'};
            }
        }
    );

    my $r = $self->routes()->route('/', format => 'json');
    $r->put('user/request')->to('user#register');
    $r->post('machine')->to('machine#register');
    $r->any(['GET', 'PUT'] => 'coffee/buy/:user/:machine')->to('Link_UserMachine#buy');
    $r->get('stats/coffee')->to('stats#coffee');
    $r->get('stats/coffee/machine/:machine')->to('stats#coffee');
    $r->get('stats/coffee/user/:user')->to('stats#coffee');
    $r->get('stats/level/user/:user')->to('stats#level');
}

1;
