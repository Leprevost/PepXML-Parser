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
	
	
sub get_msms_pipeline_analysis {
	my $self = shift;
	
	my %map;
	
	$map{'date'} = $self->msms_pipeline_analysis->date;
	$map{'xmlns'} = $self->msms_pipeline_analysis->xmlns;
	$map{'xmlns_xsi'} = $self->msms_pipeline_analysis->xmlns_xsi;
	$map{'xmlns_schemaLocation'} = $self->msms_pipeline_analysis->xmlns_schemaLocation;
	$map{'summary_xml'} = $self->msms_pipeline_analysis->summary_xml;
	
	return %map;		
}

1