#!/usr/bin/perl -w

use strict;
use Data::Dumper;

if(scalar(@ARGV) < 3){
	print STDERR "\nExtract information of map html file\n";
	print STDERR "Author: zhoujj2013\@gmail.com\n";
	print STDERR "\nperl $0 <maphtml> <*_query.ko> <out prefix>\n\n";
	exit(1)
}

my ($maphtml, $ko, $prefix) = @ARGV;

# read query K ortholog gene annotaiton by kaas
my @ko;
my %k2gene;
open IN,"$ko" || die $!;
while(<IN>){
	chomp;
	my @t = split /\s+/;
	next if(scalar(@t) < 2);
	push @{$k2gene{$t[1]}},$t[0];
	push @ko,\@t;
}
close IN;
# create k to gene file
open OUT,">","./$prefix.k2gene.txt" || die $!;
foreach my $k (keys %k2gene){
	print OUT "$k\t";
	print OUT scalar(rm_dup($k2gene{$k}));
	print OUT "\t";
	print OUT join "\t",rm_dup($k2gene{$k});
	print OUT "\n";
}
close OUT;

my %g2map;
my %map2g;

open OUT,">","./$prefix.map2gene.txt" || die $!;
open IN,"$maphtml" || die $!;
while(<IN>){
	chomp;
	next unless(/http:\/\/www\.kegg\.jp\/kegg-bin\/show_pathway/g);
	#<p class='trd'><a href='http://www.kegg.jp/kegg-bin/show_pathway?@ko01200/reference%3dwhite/default%3d%23bfffbf/K00844/K12407/K08074/K01810/K00850/K01623/K01803/K00134/K00927/K01834/K01689/K00873/K00161/K00162/K00627/K00382/K00027/K00029/K13937/K00036/K01057/K00033/K01783/K01807/K00615/K00616/K00948/K01053/K01647/K01681/K00031/K00030/K00164/K00658/K01899/K01900/K00234/K00235/K00236/K00237/K00025/K03841/K14454/K14455/K00814/K01958/K01960/K01965/K01966/K05606/K01847/K00626/K00297/K00121/K01070/K01895/K00863/K00600/K00830/K00058/K00831/K01079/K01754/K17989/K00281/K00283/K00605/K01948/K00249/K07511/K07514/K07515/K05605/K00140/K00248' target='new'>01200</a> Carbon metabolism (75)</p>
	# change to red object
	my $pstr = $_;
	$pstr =~ s/%23bfffbf/red/g;

	# get link address
	my ($link, $mapnum, $shortexplain) = ($pstr =~ /<a href='([^']+)'.*>(\d+)<\/a>\s([^<]+)<\/p>/);
	my @karr = ($pstr =~ /(K\d+)/g);
	my $mapid = "map$mapnum";
	
	# prepare map2gene
	my @g;
	my @kostr;
	foreach my $k (@karr){
		if(exists $k2gene{$k}){
			push @g,@{$k2gene{$k}};
			push @kostr,"$k#".join ",",@{$k2gene{$k}};
		}
	}

	# store gene2map
	foreach my $gg (@g){
		push @{$g2map{$gg}},$mapid;
	}
	
	print OUT "$mapid\t";
	print OUT scalar(rm_dup(\@g));
	print OUT "\t";
	print OUT scalar(@kostr);
	print OUT "\t";
	print OUT "$shortexplain\t";
	print OUT "$link\t";
	print OUT join "\t",@kostr;
	print OUT "\n";
}
close IN;
close OUT;


open OUT,">","./$prefix.gene2map.txt" || die $!;
foreach my $g (keys %g2map){
	print OUT "$g\t";
	print OUT join "\t",@{$g2map{$g}};
	print OUT "\n";
}
close OUT;

sub rm_dup{
	my ($arr) = @_;
	my %arr;
	foreach my $a (@$arr){
		$arr{$a} = 1;
	}
	return keys %arr;
}


