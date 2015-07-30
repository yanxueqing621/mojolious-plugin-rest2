use Modern::Perl;
use Test::More;
use Test::Mojo;
use FindBin;
use lib "$FindBin::Bin/lib";
my $module = 'Mojolious::Plugin::REST2';

my $t = Test::Mojo->new('MyRest');
# get request to collection returns correct collection...
$t->get_ok('/api/v1/users')->status_is(200)
    ->json_is( { data => [ { id => 1, name => 'mysql' }, { id => 2, name => 'mails' } ] } );
 
# post request to collection returns added item
$t->post_ok( '/api/v1/users' => json => { id => 3, name => 'newuser' } )->status_is(200)
    ->json_is( { data => { id => 3, name => 'newuser' } } );
 
# get request to individual item returns that item
$t->get_ok('/api/v1/users/1')->status_is(200)
    ->json_is( { data => { id => 1 } } );
 
# put request to individual item returns that item
$t->put_ok('/api/v1/users/1')->status_is(200)
    ->json_is( { data => { id => 1  } } );
 
# delete request to individual item returns that item
$t->delete_ok('/api/v1/users/1')->status_is(200)
    ->json_is( { data => { id => 1 } } );


# get request to collection returns correct collection...
$t->get_ok('/api/v1/users/1/features')->status_is(200)
    ->json_is( { data => [ { id => 1, name => 'mysql' }, { id => 2, name => 'mails' } ] } );
 
# post request to collection returns added item
$t->post_ok( '/api/v1/users/1/features' => json => { id => 3, name => 'newfeature' } )->status_is(200)
    ->json_is( { data => { id => 3, name => 'newfeature' } } );
 
# get request to individual item returns that item
$t->get_ok('/api/v1/users/1/features/1')->status_is(200)
    ->json_is( { data => { id => 1, features => [ { id => 'mysql' }, { id => 'mails' } ] } } );
 
# put request to individual item returns that item
$t->put_ok('/api/v1/users/1/features/10')->status_is(200)->json_is( { data => { id => 1, feature => { id => 10 } } } );
 
# delete request to individual item returns that item
$t->delete_ok('/api/v1/users/1/features/10')->status_is(200)->json_is( { data => { id => 1, feature => { id => 10 } } } );


## if the url you accessed is not exist, it's will return the error information
$t->get_ok('/api/v1/users/1/featuresaaaa')->status_is(404)
    ->json_is( { data => { }, message => [ { severity => 'error', text => 'route that you accessed  is not exist' } ] } );


done_testing;

