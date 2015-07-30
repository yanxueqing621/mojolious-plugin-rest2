package Mojolicious::Plugin::REST2;
use Modern::Perl;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Exception;
use Lingua::EN::Inflect 1.895 qw/PL/;

# VERSION
# ABSTRACT: Mojolious::Plugin::REST2

=head1 NAME

Mojolious::Plugin::REST2 - Mojolicious Plugin for building RESTful routes

=head1 SYNOPSIS

    # In Mojolicious Application
    $self->plugin( 'REST' => { prefix => 'api', version => 'v1' } );

    $routes->rest_routes( name => 'account' );

    # Installs following routes:

    # /api/v1/accounts              ....  GET     "list_account()"    ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts              ....  POST    "create_account()"  ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId   ....  DELETE  "delete_account()"  ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId   ....  GET     "read_account()"    ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId   ....  PUT     "update_account()"  ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
 
 
    $routes->rest_routes( name => 'account')->rest_routes( name => 'feature');

    # Installs following routes:
 
    # /api/v1/accounts                                  ....  GET       "list_account()"                  ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts                                  ....  POST      "create_account()"                ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId                       ....  DELETE    "delete_account()"                ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId                       ....  GET       "read_account()"                  ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId                       ....  PUT       "update_account()"                ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId/features              ....  GET       "list_account_feature()"          ^/api/v1/accounts/([^\/\.]+)/features
    # /api/v1/accounts/:accountId/features              ....  POST      "create_account_feature()"        ^/api/v1/accounts/([^\/\.]+)/features
    # /api/v1/accounts/:accountId/features/:featureId   ....  DELETE    "delete_account_feature()"        ^/api/v1/accounts/([^\/\.]+)/features/([^\/\.]+)
    # /api/v1/accounts/:accountId/features/:featureId   ....  GET       "read_account_feature()"          ^/api/v1/accounts/([^\/\.]+)/features/([^\/\.]+)
    # /api/v1/accounts/:accountId/features/:featureId   ....  PUT       "update_account_feature()"        ^/api/v1/accounts/([^\/\.]+)/features/([^\/\.]+)

    $routes->rest_routes( name => 'account')->rest_routes( name => 'feature')->rest_routes( name => 'other');
    .......
    .......


=head1 DESCRIPTION

L<Mojolicious::Plugin::REST2> adds various helpers for L<REST|http://en.wikipedia.org/wiki/Representational_state_transfer>ful
L<CRUD|http://en.wikipedia.org/wiki/Create,_read,_update_and_delete> operations via
L<HTTP|http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol> to your mojolicious application.

As much as possible, it tries to follow L<RESTful API Design|https://blog.apigee.com/detail/restful_api_design> principles from Apigee.

L<Mojolicious::Plugin::REST2/rest_routes> shortcut could be used in conjuction with L<Mojolicious::Plugin::REST2/data> and L<Mojolicious::Plugin::REST2/message> helper etc, this module makes building RESTful application a breeze.

This module is inspired from L<Mojolicious::Plugin::REST>.
There are two reasons why I writed this module. One is that some function is not available such as 'under' parameter in L<Mojolicious::Plugin::REST/rest_routes> due to the update of Mojolicious. Anther is that i want to make this module more convinient to use.

The most different between L<Mojolicious::Plugin::REST2> and L<Mojolicious::Plugin::REST> is as below:
1. you could build a multilevel related routes more convenient and explicit, see example above.
2. you could use L<Mojolicious::Plugin::REST2/data> and L<Mojolicious::Plugin::REST2/message> etc helper rather than inheriting L<Mojolicious::Controller::REST>. due to other functions are mostly similar, so I named this module L<Mojolicious::Plugin::REST2>

=head1 PLUGIN OPTIONS

=over

=item prefix

If present, this value will be added as prefix to all routes created.

=item version

If present, this value will be added as prefix to all routes created but after prefix.

=item htt2crud

If present, given HTTP to CRUD mapping will be used to determine method names in controller. Default mapping:

    {
        collection => {
            get  => 'list',
            post => 'create',
        },
        resource => {
            get    => 'read',
            put    => 'update',
            delete => 'delete'
        }
    }

=back


=head1 Routes shortcut


=head2 rest_routes

A routes shortcut to easily add RESTful routes and multilevel nested routes.

Following options can be used to control route creation:


=over

=item methods

This option can be used to control which methods are created for declared rest_route. Each character in the value of this option,
determined if corresponding route will be created or ommited(default:crudl). For Example:

    $routes->rest_routes( name => 'account', methods => 'crudl' );

