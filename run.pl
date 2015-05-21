use strict;
use warnings;
use utf8;
use v5.10;
use lib "lib";
use PepXML::Parser;
use Data::Printer;

my $p = PepXML::Parser->new();

my $pepxml = $p->parse("t/sample.pep.xml");

my %msms = $pepxml->get_msms_pipeline_analysis();

p %msms;
