grep  '>' a.fasta | sed 's/>//' > a.allIdentifiers
../fastaSubset.rb -f a.fasta -s a.allIdentifiers  > a.allIdentifiers.fasta
seqret a.allIdentifiers.fasta a.allIdentifiers.fasta.seqret
seqret a.fasta a.fasta.seqret
diff a.fasta.seqret a.allIdentifiers.fasta.seqret
