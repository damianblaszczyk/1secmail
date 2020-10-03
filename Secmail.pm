package Secmail;

use warnings;
use strict;
use Carp;

use WWW::Mechanize;
use HTML::Entities;
use JSON::MaybeXS;

sub new
{
	my $class = shift( @_ );

	my $self = 
	{
		_url	=> 'https://www.1secmail.com',
		_ua	=> 'Mozilla/5.0',
	};

	bless $self => $class;

	return $self;
}

sub proxy
{
	my $self = shift( @_ );

	$self->{_proxyhost} = $_[0];
	$self->{_proxyport} = $_[1];
}

sub ua
{
	my $self = shift( @_ );

	$self->{_ua} = $_[0];
}

sub checkemail
{
	my $self = shift(@_);

	my $json;

	$self->{_browser} = WWW::Mechanize->new
	(
		agent => $self->{_ua},
		ssl_opts => 
		{
			verify_hostname => 0,
			SSL_verify_mode => 0,
		},
		timeout => 15,
	);

	$self->{_browser}->proxy
	( 
		['http','https'],"http://" 
		. $self->{_proxyhost} . ":" 
		. $self->{_proxyport} . "/" 
	) if ($self->{_proxyhost} && $self->{_proxyport});

	$self->{_browser}->get
	(
		$self->{_url} . "/api/v1/?action=getMessages&login=" . 
		(split(/@/,$_[0]))[0] . "&domain=" . (split(/@/,$_[0]))[1] 
	);

	if ($self->{_browser}->success)
	{
		if ($self->{_browser}->response()->decoded_content())
		{
			print $self->{_browser}->response()->decoded_content;
			return decode_json($self->{_browser}->response()->decoded_content);
		}
		else
		{
			die "Decoding content problem";
		}
	}
	else
	{
		die "Request message problem";
	}
	return undef;
}

sub bodymessage
{
	my $self = shift( @_ );

	$self->{_browser}->get
	( 
		$self->{_url} . "/mailbox/?action=mailBody&id=" . $_[1] . 
		"&login=" . (split(/@/,$_[0]))[0] . "&domain=" . (split(/@/,$_[0]))[1]
	);	

	if ($self->{_browser}->success)
	{
		if ($self->{_browser}->response()->decoded_content())
		{
			return decode_entities($self->{_browser}->response()->decoded_content);
		}
		else
		{
			die "Decoding content problem";
		}
	}
	else
	{
		die "Request message problem";
	}
	return undef;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Secmail - Automatic create temporary e-mail and check it.

https://www.1secmail.com

=head1 VERSION

version 1.00

=head1 SYNOPSIS

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
		$mail->proxy('host', ip);

		# Define your useragent to request
		# Default is Mozilla/5.0
		$mail->ua('Mozilla/5.0');

		# Return hash reference type json array with messages
		# Return undef if error
		# Check avialiable domain on https://www.1secmail.com
		$messages = $mail->checkemail('any@1secmail.com');

		if ($messages->[0]->{id})
		{
			# Return body message
			$body = $mail->bodymessage(EMAIL, MESSAGEID);
			print $body;
		}

		return 0;
	}

	main();

=head1 METHODS

=over 4

=item * proxy(HOST,PORT)

Set proxy every request, support only HTTP proxy, default is disable.

=item * ua(USERAGENT)

Define your useragent to request, default is Mozilla/5.0

=item * checkemail(EMAIL)

Checking email. Return hash reference type json array with messages.
If error return undef value. Check avialiable domain on https://www.1secmail.com.

=item * bodymessage(EMAIL, MESSAGEID)

Return body message.

=back