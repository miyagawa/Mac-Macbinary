use strict;
use Test;
BEGIN { plan tests => 1 }
use Mac::Macbinary;

open FH, "t/lay.bin";
my $mb = new Mac::Macbinary \*FH;
ok($mb->header->name, "52876500R.lay");
close FH;
