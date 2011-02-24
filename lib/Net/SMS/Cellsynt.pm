#!/usr/bin/perl
# Copyright 2009-2010, Olof Johansson <zibri@cpan.org>
# 
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself.

package Net::SMS::Cellsynt;
our $VERSION = 0.2;
use strict;
use warnings;
use WWW::Curl::Easy;
use URI::Escape;
use Carp;

=pod

=head1 NAME

Net::SMS::Cellsynt - Send SMS through Cellsynt SMS gateway

=head1 SYNOPSIS

 use Net::SMS::Cellsynt;
 
 $sms = Net::SMS::Cellsynt->new(
        origtype=>'alpha',
        orig=>'zibri',
 	username=>'foo',
	password=>'bar',
 );

 $sms->send_sms(
   to=>$recipient,
   text=>'this text is being sent to you bu Net::SMS::Cellsynt',
 );

=head1 DESCRIPTION

Net::SMS::Cellsynt provides a perl object oriented interface to the
Cellsynt SMS HTTP API, which allows you to send SMS from within your
script or application. 

To use this module you must have a Cellsynt account.

=head1 CONSTRUCTOR

=head2 new( parameters )
 
=head3 MANDATORY PARAMETERS

=over 8

=item username => $username
	
Your Cellsynt username.

=item password => $password

Your Cellsynt password.

=item origtype => $origtype

Type of originator. This can be either "alpha", where you supply a 
string in orig parameter that the recpient will see as sender (note 
that the recipient cannot answer this types of SMS); numeric, where
you supply a telephone number in the orig parameter and shortcode
where you supply a numerical short code for a operator network.

=item orig => $orig

This is the "sender" the recpient sees when recieving the SMS. 
Depending on the value of origtype this should be a string, a 
telephone number or a numerical shortcode. (See origtype)

=back

=head3 OPTIONAL PARAMETERS

=over 8

=item ttl

This value determines how long the SMS can be tried to be delivered,
in seconds. If this value is above the operator's max value, the
operator's value is used. Default is not set.

=item concat

Setting this to a value above 1 will allow for longer SMS:es to be
sent. One SMS can use 153 bytes, and with this you can send up to 
6 SMS:es (918 bytes).

=item simulate

If set to a value other than 0, the module will output the URI that 
would be used if this wasn't a simulation, and return, when callng 
the B<send_sms> subroutine. Default is 0.

=item uri

Set an alternative URI to a service implementing the Cellsynt API.
Default is "https://se-1.cellsynt.net/sms.php".

=back

=cut

sub new {
	my $class = shift;
	my $self = {
		uri => 'https://se-1.cellsynt.net/sms.php',
		simulate => 0,
		@_,
	};
	$self->{curl} = new WWW::Curl::Easy;

	bless $self, $class;
	return $self;
}

=head1 METHODS

=head2 send_sms(to=>$recipient, $text=>"msg")

Will send message "msg" as an SMS to $recipient, unless the object has 
set the simulate object; then the send_msg will output the URI that 
would be used to send the SMS.

$recipient is a telephone number in international format: The Swedish
telephonenumber 0700123456 will translate into 0046700123456 --- it is 
the caller's responsibility to convert numbers into this format before
calling send_sms.

Will return a tracking ID if successfull (or 1 if simulating), or undef
if an error occurs, and also write the error message to stderr.

=cut

sub send_sms {
	my $self = shift;
	my $param = {
		@_,
	};

	my $username = $self->{username};
	my $password = $self->{password};
	my $origtype = $self->{origtype};
	my $orig = $self->{orig};
	my $uri = $self->{uri};
	my $text = uri_escape($param->{text});

	my $ttl='&expiry=';
	$ttl .= $self->{ttl}+time if(exists $self->{ttl});

	if(not $param->{to} =~ /^00/) {
		return "Error: Phone number not in expected format";
	}

	my $req = "$uri?username=$username&password=$password".
	          "&destination=".$param->{to}."&text=$text".
		  "$ttl&originatortype=$origtype&originator=$orig";
	if(exists $self->{concat}) {
		$req .= '&allowconcat='.$self->{concat};
	}

	# this username is used in the example script.
	if($username eq 'zibri') {
		return "Error: Don't run the example script as is";
	}

	if($self->{simulate}) {
		return "ok: simulation $req";
	}

	my $body;

	my $curl = new WWW::Curl::Easy;
	open(my $curld, ">", \$body);
	$curl->setopt(CURLOPT_URL, $req);
	$curl->setopt(CURLOPT_WRITEDATA, \$curld);
	$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
	$curl->perform();
	close $curld;

	if($body=~/^OK: (.*)/) {
		return "ok: $1";
	} elsif($body=~/^Error: (.*)/) {
		return "Error: $1\n";
	} else {
		return "Error: SMS gateway does not follow protocol";
	}
}

=head2 sender(origtype=>$origtype, orig=>$orig)

Update sender. See constructor documentation for valid values.

=cut

sub sender {
	my $self = shift;
	my $param = {
		@_,
	};

	$self->{origtype} = $param->{origtype};
	$self->{orig} = $param->{orig};
}

1;

=head1 SEE ALSO

http://cellsynt.com/

=head1 COPYRIGHT

Copyright (c) 2009-2010,  Olof 'zibri' Johansson <zibri@cpan.org>
All rights reserved.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut

