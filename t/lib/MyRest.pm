package MyRest;
use Modern::Perl;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;
    $self->plugin( REST2 => { prefix => 'api', version => 'v1' } );
    my $r = $self->routes;
    $r->rest_routes( name => 'user' )->rest_routes( name =>'feature' );
}

1;
