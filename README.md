# 1secmail
Module to generating temporary emails

```
#!/usr/bin/perl

use warnings;
use strict;

use Secmail;

sub main
{
	my $mail;
	my $messages;
	my $body;

	$mail = Secmail->new();

	# Set proxy every request
	# Support only HTTP proxy
	# Default is disable
	$mail->proxy('host', port);

	# Define your useragent to request
	# Default is Mozilla/5.0
	$mail->ua('Mozilla/5.0');

	# Return hash reference to json array with messages
	# Return undef if error
	# Check avialiable domain on https://www.1secmail.com
	$messages = $mail->checkemail('any@1secmail.com');

	if ($messages->[0]->{id})
	{
		# Return body message
		$body = $mail->bodymessage('any@1secmail.com', $messages->[0]->{id});
		print $body;
	}

	return 0;
}

main();
```