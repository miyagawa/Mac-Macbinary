use strict;
use Test;
BEGIN { plan tests => 1 }
use Mac::Macbinary;

eval {
    my $mb = new Mac::Macbinary "foo.txt";
};

ok($@ =~ /Can't read foo\.txt/);
