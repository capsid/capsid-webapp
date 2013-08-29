#!/usr/bin/env perl -w

use strict;
use warnings;

use feature qw(say);

use Data::Dumper qw(Dumper);

use MongoDB;

sub open_database {
	
	my $database_name = "capsid";
    my $database_server = "localhost:27017";  
    my @options = (host => $database_server);

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

	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	my $samples = $db->get_collection('sample');
	while(my ($key, $value) = each %$table) {
		$samples->update({project => $key}, {'$set' => {projectId => $value}, '$rename' => {project => 'projectLabel'}});
	}

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

	close_database($db);
}

sub update_statistics_projects {
	my $db = open_database();

	my $table = {};

	my $projects = $db->get_collection('project')->find();
	while (my $project = $projects->next()) {
		$table->{$project->{label}} = $project->{_id};
	}

	my $statistics = $db->get_collection('statistics');
	while(my ($key, $value) = each %$table) {
		say Dumper $statistics->update({label => $key}, {'$set' => {projectId => $value}, '$rename' => {label => 'projectLabel'}}, {multiple => 1});
	}

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

	close_database($db);
}


# update_samples();
# update_statistics_genomes();
# update_statistics_projects();
update_statistics_samples();

1;