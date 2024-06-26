#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub DBGetAllItemsInThread { # $itemHash, $recurseLevel = 0
	my $itemHash = shift;
	my $recurseLevel = shift;

	if (!$recurseLevel) {
		$recurseLevel = 0;
	}

	#todo sanity

	#my $query = "SELECT item_hash FROM item_parent WHERE parent_hash = ? OR item_hash = ?";
	my $query = "
		SELECT
		file_hash,
		file_path,
		author_key
		FROM
		item_parent
		JOIN item_flat ON(item_parent.item_hash = item_flat.file_hash)
		WHERE parent_hash = ?
		UNION ALL
		SELECT
		file_hash,
		file_path,
		author_key
		FROM
		item_flat
		WHERE
		file_hash = ?
	";

	my %return;

	my @queryParams = ($itemHash, $itemHash);
	my @result = SqliteQueryHashRef($query, @queryParams);

	shift @result; #todo sanity check column names

	WriteLog('DBGetAllItemsInThread: $itemHash = ' . $itemHash . '; @result = ' . scalar(@result) . '; caller = ' . join(',', caller));

	for my $r (@result) {
		my %row = %{$r};
		my $key = $row{'file_hash'};

		$return{$key} = \%row;

		if ($key ne $itemHash) {
			my $subR = DBGetAllItemsInThread($key, ($recurseLevel + 1));
			my %sub = %{$subR};

			WriteLog('DBGetAllItemsInThread: $subR = ' . scalar(keys %{$subR}));

			for my $subKey (keys %sub) {
				WriteLog('DBGetAllItemsInThread: $subKey = ' . $subKey);
				my %subHash = %{$sub{$subKey}};
				$return{$subKey} = \%subHash;
			}
		}
	}

	#todo
	# only if $recurseLevel == 0:
	# collect list of authors and get each author's public key or self-id
	# select * from item_flat where author_key = ? and (labels_list like 'pubkey' or labels_list like 'my_name_is'
	# include in return
	if ($recurseLevel == 0) {
		WriteLog('DBGetAllItemsInThread: recurseLevel == 0');

        # Collect list of authors
        my @authors = map { $_->{'author_key'} } @result;

        for my $author (@authors) {
        	WriteLog('DBGetAllItemsInThread: author = ' . ($author ? $author : 'undef'));

			if ($author) {
				# Prepare and execute the query
				my $query = "
					SELECT file_hash, file_path, author_key, labels_list
					FROM item_flat
					WHERE author_key = ? AND (labels_list LIKE '%pubkey%' OR labels_list LIKE '%my_name_is%')
				";
				my @author_info = SqliteQueryHashRef($query, $author);

				shift @author_info; #todo sanity check column names

				# Include author keys
				for my $info (@author_info) {
					WriteLog('DBGetAllItemsInThread: info = ' . $info);
					my $key = $info->{'file_hash'};
					$return{$key} = $info;
				}
			}
        }
    }

	return \%return;
} # DBGetAllItemsInThread()

sub DBGetAllItemsInThreadAsArray { # $itemHash
	my $itemHash = shift;

	my $itemsRef = DBGetAllItemsInThread($itemHash);
	my %items = %{$itemsRef};

	my @ret;
	for my $key (keys %items) {
		push @ret, $items{$key};
	}

	return @ret;
}

1;