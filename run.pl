use strict;
use warnings;
use utf8;
use v5.10;
use lib "lib";
use PepXML::Parser;

my $p = PepXML::Parser->new();

$p->parse("t/sample.pep.xml");


