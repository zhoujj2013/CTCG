#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use Data::Dumper;
use Getopt::Long;
use File::Basename qw(basename dirname);

sub usage{
    my $usage = << "USAGE";
    Get annotation by kaas system!
    Author: zhoujiajian\@genomics.cn
    perl $0 [options] protein.fa
    --prefix    prefix for the job
    --email     email address [force]
    --outdir    out directory
    --dbmode    manual
    --org_list  GENES data set, like "hsa, dme, cel, ath"
    --way       Assignment method SBH="s", BBH="b"
    --help      print this information
USAGE
print "$usage";
exit(1);
}

my ($input_fa,$email,$prefix,$outdir,$dbmode,$org_list,$way,$help);
GetOptions(
    "prefix:s"=>\$prefix,
    "email:s"=>\$email,
    "outdir:s"=>\$outdir,
    "dbmode:s"=>\$dbmode,
    "org_list:s"=>\$org_list,
    "way:s"=>\$way,
    "help"=>\$help
);

&usage if (@ARGV == 0 || $help || !$email);
$input_fa = shift;
$prefix ||= "kaas";
$outdir ||= "./";
$dbmode ||= "manual";
$org_list ||= "eco, dme";
#$org_list ||= "hsa, dme, cel, ath, sce, cho, eco, nme, hpy, rpr, bsu, lla, cac, mge, mtu, ctr, bbu, syn, bth, dra, aae, mja, ape";
#for eukaryotes
# hsa, mmu, rno, dre, dme, cel, ath, sce, ago, cal, spo, ecu, pfa, cho, ehi, eco, nme, hpy, bsu, lla, mge, mtu, syn, aae, mja, ape
$way ||= "s";

my $req = POST(
   "http://www.genome.jp/kaas-bin/kaas_main",
   content_type => "multipart/form-data",
   content => {
       uptype => "q_file",
       file => ["$input_fa"],
       qname => "$prefix",
       mail => "$email",
       dbmode => "$dbmode",
       org_list => "$org_list",    # GENES data set
       way => "$way",                # Assignment method SBH="s", BBH="b"
       mode => "compute",
   }
   );

my $ua = LWP::UserAgent -> new;
my $response = $ua -> request($req);
my $job_id;
my $accept = 0;
if($response->is_success){
    #print $response->content;
    $job_id = $1 if($response->content =~ /job ID: (\d+)<\/p>/s);
    $accept = 1 if($response->content =~ /Accepted<\/p>/s);
}else{
    print STDERR $response->status_line."\n";
    exit(1);
}

#print Dumper($ua);
if($accept == 1){
    print STDERR "Your kaas job ID: $job_id","\n";
}else{
    print STDERR "Your kaas job is failed.\nBecause each user is allowed to compute one query at the same time.\nopen this link below and check again:\nhttp://www.genome.jp/kaas-bin/kaas_main?mode=user&mail=$email\n";
    exit(1);
}

my $i = 0;
while(1){
    my $stat = get_queryko($job_id, $prefix, $outdir);
	my $stat2 = get_map_html($job_id, $prefix, $outdir);
	
    if($stat == 0 && $stat2 == 0){
		&get_K_anno("$outdir/$prefix\_query.ko", $prefix, $outdir);
        print "all jobs are done! Check result:\n";
        print "$outdir/$prefix\_query.ko";
        last;
    }elsif($stat > 0 || $stat2 > 0){
        print STDERR "round $i .....\n";
        sleep 30;
    }
    $i++;
}

sub get_K_anno{
	my ($q_ko_f, $prefix, $outdir) = @_;
	my $q_ko_f_b = basename($q_ko_f);
	
	`cp $q_ko_f $outdir/$q_ko_f_b.bk`;
	
	open IN,"$outdir/$q_ko_f_b.bk" || die $!;
	open OUT,">","$outdir/$prefix\_query.ko" || die $!;
	my $browser = LWP::UserAgent->new();
	while(<IN>){
		chomp;
		my @t = split /\t/;
		if(scalar(@t) > 1){
			my $url = "http://rest.kegg.jp/find/ko/$t[1]";
			my $response = $browser->get($url);
			my $kanno = "NULL";
			if($response->content eq ""){
				print OUT "$t[0]\t$t[1]\t$kanno\n";
			}else{
				my @anno = split /\t/,$response->content;
				$kanno = $anno[1];
				print OUT "$t[0]\t$t[1]\t$kanno";
			}
		}else{
			print OUT "$t[0]\n";
		}
	}
	close IN;
	close OUT;
}

sub get_queryko{

    my ($job_id,$prefix,$outdir) = @_;

    my $browser = LWP::UserAgent->new();
    my $url = "http://www.genome.jp/tools/kaas/files/dl/$job_id/query.ko";
    my $response = $browser->get($url);
    my $status = 0;
    
    if($response->is_success){
        open OUT,">","$outdir/$prefix\_query.ko" || die "$!";
        print OUT $response->content;
        close OUT;
        $status = 0;
    }else{
        $status++;
    }
    return $status;
}

 
sub get_map_html{
	
    my ($job_id,$prefix,$outdir) = @_;

    my $browser = LWP::UserAgent->new();
    my $url = "http://www.genome.jp/kaas-bin/kaas_main?mode=map&id=$job_id";
    my $response = $browser->get($url);
    my $status = 0;
    
    if($response->is_success){
        open OUT,">","$outdir/$prefix\_map.html" || die "$!";
        print OUT $response->content;
        close OUT;
        $status = 0;
    }else{
        $status++;
    }
    return $status;
}
