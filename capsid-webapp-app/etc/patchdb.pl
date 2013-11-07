#!/usr/bin/env perl -w

use strict;
use warnings;

use feature qw(say);

use Data::Dumper qw(Dumper);

use MongoDB;
use Tie::IxHash;

sub open_database {
	
	my $database_name = "capsid";
    my $database_server = "localhost:27017";  
    my @options = (host => $database_server, query_timeout => -1);

	my $conn = MongoDB::Connection->new(@options);	
    my $database = $conn->get_database($database_name);

	return $database;
}

sub close_database {
  my ($database) = @_;
}


sub update_samples {
	my $db = open_database();

	my $table = {};

	$db->get_collection('sample')->ensure_index({'project' => 1});

	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	my $samples = $db->get_collection('sample');
	while(my ($key, $value) = each %$table) {
		$samples->update({project => $key}, {'$set' => {projectId => $value}, '$rename' => {project => 'projectLabel'}}, {multiple => 1});
	}

	$db->get_collection('sample')->drop_index('project_1');
	$db->get_collection('sample')->ensure_index({'projectId' => 1});

	close_database($db);
}

sub update_statistics_genomes {
	my $db = open_database();

	my $table = {};

	my $genomes = $db->get_collection('genome')->find();
	while (my $genome = $genomes->next()) {
		$table->{$genome->{name}} = $genome->{_id};
	}

	my $updates = {};
	my $statistics = $db->get_collection('statistics')->find();
	while (my $statistic = $statistics->next()) {
		$updates->{$statistic->{_id}} = $statistic->{genome};
	}

	while(my ($key, $value) = each %$updates) {
		$db->get_collection('statistics')->update({_id => MongoDB::OID->new($key)}, {'$set' => {genomeId => $table->{$value}}});
	}

	$db->get_collection('statistics')->ensure_index({'genomeId' => 1});

	close_database($db);
}

sub update_statistics_projects {
	my $db = open_database();

	$db->get_collection('statistics')->ensure_index({'label' => 1});

	my $table = {};

	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	my $statistics = $db->get_collection('statistics');
	while(my ($key, $value) = each %$table) {
		say Dumper $statistics->update({label => $key}, {'$set' => {projectId => $value}, '$rename' => {label => 'projectLabel'}}, {multiple => 1});
	}

	$db->get_collection('statistics')->drop_index('label_1');
	$db->get_collection('statistics')->ensure_index({'projectId' => 1});

	close_database($db);
}

sub update_statistics_samples {
	my $db = open_database();


	my $table = {};

	my $samples = $db->get_collection('sample')->find();
	while (my $sample = $samples->next()) {
		$table->{$sample->{name}} = $sample->{_id};
	}

	my $statistics = $db->get_collection('statistics');
	while(my ($key, $value) = each %$table) {
		say Dumper $statistics->update({sample => $key}, {'$set' => {sampleId => $value}}, {multiple => 1});
	}

	$db->get_collection('statistics')->drop_index('sample_1');
	$db->get_collection('statistics')->ensure_index({'sampleId' => 1});

	close_database($db);
}

sub update_alignments {
	my $db = open_database();

	$db->get_collection('alignment')->ensure_index({'sample' => 1});
	$db->get_collection('alignment')->ensure_index({'project' => 1});

	my $table = {};

	my $samples = $db->get_collection('sample')->find();
	while (my $sample = $samples->next()) {
		$table->{$sample->{name}} = $sample->{_id};
	}

	my $alignments = $db->get_collection('alignment');
	while(my ($key, $value) = each %$table) {
		say Dumper $alignments->update({sample => $key}, {'$set' => {sampleId => $value}}, {multiple => 1});
	}

	$table = {};
	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	while(my ($key, $value) = each %$table) {
		say Dumper $alignments->update({project => $key}, {'$set' => {projectId => $value}, '$rename' => {project => 'projectLabel'}}, {multiple => 1});
	}

	$db->get_collection('alignment')->drop_index('sample_1');
	$db->get_collection('alignment')->drop_index('project_1');

	$db->get_collection('alignment')->ensure_index({'sampleId' => 1});
	$db->get_collection('alignment')->ensure_index({'projectId' => 1});

	close_database($db);
}

