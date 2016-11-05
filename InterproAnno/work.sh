perl iprscan5_soaplite.pl --paramDetail appl > appl.txt

perl iprscan5_soaplite.pl  ../KeggAnno/example/spe1.fa --email zhoujj2013@gmail.com --goterms --pathways --multifasta > std.log 2> err.log &

perl iprscan5_soaplite.pl  ../KeggAnno/example/spe1.fa --email zhoujj2013@gmail.com --outformat tab --outfile test.iprscan --goterms --pathways --multifasta > std.log 2> err.log &


perl iprscan5_soappy.py ../KeggAnno/example/spe1.fa --email=zhoujj2013@gmail.com --outformat=tsv --outfile=test.tsv --goterms --pathways >std.log2 2>err.log2 &

perl iprscan5_soaplite.pl ../KeggAnno/example/spe1.fa --email zhoujj2013@gmail.com --outformat tsv --useSeqId --goterms --pathways --multifasta > std.log 2> err.log &

perl runIprscan.pl ../KeggAnno/example/spe1.fa
