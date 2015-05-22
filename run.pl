use strict;
use warnings;
use utf8;
use v5.10;
use lib "lib";
use PepXML::Parser;
use Data::Printer;

my $p = PepXML::Parser->new();

my $pepxml = $p->parse("t/sample.pep.xml");

#my %msms = $pepxml->get_msms_pipeline_analysis();

#my ($enzymes) = $pepxml->get_sample_enzyme;
#my @enzymes = @{$enzymes};

#my $summary = $pepxml->get_run_summary();
#p $summary;

#my $search_summary = $pepxml->get_search_summary();
#p $search_summary;

#my @mods = $pepxml->get_amminoacid_modification();
#p @mods;

#my @mods = $pepxml->get_amminoacid_modification();
#p $mods[0];
	
p $pepxml->search_hit->[0];