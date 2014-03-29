#!/usr/bin/perl -w

use strict;

my $f = shift;

print "# Lyc genome KEGG annotation report\n\n";
print "Created by bsgenomics\@163.com\n\n";
print "-------\n\n";
print "## Methold\n";
print "1. 我们用自主开发的程序（[依据kaas注释系统的方法](http://www.genome.jp/kegg/kaas/)），对[kegg](http://www.kegg.jp/)数据库上的序列进行分析，以真核生物为参考列表进行大黄鱼基因组注释，得到大黄鱼与其余模式真核生物的直系同源基因。\n\n";
print "   > 具体参数如下：双向比对的方法 way=b, blast score cutoff=6, 参考物种列表：hsa, mmu, rno, dre, dme, cel, ath, sce, ago, cal, spo, ecu, pfa, cho, ehi, eco, nme, hpy, bsu, lla, mge, mtu, syn, aae, mja, ape\n\n";
print "2. 根据所得到的直系同源基因及kegg pathway数据库，把大黄鱼的基因注释到不同的代谢通路。\n\n";
print "3. 根据kegg注释的结果，我们可以了解大黄鱼在特定的代谢通路中，与其它物种相对，是否有特别之处\n\n";
print "## Result\n\n";
print "1. 大黄鱼基因组中有4671个基因(比起以前的基因组，这个数据偏少)，共关联到331个代谢及调控通路。\n\n";
print "2. 大黄鱼基因与pathway的对应关系。\n\n";
print "   > [lyc.gene2map.xls](./lyc.gene2map.xls)\n\n";
print "3. 所注释的pathway对应的大黄鱼基因id。\n\n";
print "   > [lyc.map2gene.xls](./lyc.map2gene.xls)\n\n";
print "## 附录：\n\n";

open IN,"$f" || die $!;
my $header = <IN>;
$header = chomp($header);
my @header = split /\t/,$header;
while(<IN>){
	chomp;
	my @t = split /\t/;
	print "### [$t[0] $t[1]]($t[2])\n\n";
	my @g = split /;/,$t[3];
	foreach my $gg (@g){
		print "$gg\n\n";
	}
}
close IN;

