#!/usr/bin/perl
# cellsynt-sms: Send SMS from the command line
# Simple example script for Net::SMS::Cellsynt
#
# This example uses hard coded authentication information.
#
# Copyright 2010, Olof Johansson <zibri@cpan.org>
#
# This program is free software; you can redistribute it and/or 
# modify it under the same terms as Perl itself. 

use strict;
use warnings;
use Net::SMS::Cellsynt;

if($#ARGV != 1) {
	print STDERR "Usage: ./example.pl <number> <message>\n\n";
	print STDERR "Number is of the format \n\t";
	print STDERR "00 <country code> <national number w/o leading zero>\n\n";
	print STDERR "Example: 0700123456 (swedish number) -> 0046700123456\n";
	exit(1);
}

my $sms = Net::SMS::Cellsynt->new(
	username=>'zibri',
	password=>'foobar',
	origtype=>'alpha',
	orig=>'zibri',
);

my $ret = $sms->send_sms(
	to=>$ARGV[0],
	text=>$ARGV[1],
);

print STDERR "$ret\n" if($ret=~/^Error:/);
print STDERR "ok\n" if($ret=~/^ok:/);

