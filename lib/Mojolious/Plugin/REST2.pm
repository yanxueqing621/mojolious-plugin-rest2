package Mojolious::Plugin::REST2;
use Modern::Perl;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Exception;
use Lingua::EN::Inflect 1.895 qw/PL/;

# VERSION
# ABSTRACT: Mojolious::Plugin::REST2

=head1 SYNOPSIS

  use Mojolious::Plugin::REST2
  ..


=head1 DESCRIPTION

=cut

my $http2crud = {
    collection => {
        get  => 'list',
        post => 'create',
    },
    resource => {
        get    => 'read',
        put    => 'update',
        delete => 'delete'
    },
};
 
has install_hook => 1;


sub register {
  my $self = shift;
  my $app = shift;
  my $options = { ref $_[0] ? %{ $_[0] } : @_};
  my $url_prefix = $options->{prefix} || '';
  $url_prefix =~/^\// or $url_prefix = '/' . $url_prefix;

  # override default http2crud mapping from options...
  if ( exists( $options->{http2crud} ) ) {
      foreach my $method_type ( keys( %{$http2crud} ) ) {
          next unless exists $options->{http2crud}->{$method_type};
          foreach my $method ( keys( %{ $http2crud->{$method_type} } ) ) {
              next unless exists $options->{http2crud}->{$method_type}->{$method};
              $http2crud->{$method_type}->{$method} = $options->{http2crud}->{$method_type}->{$method};
          }
      }
  }

  # install app hook if not disabled...
  $self->install_hook(0) if ( defined( $options->{hook} ) and $options->{hook} == 0 );
  if ( $self->install_hook ) {
      $app->hook(
          before_render => sub {
              my $c = shift;
              my $path_substr = substr "" . $c->req->url->path, 0, length $url_prefix;
              if ( $path_substr eq $url_prefix ) {
                  my $json = $c->stash('json');
                  unless ( defined $json->{data} ) {
                      $json->{data} = {};
                      $c->stash( 'json' => $json );
                  }
              }
          }
      );
  }
  
  $app->routes->add_short_cut(   
    rest_routes => sub{
      my $routes = shift;
      my $params = { ref $_[0] ? %{ $_[0] } : @_ };
      Mojo::Exception->throw('Route name is required in rest_routes') unless defined $params->{name};
      
    }
  );

}






1;
