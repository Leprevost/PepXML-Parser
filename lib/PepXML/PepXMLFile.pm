package PepXML::PepXMLFile;

use 5.010;
use strict;
use warnings;
use XML::Twig;
use Moose;
use namespace::autoclean;
use PepXML::MsmsPipelineAnalysis;

has 'msms_pipeline_analysis' => (
	is	=>	'rw',
	isa	=>	'PepXML::MsmsPipelineAnalysis',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::MsmsPipelineAnalysis->new();
    	}
	);

1;
