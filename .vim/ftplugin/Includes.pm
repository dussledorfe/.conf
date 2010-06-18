package Includes;

use 5.006;
use warnings;
use strict;

our $VERSION = '0.07';

use Fcntl qw(:flock :seek);
use Dir::Self;

use constant {
	MAN => '/usr/bin/man',
	PAGER => '/bin/cat',
	TBLPATH => __DIR__ . '/c_includes.txt',
};

our $Cache_updated;
our %Cache;

sub _fill_cache {
	my $fh = shift;
	local $/ = "\n";
	while (defined (my $s = <$fh>)) {
		while ($s =~ s/\\\n\z//) {
			$s .= <$fh>;
		}
		next if $s =~ /^\s*#/;
		chomp $s;
		my @pieces = $s =~ /(?:[^\\\s]|\\.)+/sg;
		s/\\(.)/$1/sg for @pieces;
		my $id = shift @pieces;
		next unless @pieces;
		my @entry = [];
		my $i = 0;
		for (@pieces) {
			if ($_ eq '|') {
				push @entry, [];
			} else {
				push @{$entry[-1]}, $_;
			}
		}
		next unless @{$entry[0]};
		$Cache{$id} = \@entry;
	}
}

sub fill_cache {
	open my $fh, '<', TBLPATH or VIM::Msg("Can't open ${\TBLPATH}: $!", 'ErrorMsg'), return;
	unless (flock $fh, LOCK_SH | LOCK_NB) {
		VIM::Msg("${\TBLPATH}: Waiting for lock...", 'Comment');
		flock $fh, LOCK_SH or VIM::Msg("Can't lock ${\TBLPATH}: $!", 'ErrorMsg'), return;
	}
	_fill_cache($fh);
}

sub _escape {
	my $s = shift;
	$s =~ s/([\s|\\])/\\$1/g;
	$s
}

sub flush_cache {
	my $force = shift;
	return unless $Cache_updated or $force;
	open my $fh, '+>>', TBLPATH or VIM::Msg("Can't open ${\TBLPATH}: $!", 'ErrorMsg'), return;
	unless (flock $fh, LOCK_EX | LOCK_NB) {
		VIM::Msg("${\TBLPATH}: Waiting for lock...", 'Comment');
		flock $fh, LOCK_EX or VIM::Msg("Can't lock ${\TBLPATH}: $!", 'ErrorMsg'), return;
	}
	seek $fh, 0, SEEK_SET;
	_fill_cache($fh);
	truncate $fh, 0 or VIM::Msg("Can't truncate ${\TBLPATH}: $!", 'ErrorMsg'), return;
	for my $k (sort keys %Cache) {
		my $v = $Cache{$k};
		printf $fh "%-30s\t%s\n"
		, _escape($k)
		, join ' | ', map join(' ', map _escape($_), @$_), @$v
		;
	}
	close $fh or VIM::Msg("Can't close ${\TBLPATH}: $!", 'ErrorMsg');
	$Cache_updated = 0;
}

sub _cleanup {
	my $s = shift;
	$s =~ s/\e\[[^m]*m//g;
	$s =~ s/.\cH//g;
	$s
}

sub _headerp {
	my ($line, $hdr) = @_;
	chomp $line;
	#use Data::Dumper; $Data::Dumper::Useqq = 1;
	#print STDERR "> ", Dumper($line, $hdr), "\r\n";
	#print STDERR "< ", Dumper($line, $hdr), "\r\n";
	_cleanup($line) eq $hdr
}

sub find {
	my $func = shift;
	return $Cache{$func} if exists $Cache{$func};

	local $ENV{MANSECT} = '3:3p:3c:2';
	open my $fh, "${\MAN} -P${\PAGER} 2>/dev/null \Q$func\E |" or VIM::Msg("Can't run ${\MAN}: $!", 'ErrorMsg'), return;
	local $/ = "\n";
	my $s;
	while ($s = <$fh>) {
		last if _headerp($s, 'SYNOPSIS');
	}
	defined $s or VIM::Msg("Can't find a manpage for $func", 'ErrorMsg'), return;
	my %found;
	while (defined($s = <$fh>) && !_headerp($s, 'DESCRIPTION')) {
		$s = _cleanup $s;
		$found{$1} = undef if $s =~ /^\s*#\s*include\s*(<[^>]+>|"[^"]+")/;
	}
	%found or VIM::Msg("Can't find #includes for $func", 'ErrorMsg'), return;
	$Cache_updated = 1;
	$Cache{$func} = [[keys %found]]
}

1
