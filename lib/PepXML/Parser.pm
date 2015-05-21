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
use PepXML::Enzyme;
use PepXML::RunSummary;
use PepXML::SearchSummary;
use PepXML::SearchDatabase;
use PepXML::AAModification;
use PepXML::SpectrumQuery;
use PepXML::SearchHit;
use PepXML::SearchScore;

our $VERSION = '0.01';


#globals
my $package;
my @enzyme_list;
my @aamod_list;
my @param_list;
my @spec_query_list;
my @search_hit_list;
my @search_score_list;


has 'pepxmlfile' => (
	is	=>	'rw',
	isa	=>	'PepXML::PepXMLFile',
	default => sub {
    	my $self = shift;
        return my $obj = PepXML::PepXMLFile->new();
    	}
	);
	
	
sub parse {
	my $self = shift;
	my $file = shift;
	
	$package = $self;

	my $parser = XML::Twig->new(
		twig_handlers =>	
		{
			msms_pipeline_analysis	=>	\&parse_msms_pipeline_analysis,
			sample_enzyme			=>	\&parse_sample_enzyme,
			msms_run_summary		=>	\&parse_msms_run_summary,
			search_summary			=>	\&parse_search_summary,
			#spectrum_query			=>	\&parse_spectrum_query,

		},
		pretty_print => 'indented',
	);

	$parser->parsefile($file);
	
	#from globals to object
	$package->pepxmlfile->sample_enzyme(\@enzyme_list);
	
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


sub parse_sample_enzyme {
	my ( $parser, $node ) = @_;
	
	my $enz = PepXML::Enzyme->new();
	
	$enz->name($node->{'att'}->{'name'});
	
	my @subnodes = $node->children;
	
	for my $sn ( @subnodes ) {
		
		$enz->cut($sn->{'att'}->{'cut'});
		$enz->no_cut($sn->{'att'}->{'no_cut'});
		$enz->sense($sn->{'att'}->{'sense'});
	}
	
	push(@enzyme_list, $enz);	
}


sub parse_msms_run_summary {
	my ( $parser, $node ) = @_;
	
	my $rs = PepXML::RunSummary->new();
	
	$rs->base_name($node->{'att'}->{'base_name'});
	$rs->msManufacturer($node->{'att'}->{'msManufacturer'});
	$rs->msModel($node->{'att'}->{'msModel'});
	$rs->raw_data_type($node->{'att'}->{'raw_data_type'});
	$rs->raw_data($node->{'att'}->{'raw_data'});
	
	$package->pepxmlfile->msms_run_summary($rs);
}


sub parse_search_summary {
	my ( $parser, $node ) = @_;
	
	my $sm = PepXML::SearchSummary->new();
	
	$sm->base_name($node->{'att'}->{'base_name'});
	$sm->search_engine($node->{'att'}->{'search_engine'});
	$sm->search_engine_version($node->{'att'}->{'search_engine_version'});
	$sm->precursor_mass_type($node->{'att'}->{'precursor_mass_type'});
	$sm->fragment_mass_type($node->{'att'}->{'fragment_mass_type'});
	$sm->search_id($node->{'att'}->{'search_id'});
	
	my @subnodes = $node->children;
	
	for my $sn ( @subnodes ) {
		
		if ( $sn->name eq 'search_database' ) {
			
			my $sb = PepXML::SearchDatabase->new();
			
			$sb->local_path($sn->{'att'}->{'local_path'});
			$sb->type($sn->{'att'}->{'type'});
			
			$sm->search_database($sb);
				
		} elsif ( $sn->name eq 'enzymatic_search_constraint' ) {
		
			my $esc = PepXML::EnzSearchConstraint->new();
			
			$esc->enzyme($sn->{'att'}->{'enzyme'});
			$esc->max_num_internal_cleavages($sn->{'att'}->{'max_num_internal_cleavages'});
			$esc->min_number_termini($sn->{'att'}->{'min_number_termini'});
			
			$sm->enzymatic_search_constraint($esc);
		
		} elsif ( $sn->name eq 'aminoacid_modification' ) {
			
			my $aam = PepXML::AAModification->new();
			
			$aam->aminoacid($sn->{'att'}->{'aminoacid'});
			$aam->massdiff($sn->{'att'}->{'massdiff'});
			$aam->mass($sn->{'att'}->{'mass'});
			$aam->variable($sn->{'att'}->{'variable'});
			$aam->symbol($sn->{'att'}->{'symbol'}) if defined $sn->{'att'}->{'symbol'};
			
			push(@aamod_list, $aam);
			
			$sm->aminoacid_modification(\@aamod_list);
			
		} elsif ( $sn->name eq 'parameter' ) {
			
			my $pm = PepXML::Parameter->new();
			
			$pm->name($sn->{'att'}->{'name'});
			$pm->value($sn->{'att'}->{'value'});
			
			push(@param_list, $pm);
			
			$sm->parameter(\@param_list);	
		}
	
	}
	
	$package->pepxmlfile->search_summary($sm);

}


sub parse_spectrum_query {
	my ( $parser, $node ) = @_;
	
	if ( $node->name eq 'spectrum_query' ) {
		
		my $sq = PepXML::SpectrumQuery->new();
		
		$sq->spectrum($node->{'att'}->{'spectrum'});
		$sq->start_scan($node->{'att'}->{'start_scan'});
		$sq->end_scan($node->{'att'}->{'end_scan'});
		$sq->precursor_neutral_mass($node->{'att'}->{'precursor_neutral_mass'});
		$sq->assumed_charge($node->{'att'}->{'assumed_charge'});
		$sq->index($node->{'att'}->{'index'});
		$sq->retention_time_sec($node->{'att'}->{'retention_time_sec'});
		
		my @subnodes_1 = $node->children;
		
		for my $sn1 ( @subnodes_1 ) {
			
			my @subnodes_2 = $sn1->children;
			
			for my $sn2 ( @subnodes_2 ) {
					
				my $sh = PepXML::SearchHit->new();
				
				$sh->hit_rank($sn2->{'att'}->{'hit_rank'});
				$sh->peptide($sn2->{'att'}->{'peptide'});
				$sh->peptide_prev_aa($sn2->{'att'}->{'peptide_prev_aa'});
				$sh->peptide_next_aa($sn2->{'att'}->{'peptide_next_aa'});
				$sh->protein($sn2->{'att'}->{'protein'});
				$sh->num_tot_proteins($sn2->{'att'}->{'num_tot_proteins'});
				$sh->num_matched_ions($sn2->{'att'}->{'num_matched_ions'});
				$sh->tot_num_ions($sn2->{'att'}->{'tot_num_ions'});
				$sh->calc_neutral_pep_mass($sn2->{'att'}->{'calc_neutral_pep_mass'});
				$sh->massdiff($sn2->{'att'}->{'massdiff'});
				$sh->num_tol_term($sn2->{'att'}->{'num_tol_term'});
				$sh->num_missed_cleavages($sn2->{'att'}->{'num_missed_cleavages'});
				$sh->num_matched_peptides($sn2->{'att'}->{'num_matched_peptides'});
				
				my @subnodes_3 = $sn2->children;
				
				for my $sn3 ( @subnodes_3 ) {
					
					if ( $sn3->name eq 'search_score' ) {
						
						my $sc = PepXML::SearchScore->new();
						
						$sc->name($sn3->{'att'}->{'name'});
						$sc->value($sn3->{'att'}->{'value'});
						
						push(@search_score_list, $sc);
						$sh->search_score(\@search_score_list);
					}
				}
				
				push(@search_hit_list, $sh);
				$sq->search_hit(\@search_hit_list);
				
			}
		}
	}
	
	#$package->pepxmlfile->search_summary($sm);
}

1;