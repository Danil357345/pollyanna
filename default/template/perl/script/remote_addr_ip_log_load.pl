#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

require('./utils.pl');

sub LoadIntoDatabase { # Load remote_addr.log into remote_addr_ip_log table
	my $log = GetFile('log/remote_addr.log');
	my $linesLoaded = 0;

	if (defined($log) && $log) {
		my @lines = split("\n", $log);
		# create table if needed
		my $query = "
			CREATE TABLE IF NOT EXISTS remote_addr_ip_log (
				file_hash,
				remote_addr,
				first_three_octets,
				first_two_octets
			)
		";
		SqliteQuery($query);
		foreach my $line (@lines) {
			my ($file_hash, $remote_addr) = split('\|', $line);
			if ($file_hash && $remote_addr) {
				my $first_three_octets = join('.', (split('\.', $remote_addr))[0..2]);
				my $first_two_octets = join('.', (split('\.', $remote_addr))[0..1]);
				$query = GetTemplate('query/insert/remote_addr_ip_log.sql');
				SqliteQuery($query, $file_hash, $remote_addr, $first_three_octets, $first_two_octets);
				$linesLoaded++;
			}
		}
	}

	WriteLog("LoadIntoDatabase: $linesLoaded lines loaded into remote_addr_ip_log");
	WriteMessage("LoadIntoDatabase: $linesLoaded lines loaded into remote_addr_ip_log");
} # LoadIntoDatabase()

SetSqliteDbName('remote.sqlite3');

LoadIntoDatabase();

1;
