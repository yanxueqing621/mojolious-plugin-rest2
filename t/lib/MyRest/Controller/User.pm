package MyRest::Controller::User;

use Mojo::Base 'Mojolicious::Controller';
 
sub list_user{
    my $self = shift;
    $self->render( json => { data => [ { id => 1, name => 'mysql' }, { id => 2, name => 'mails' } ] } );
}
 
sub create_user{
    my $self = shift;
    $self->render( json => { data => { id => $self->req->json->{id}, name => $self->req->json->{name} } } );
}
 
sub read_user{
    my $self = shift;
    $self->render(
        json => { data => { id => $self->stash('userId') } }
    );
}
 
sub update_user{
    my $self = shift;
    $self->render(
        json => { data => { id => $self->stash('userId') } } );
}
 
sub delete_user{
    my $self = shift;
    $self->render(
        json => { data => { id => $self->stash('userId') } } );
}
1;
