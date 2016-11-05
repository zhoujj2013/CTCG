#!/usr/bin/perl -w

use strict;
use FindBin qw($Bin);

`mkdir ./fasta_tmp` unless(-e "./fasta_tmp");
`mkdir ./iprscan_out` unless(-e "./iprscan_out");
open OUT1,">","./iprscan.sh" || die $!;
open IN,"$ARGV[0]" || die $!;
$/ = ">";<IN>;$/="\n";
while(<IN>){
	chomp;
	my $id = $1 if(/(\S+)/);
	$/ = ">";
	my $seq = <IN>;
	chomp($seq);
	$/ = "\n";
	open OUT,">","./fasta_tmp/$id.fa" || die $!;
	print OUT ">$id\n";
	print OUT "$seq\n";
	close OUT;
	print OUT1 "perl $Bin/iprscan5_soaplite.pl ./fasta_tmp/$id.fa --email=zhoujj2013\@gmail.com --outformat=tsv --outfile=./iprscan_out/$id --goterms --pathways >>std.log 2>>err.log\n";
	#sleep(10);
}
close IN;
close OUT1;

`perl $Bin/multi-process.pl -cpu 8 ./iprscan.sh`;

