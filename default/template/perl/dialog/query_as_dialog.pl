#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetQueryAsDialog { # $query, $title, $columns, \%param ; returns dialog with resultset from query
# sub GetQueryDialog { #GetQueryAsDialog() # display result set to user
# sub GetDialogFromQuery {
# sub GetQueryFromDialog {

# $param{'id'} = dialog id

# runs specified query and returns it as a dialog using GetResultSetAsDialog()
# note: GetResultSetAsDialog() called below has some special conditions for GetAttributesDialog()
#todo this should report query error
#todo this should take @queryArgs
#todo document no_empty flag
# $flags{'no_empty'}
#todo move columns to params

	my $query = shift;
	my $title = shift;
	my $columns = shift; # optional, default is to use all the columns from the query

	my $paramHashRef = shift;
	my %flags;
	if ($paramHashRef) {
		%flags = %{$paramHashRef};
	}

	WriteLog('GetQueryAsDialog(' . $query . '); caller = ' . join(',', caller));

	if (!$query) {
		WriteLog('GetQueryAsDialog: warning: $query is FALSE; caller = ' . join(',', caller));
		return '';
	}
	if (!$title) {
		WriteLog('GetQueryAsDialog: warning: $title is FALSE; caller = ' . join(',', caller));
		$title = 'Untitled';
	}

	# 	$query = SqliteGetQueryTemplate("$query");

	$flags{'query'} = $query;

	if (index($query, ' ') == -1) {
		WriteLog('GetQueryAsDialog: adding $flags{id}');
		$flags{'id'} = $query;
	} else {
		WriteLog('GetQueryAsDialog: $query contains space, skipping addition of $flags{id}');
	}

	my @result  = SqliteQueryHashRef($query);

	#WriteLog('GetQueryAsDialog: $query = ' . $query . '; calling GetResultSetAsDialog(); caller = ' . join(',', caller));
	#commented because it prints a lot

	if (scalar(@result) < 2 && $flags{'no_empty'}) {
		# if scalar(@result) is less than 2, that means there are no results
		# it is 2 and not 1 because the first row returns the column names
		# if no_empty flag is set, we want to return an empty string here
		return '';
	} else {
		# everything seems good, get our dialog and return it
		return GetResultSetAsDialog(\@result, $title, $columns, \%flags);
	}
} # GetQueryAsDialog()

1;
