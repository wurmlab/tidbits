../fastaSubset.rb -f a.fasta -s SiJWG07BBD2.scf > 1.fa
../fastaSubset.rb -f a.fasta -s SiJWG07BBD2.scf:878-1 | sed 's/:/_/'> 2.fa
../fastaSubset.rb -f 2.fa -s SiJWG07BBD2.scf_1-878.revcomp:878-1    > 3.fa
sed 's/_.*//' 3.fa > 4.fa
diff -i 1.fa 4.fa
