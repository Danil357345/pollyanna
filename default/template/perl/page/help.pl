#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetHelpPage { # returns html for help page (/help.html)
# sub GetHelpDialog()
# sub GetMenuPage()
	WriteLog('GetHelpPage()');

	my $txtIndex = "";

	$txtIndex =
		GetPageHeader('help') .
		GetTemplate('html/maincontent.template') .
		GetDialogX(GetTemplate('html/page/help.template'), 'Help') .
		GetDialogX(GetTemplate('html/page/help_diagnostics.template'), 'Toys') .
		GetDialogX(GetTemplate('html/page/help_views.template'), 'Views') .
		GetDialogX('<a href="https://www.github.com/gulkily/pollyanna">github.com/gulkily/pollyanna</a>', 'Source Code') .
		GetStatsTable() .
		GetIntroDialog('help') .
		GetPageFooter('help')
	;

	if (GetConfig('setting/admin/js/enable')) {
		$txtIndex = InjectJs($txtIndex, qw(settings avatar profile timestamp pingback utils clock));
	}

	return $txtIndex;
} # GetHelpPage()

1;
