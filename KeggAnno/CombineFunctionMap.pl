#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);
use Data::Dumper;
use lib "/home/zhoujj/my_lib/pm";
use bioinfo;

&usage if @ARGV<1;

#open IN,"" ||die "Can't open the file:$\n";
#open OUT,"" ||die "Can't open the file:$\n";

sub usage {
        my $usage = << "USAGE";

        This script combine all function annotation to a table for statistics.
        Author: zhoujj2013\@gmail.com
        Usage: $0 <gene_lst> <function_annotation_results> > <statistics_result>
        Example:perl $0 geneID.lst GO.lst ipr.lst kegg.best Swissprot.best Trembl.best >function_annotation_stat.txt

USAGE
print "$usage";
exit(1);
};

my %e;
my @s;

# prepare the hash
foreach my $fstr (@ARGV){
	my ($f, $prefix) = split /:/,$fstr;
	push @s,$prefix;
	open IN,"$f" || die $!;
	while(<IN>){
		chomp;
		my @t = split /\t/;
		$e{$t[0]}{'gnum'} = ();
		$e{$t[0]}{'desc'} = $1 if($t[3] =~ /([^\(]+) \(/);
	}
	close IN;
}

# initial the hash
foreach my $k (keys %e){
	foreach(@s){
		push @{$e{$k}{'gnum'}},0;
	}
}

# read in the file again
my $i = 0;
foreach my $fstr (@ARGV){
	my ($f, $prefix) = split /:/,$fstr;
	open IN,"$f" || die $!;
    while(<IN>){
        chomp;
        my @t = split /\t/;
		$e{$t[0]}{'gnum'}[$i]  = $t[1] if(exists $e{$t[0]});
    }
    close IN;
	$i++;
}

#print Dumper(\%e);

# write to the file
print "#Mapid\tdesc\t";
print join "\t",@s;
print "\n";
foreach my $k (keys %e){
	print "$k\t$e{$k}{'desc'}\t";
	print join "\t",@{$e{$k}{'gnum'}};
	print "\n";
}