This will install all the rest routes, value 'crudl' signifies:

    c - create
    r - read
    u - update
    d - delete
    l - list.

Only methods whose first character is mentioned in the value for this option will be created. For Example:

    $routes->rest_routes( name => 'account', methods => 'crd' );

This will install only create, read and delete routes as below:

    # /api/v1/accounts             ....  POST    "create_account()"  ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId  ....  DELETE  "delete_account()"  ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?
    # /api/v1/accounts/:accountId  ....  GET     "read_account()"    ^/api/v1/accounts/([^\/\.]+)(?:\.([^/]+)$)?

option value 'crd' signifies,
    c - create,
    r - read,
    d - delete

you could set current route a collection as below:


    # create a collection routes

    $routes->rest_routes( name => 'Account', methods => 'cl' ); # will install routes as below:

    # /api/v1/accounts  ....  GET   "list_account()"    ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts  ....  POST  "create_account()"  ^/api/v1/accounts(?:\.([^/]+)$)?

    # the subroutes below collection will install routes just like below:
    $routes->rest_routes( name => 'accout', method => 'lc')-> (name => 'feature', method => 'rl');
    # /api/v1/accounts                       ....  GET       "list_account()"            ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts                       ....  POST      "create_account()"          ^/api/v1/accounts(?:\.([^/]+)$)?
    # /api/v1/accounts/features              ....  GET       "list_account_feature()"    ^/api/v1/accounts/([^\/\.]+)/features
    # /api/v1/accounts/features/:featureId   ....  GET       "read_account_feature()"    ^/api/v1/accounts/([^\/\.]+)/features/([^\/\.]+)


=item name

The name of the resource, e.g. 'user'. This name will be used to build the route url as well as the controller name, which is case-insensitive.

=item controller

By default, resource name will be converted to CamelCase controller name. You can change it by providing controller name.

If customized, this options needs a full namespace of the controller class.

=back


=head1 HELPERS

=head2 data

Sets the data element in 'data' array in JSON output. Returns controller object so that other method calls can be chained.

  $self->data( hello  => 'world' );
  # renders json response as:
  {
      "data":
      {
          "hello": "world"
      }
  }

  # chained to call message helper;
  $self->data( hello  => 'world' )->message('Something went wrong');
  # renders json response as:
  {
      "data":
      {
          "hello": "world"
      },
      "messages":
      [
          {
              "severity": "info",
              "text": "Something went wrong"
          }
      ]
  }


=head2 message

Sets an individual message in 'messages' array in JSON output. Returns controller object so that other method calls can be chained.

B<if the url you accessed is under '/prefix/version' but not exist, 
it's will render json = { data : {}, messages : [ {severity: 'error', text: 'route that you accessed  is not exist'} ]>

A custom severity value can be used by calling C<message> as(default: 'info'):

  $self->message('Something went wrong', 'fatal');

  # renders json response as:
  {
      "messages":
      [
          {
              "text": "Something went wrong",
              "severity": "fatal"
          }
      ]
  }

=head2 message_warn

Similar to message, but with severity = 'warn'. Returns controller object so that other method calls can be chained.


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
          }
          unless ( defined $c->match->stack->[0]){
            $json->{message} = [ { severity => 'error', text => 'route that you accessed  is not exist' } ] ;
          }
          $c->stash( 'json' => $json );
        }
      }
    );
  }

  $app->helper( data => sub{
    my $self = shift;
    my %data = ref $_[0] ? %{ $_[0] } : @_;

    my $json = $self->stash('json');
    $json = { data => {}, message => [] } unless defined $json;
    @{ $json->{ data } }{ keys %data } = values %data;
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
      my $controller = $params->{controller} ? lc $params->{controller} : $route_name;
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
          my $controller_crud =  $http2crud->{$resource_type}->{$http_crud};
          my $action = $controller_crud . "_" . $route_name;

          # obtain current url for route
          my $url = $resource_type eq 'collection' 
            ? "/$route_name_plural"
            : "/$route_name_plural/$route_id";

          $routes->route("${url_prefix}$url")->via($http_crud)
            ->to("$controller#$action")
            ->name($action);
        }
      }
      #  return $routes->route("$url_prefix/$route_name_plural/$route_id")->name($route_name);
      if (defined $params->{methods} and $params->{methods} !~ /[rdu]/ ) {
        return $routes->route("$url_prefix/$route_name_plural")->name($route_name);
      } else {
        return $routes->route("$url_prefix/$route_name_plural/$route_id")->name($route_name);
      }

    }
  );
}

1;
