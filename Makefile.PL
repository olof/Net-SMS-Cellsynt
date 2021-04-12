#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

my $vcs = 'https://github.com/olof/Net-SMS-Cellsynt';

WriteMakefile (
	NAME => 'Net::SMS::Cellsynt',
	AUTHOR => 'Olof Johansson <zibri@cpan.org>',
	LICENSE => 'perl',
	ABSTRACT_FROM => 'lib/Net/SMS/Cellsynt.pm',
	VERSION_FROM => 'lib/Net/SMS/Cellsynt.pm',

	PREREQ_PM => {
		'WWW::Curl::Easy' => 4.14,
		'URI' => 0,
		'URI::QueryParam' => 0,
		'URI::Escape' => 0,
	},

	SIGN => 1,

	META_MERGE => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url => "$vcs.git",
				web => "$vcs",
			},
			bugtracker  => {
				web    => "$vcs/issues",
			},
		},
	},
);
