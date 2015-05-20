package PepXML::Parser;

use 5.010;
use strict;
use warnings;
use XML::Twig;
use Moose;
use namespace::autoclean;
use Data::Printer;
use PepXML::PepXMLFile;
use PepXML::MsmsPipelineAnalysis;

our $VERSION = '0.01';


has 'pepxmlfile' => (
	is	=>	'rw',
	isa	=>	'PepXML::PepXMLFile',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::PepXMLFile->new();
    	}
	);
	

my $package;
	
sub parse {
	my $self = shift;
	my $file = shift;
	
	$package = $self;

	my $parser = XML::Twig->new(
		twig_handlers =>	
		{
			msms_pipeline_analysis	=>	\&parse_msms_pipeline_analysis,

		},
		pretty_print => 'indented',
	);

	$parser->parsefile($file);

	return $self->pepxmlfile;
}


sub parse_msms_pipeline_analysis {
	my ( $parser, $node ) = @_;
	
	my $mpa = PepXML::MsmsPipelineAnalysis->new();
	
	$mpa->date($node->{'att'}->{'date'});
	$mpa->xmlns($node->{'att'}->{'xmlns'});
	$mpa->xmlns_xsi($node->{'att'}->{'xmlns:xsi'});
	$mpa->xmlns_schemaLocation($node->{'att'}->{'xsi:schemaLocation'});
	$mpa->summary_xml($node->{'att'}->{'summary_xml'});	
	
	$package->pepxmlfile->msms_pipeline_analysis($mpa);
}

1;
