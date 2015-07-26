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
  my $options = {@_ ? (ref $_[0] ? %{ $_[0] : @_) : ()};



}






1;
