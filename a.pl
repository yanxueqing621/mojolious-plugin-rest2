use Modern::Perl;
$a = '/a/b';

$b='/a/b/dogs/:dog/cats/:cat';
say $b;

$b =~s;\Q$a\E;;g;
say $b;
