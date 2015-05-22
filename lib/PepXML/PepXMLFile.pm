package PepXML::PepXMLFile;

use 5.010;
use strict;
use warnings;
use XML::Twig;
use Moose;
use namespace::autoclean;
use PepXML::MsmsPipelineAnalysis;
use PepXML::Enzyme;
use PepXML::RunSummary;
use PepXML::SearchHit;

has 'msms_pipeline_analysis' => (
	is	=>	'rw',
	isa	=>	'PepXML::MsmsPipelineAnalysis',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::MsmsPipelineAnalysis->new();
    	}
	);
	
has 'sample_enzyme' => (
	is	=>	'rw',
	isa	=>	'ArrayRef[PepXML::Enzyme]',
	);
	
has 'msms_run_summary' => (
	is	=>	'rw',
	isa	=>	'PepXML::RunSummary',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::RunSummary->new();
    	}
	);
	
has 'search_summary' => (
	is	=>	'rw',
	isa	=>	'PepXML::SearchSummary',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::SearchSummary->new();
    	}
	);
	
has 'search_hit' => (
	is	=>	'rw',
	isa	=>	'ArrayRef[PepXML::SearchHit]',
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

sub get_sample_enzyme {
	my $self = shift;
	
	my @list = $self->sample_enzyme;
	
	return @list;
}

sub get_run_summary {
	my $self = shift;
	
	return $self->msms_run_summary;	
}

sub get_search_summary {
	my $self = shift;
	
	return $self->search_summary;	
}

sub get_amminoacid_modification {
	my $self = shift;
	
	my $ref = $self->search_summary->aminoacid_modification;
	my @deref = @{$ref};
	
	return @deref;	
}

sub get_parameters {
	my $self = shift;
	
	my $ref = $self->search_summary->parameter;
	my @deref = @{$ref};
	
	return @deref;	
}

1