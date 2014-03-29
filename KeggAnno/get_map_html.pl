#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;

if(scalar(@ARGV) < 3){
	print STDERR "\nGet map information of a kaas job\n";
	print STDERR "Author: zhoujj2013\@gmail.com\n";
	print STDERR "\nperl $0 <jobid> <prefix> <outputdir>\n\n";
	exit(1)
}

my ($jobid, $p, $out) = @ARGV;

&get_map_html($jobid, $p, $out);

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
