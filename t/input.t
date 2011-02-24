#!/usr/bin/perl
use strict;
use Test::More tests => 4;
use Net::SMS::Cellsynt;

my $sms = Net::SMS::Cellsynt->new(
	username=>'username',
	password=>'password',
	origtype=>'alpha',
	orig=>'test',
	simulate=>1,
);

# correct input
is(
	$sms->send_sms(to=>'0046700123456', text=>'hej'),
	"ok: simulation https://se-1.cellsynt.net/sms.php?".
	"username=username&password=password&destination=".
	"0046700123456&text=hej&expiry=&originatortype=alpha&".
	"originator=test"
);

# incorrect telephone number format
is(
	$sms->send_sms(to=>'0700123456', text=>'hej'),
	"Error: Phone number not in expected format"
);

$sms = Net::SMS::Cellsynt->new(
	username=>'zibri',
	password=>'password',
	origtype=>'alpha',
	orig=>'test',
	simulate=>1,
);

# using example script (username zibri)
is(
	$sms->send_sms(to=>'0046700123456', text=>'hej'),
	"Error: Don't run the example script as is"
);

$sms = Net::SMS::Cellsynt->new(
	username=>'username',
	password=>'password',
	origtype=>'alpha',
	orig=>'test',
	uri=>'http://example.org/'
);

is(
	$sms->send_sms(to=>'0046700123456', text=>'hej'),
	"Error: SMS gateway does not follow protocol"
);

