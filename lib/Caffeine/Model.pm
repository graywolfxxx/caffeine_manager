package Caffeine::Model;

use Mojo::Loader qw(find_modules load_class);
use Mojo::Base -base;

use Carp qw(croak);

has modules => sub { {} };

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    my $cur_pkg_name = __PACKAGE__;
    my $model_base_name = {($cur_pkg_name . '::Base') => 1};
    #my $model_packages = Mojo::Loader->search($cur_pkg_name);
    my @model_packages = find_modules($cur_pkg_name);
    for my $pm (grep {!$model_base_name->{$_}} @model_packages) {
        #my $e = Mojo::Loader->load($pm);
        my $e = load_class($pm);
        croak "Loading '$pm' failed: $e" if ref $e;
        my ($basename) = $pm =~ /^\Q$cur_pkg_name\E::(.*)$/;
        $self->modules->{$basename} = $pm->new(%args);
    }
    return $self;
}

sub get_model {
    my ($self, $model) = @_;
    return $self->modules->{$model // ''} || croak "Unknown model '" . ($model // '') . "'";
}

1;
