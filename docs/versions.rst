Latest and stable versions on FireCloud
---------------------------------------

scCloud is a fast growing project. As a result, we frequently update WDL snapshot versions on FireCloud. See below for latest and stable WDL versions you can use.

Latest version
^^^^^^^^^^^^^^

.. list-table::
	:widths: 15 5 30
	:header-rows: 1

	* - WDL
	  - Snapshot
	  - Function
	* - scCloud/cellranger_workflow
	  - 4
	  - Run Cell Ranger tools, which include extracting sequence reads using cellranger mkfastq or cellranger-atac mkfastq, generate count matrix using cellranger count or cellranger-atac count, run cellranger vdj or feature-barcode extraction
	* - scCloud/smartseq2
	  - 6
	  - Run Bowtie2 and RSEM to generate gene-count matrices for SMART-Seq2 data from FASTQ files
	* - scCloud/scCloud
	  - 16
	  - Run scCloud analysis module for variable gene selection, batch correction, PCA, diffusion map, clustering and more
	* - scCloud/scCloud_subcluster
	  - 11
	  - Run subcluster analysis using scCloud
	* - scCloud/scCloud_hashing_cite_seq
	  - 11
	  - Run scCloud for cell-hashing/nucleus-hashing/CITE-Seq analysis

Stable version - HTAPP v2
^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
	:widths: 15 5 30
	:header-rows: 1

	* - WDL
	  - Snapshot
	  - Function
	* - regev/cellranger_mkfastq_count
	  - 45
	  - Run Cell Ranger to extract FASTQ files and generate gene-count matrices for 10x genomics data
	* - scCloud/smartseq2
	  - 5
	  - Run Bowtie2 and RSEM to generate gene-count matrices for SMART-Seq2 data from FASTQ files
	* - scCloud/scCloud
	  - 14
	  - Run scCloud analysis module for variable gene selection, batch correction, PCA, diffusion map, clustering and more
	* - scCloud/scCloud_subcluster
	  - 9
	  - Run subcluster analysis using scCloud
	* - scCloud/scCloud_hashing_cite_seq
	  - 9
	  - Run scCloud for cell-hashing/nucleus-hashing/CITE-Seq analysis

Stable version - HTAPP v1
^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
	:widths: 15 5 30
	:header-rows: 1

	* - WDL
	  - Snapshot
	  - Function
	* - regev/cellranger_mkfastq_count
	  - 39
	  - Run Cell Ranger to extract FASTQ files and generate gene-count matrices for 10x genomics data
	* - scCloud/scCloud
	  - 3
	  - Run scCloud analysis module for variable gene selection, batch correction, PCA, diffusion map, clustering and more
