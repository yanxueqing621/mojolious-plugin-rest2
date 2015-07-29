package Mojolicious::Plugin::REST2;
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

=head1 install_hook

=cut

has install_hook => 1;

sub register {
  my $self = shift;
  my $app = shift;
  my $options = { ref $_[0] ? %{ $_[0] } : @_};

  # prefix, version, stuff...
  my $url_prefix = '';
  my $version = $options->{version};
  foreach my $modifier (qw(prefix version)) {
      if ( defined $options->{$modifier} && $options->{$modifier} ne '' ) {
          $url_prefix .= "/" . $options->{$modifier};
      }
  }

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

  $app->helper( data => sub{
    my $self = shift;
    my %data = ref $_[0] ? %{ $_[0] } : @_;

    my $json = $self->stash('json');
    if ( defined $json and defined  $json->{data} ){
      @{ $json->{ data } }{ keys %data } = values %data;
    }else{
      $json->{data} = \%data;
    }
    $self->stash( json => $json );
    return $self;
  });

  $app->helper( message => sub {
    my $self = shift;
    my ( $message, $severity ) = @_;
    $severity //= 'info';
    my $json = $self->stash('json');

    if( defined $json->{messages} ) {
      push $json->{messages}, { text => $message, severity => $severity } ;
    } else {
      $json->{messages} = [ { text => $message, severity => $severity } ];
    }

    $self->stash( json => $json );
    return $self;
  });

  $app->helper( message_warn => sub {
    my $self = shift;
    $self->message( shift, 'warn' );
    return $self;
  });


  $app->routes->add_shortcut(
    rest_routes => sub{
      my $routes = shift;
      my $params = { ref $_[0] ? %{ $_[0] } : @_ };
      Mojo::Exception->throw('Route name is required in rest_routes') unless defined $params->{name};

      # check whether current route is contain prefix or version
      my $route_name_prefix = $routes->name;
      my $url_prefix = $routes->to_string =~/$url_prefix/ ? '' : $url_prefix;

      # name setting
      my $route_name = lc $params->{name};
      my $controller = $route_name;
      my $route_name_plural = PL( $route_name, 10);
      my $route_id = ':'. $route_name . "Id";
      $route_name_prefix and $route_name = $route_name_prefix . "_" . $route_name;

      # build collection and resources  routes
      for my $resource_type ( keys %{ $http2crud } ) {

        # http_crud signify 'get' 'put' etc HTTP operation
        for my $http_crud ( keys %{ $http2crud->{$resource_type} } ){
          $params->{methods}
            and index( $params->{methods}, substr( $http2crud->{$resource_type}->{$http_crud}, 0, 1 ) ) == -1
            and next;

          # controller_crud signify 'read','update' etc in controller's method
          my $controller_crud = $http2crud->{$resource_type}->{$http_crud};
          my $action = $controller_crud . "_" . $route_name;

          # obtain current url for route
          my $url = $resource_type eq 'collection' 
            ? "/$route_name_plural"
            : "/$route_name_plural/$route_id";

          $routes->route("${url_prefix}$url")->via($http_crud)
            ->to(controller => ucfirst $controller, action => $action)
            ->name($action);
        }
      }
      return $routes->route("$url_prefix/$route_name_plural/$route_id")->name($route_name);
    }
  );
}

1;
