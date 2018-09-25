### Drop-Seq Bundle
#### Create resource files for the Drop-Seq pipeline
Available at https://portal.firecloud.org/#methods/regev/dropseq_bundle/

Drop-Seq bundle requires the following files:

1. reference genome sequence (FASTA file) 
1. gene annotations (GTF file)

#### Single Species 
Input one set of matched FASTA and GTF files typically obtained from Ensembl, NCBI, or UCSC.

#### Multiple Species
This is similar to the single species case, but note that the species order of the FASTA and GTF files must match.
For example:

fasta_file: ["gs://fc-xxx/hg19.fa", "gs://fc-xxx/mm10.fa"]

gtf_file: ["gs://fc-xxx/hg19.gtf", "gs://fc-xxx/mm10.gtf"]

The name of the species list when running the Drop-Seq pipeline corresponds to the fasta file names (e.g.  ["hg19","mm10"])