# sub update_alignments2 {
# 	my $db = open_database();
#
# 	my $table = {};
#
# 	my $samples = $db->get_collection('sample')->find();
# 	while (my $sample = $samples->next()) {
# 		$table->{$sample->{projectId}}->{$sample->{name}} = $sample->{_id};
# 	}
#
# 	my $alignments = $db->get_collection('alignment');
# 	foreach my $projectId (keys %$table) {
# 		$projectId = MongoDB::OID->new($projectId);
# 		while(my ($key, $value) = each %{$table->{$projectId}}) {
# 			say Dumper $alignments->update({sample => $key, projectId => $projectId}, {'$set' => {sampleId => $value}}, {multiple => 1});
# 		}
# 	}
# }

sub update_genomes {
	my $db = open_database();

	$db->get_collection('genome')->ensure_index({'samples' => 1});

	my $table = {};

	my $samples = $db->get_collection('sample')->find();
	while (my $sample = $samples->next()) {
		$table->{$sample->{name}} = $sample->{_id};
	}

	my $genomes = $db->get_collection('genome');
	while (my ($key, $value) = each %$table) {
		say Dumper $genomes->update({samples => $key}, {'$set' => {'samples.$' => $value}}, {multiple => 1});
	}

	# Now, we should really also remove samples which aren't object identifiers
	# by this stage. 

	$genomes->update({}, {'$pull' => {samples => {'$type' => 2}}}, {multiple => 1});
}

sub update_mapped_samples {
	my $db = open_database();

	$db->get_collection('mapped')->ensure_index({'sample' => 1});

	my $table = {};

	my $samples = $db->get_collection('sample')->find();
	while (my $sample = $samples->next()) {
		$table->{$sample->{name}} = $sample->{_id};
	}

	my $mapped = $db->get_collection('mapped');
	while (my ($key, $value) = each %$table) {
		say "Updating $key";
		say Dumper $mapped->update({sample => $key}, {'$set' => {'sampleId' => $value}}, {multiple => 1});
	}

	$db->get_collection('mapped')->drop_index('sample_1');
	$db->get_collection('mapped')->ensure_index({'sampleId' => 1});
}

sub update_mapped_projects {
	my $db = open_database();

	$db->get_collection('mapped')->ensure_index({'project' => 1});

	my $table = {};

	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	my $mapped = $db->get_collection('mapped');
	while(my ($key, $value) = each %$table) {
		say "Updating $key";
		say Dumper $mapped->update({project => $key}, {'$set' => {projectId => $value}, '$rename' => {project => 'projectLabel'}}, {multiple => 1});
	}

	$db->get_collection('mapped')->drop_index('project_1');
	$db->get_collection('mapped')->ensure_index({'projectId' => 1});
}

sub update_mapped_alignments {
	my $db = open_database();

	say "Creating alignments index";
	$db->get_collection('mapped')->ensure_index({'alignment' => 1});

	my $table = {};

	my $alignments = $db->get_collection('alignment')->find();
	while (my $alignment = $alignments->next()) {
		$table->{$alignment->{name}} = $alignment->{_id};
	}

	say "Updating alignments";
	my $mapped = $db->get_collection('mapped');
	while (my ($key, $value) = each %$table) {
		say Dumper $mapped->update({alignment => $key}, {'$set' => {'alignmentId' => $value}}, {multiple => 1});
	}

	say "Dropping alignments index";
	$db->get_collection('mapped')->drop_index('alignment_1');
	say "Creating new alignments index";
	$db->get_collection('mapped')->ensure_index({'alignmentId' => 1}, {'background' => 1});
}

sub add_indexes {
	my $db = open_database();

	say "Creating feature indexes";
	$db->get_collection('feature')->ensure_index(Tie::IxHash->new('genome' => 1, 'start' => 1));

	say "Creating genome indexes";
	$db->get_collection('genome')->ensure_index({'accession' => 1});

	say "Creating mapped indexes";
	$db->get_collection('mapped')->ensure_index(Tie::IxHash->new('genome' => 1, 'sampleId' => 1, 'refStart' => 1));

	close_database($db);	
}

# update_samples();
# update_statistics_genomes();
# update_statistics_projects();
# update_genomes();
# update_statistics_samples();
# update_alignments();
# -- update_alignments2();
# update_mapped_samples();
# update_mapped_projects();
# update_mapped_alignments();

add_indexes();

1;