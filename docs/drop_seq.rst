Drop-seq pipeline
-------------------------------------------------------------

Follow the steps below to extract gene-count matrices from Drop-seq data.
This WDL follows the steps outlined in the `Drop-seq alignment cookbook`_ from the `McCarroll lab`_ while additionally
providing the option to generate count matrices using  `dropEst`_. Please note that run cost has not yet been optimized for dropEst and so runs using dropEst might be expensive.

#. Copy your sequencing output to your workspace bucket using gsutil in your unix terminal. You can obtain your bucket URL in the workspace summary tab in FireCloud under Google Bucket. You can also read `FireCloud instructions`_ on uploading data.

	Example of copying the directory at /foo/bar/nextseq/Data/VK18WBC6Z4 to a Google Cloud bucket::

		gsutil -m cp -r /foo/bar/Data/dropseq gs://fc-e0000000-0000-0000-0000-000000000000/dropseq

	``-m`` means copy in parallel, ``-r`` means copy the directory recursively.

	Note: Broad users need to be on an UGER node (not a login node) in order to use the ``-m`` flag

	Request an UGER server::

		reuse UGER
		qrsh -q interactive -l h_vmem=4g -pe smp 8 -binding linear:8 -P regevlab

	The above command requests an interactive shell with 4G memory per thread and 8 threads. Feel free to change the memory, thread, and project parameters.

	Once you've connected to an UGER node run::
		reuse Google-Cloud-SDK

	to make the Google Cloud tools available


#. Create a `sample sheet`_.

	Please note that the columns in the CSV must be in the order shown below and does not contain a header line.
	The sample sheet provides either the FASTQ files for each sample if you've already run bcl2fastq or a list of BCL directories if you're starting from BCL directories.
	Please note that BCL directories must contain a valid bcl2fastq sample sheet (SampleSheet.csv):


	.. list-table::
		:widths: 5 30
		:header-rows: 1

		* - Column
		  - Description
		* - Name
		  - Sample name.
		* - Read1
		  - Location of the FASTQ file for read1 in the cloud (gsurl).
		* - Read2
		  - Location of the FASTQ file for read2 in the cloud (gsurl).

	Example::


		sample-1,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-1/sample1-1_L001_R1_001.fastq.gz,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-1/sample-1_L001_R2_001.fastq.gz
		sample-2,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-1/sample-2_L001_R1_001.fastq.gz,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-1/sample-2_L001_R2_001.fastq.gz
		sample-1,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-2/sample1-1_L001_R1_001.fastq.gz,gs://fc-e0000000-0000-0000-0000-000000000000/dropseq-2/sample-1_L001_R2_001.fastq.gz


	Note that in this example, sample-1 was sequenced across two flowcells.

#. Upload your sample sheet to the workspace bucket.

	Example::

		gsutil cp /foo/bar/projects/sample_sheet.csv gs://fc-e0000000-0000-0000-0000-000000000000/


#. Import dropseq_workflow method.

	In FireCloud, select the ``Method Configurations`` tab then click ``Import Configuration``. Click ``Import From Method Repository``. Type **scCloud/dropseq_workflow**.

#. Uncheck ``Configure inputs/outputs using the Workspace Data Model``.


---------------------------------

Inputs:
^^^^^^^

Please see the description of important inputs below.

.. list-table::
	:widths: 5 30
	:header-rows: 1

	* - Name
	  - Description
	* - input_csv_file
	  - CSV file containing sample name, read1, and read2 or a list of BCL directories, `sample sheet`_.
	* - output_directory
	  - Pipeline output directory (gs URL e.g. "gs://fc-e0000000-0000-0000-0000-000000000000/dropseq_output")
	* - reference
	  - hg19, mm10, hg19_mm10, mmul_8.0.1 or a path to a custom reference JSON file
	* - run_bcl2fastq
	  - Whether your sample sheet contains one BCL directory per line or one sample per line
 	* - run_dropseq_tools
	  - Whether to generate count matrixes using Drop-Seq tools from the `McCarroll lab`_.
	* - run_dropest
	  - Whether to generate count matrixes using `dropEst`_.
	* - cellular_barcode_whitelist
	  - Optional whitelist of known cellular barcodes
	* - drop_seq_tools_force_cells
	  - If supplied, bypass the cell detection algorithm and use this number of cells
	* - dropest_cells_max
	  - Maximal number of output cells
	* - dropest_genes_min
	  - Minimal number of genes in output cells
	* - dropest_apply_directional_umi_correction
	  - Apply 'directional' correction of UMI errors
	* - dropest_merge_barcodes_precise
	  - Use precise merge strategy (can be slow), recommended to use when the list of real barcodes is not available
	* - trim_sequence
      - The sequence to look for at the start of reads for trimming (default "AAGCAGTGGTATCAACGCAGAGTGAATGGG")
	* - trim_num_bases
      - How many bases at the begining of the sequence must match before trimming occur (default 5)
	* - umi_base_range
	  - the base location of the molecular barcode (default 13-20)
	* - cellular_barcode_base_range
      - the base location of the cell barcode (default 1-12)
	* - workflow_version
	  - The workflow version to use (default  "2.2.0").

Please note that run_bcl2fastq must be set to true if you're starting from BCL files instead of FASTQs.

Custom Genome JSON
===================

If you're reference is not one of the predefined choices, you can create a custom JSON file. Example::

	{
		"refflat":    "gs://fc-e0000000-0000-0000-0000-000000000000/human_mouse/hg19_mm10_transgenes.refFlat",
		"genome_fasta":    "gs://fc-e0000000-0000-0000-0000-000000000000/human_mouse/hg19_mm10_transgenes.fasta",
		"star_genome":    "gs://fc-e0000000-0000-0000-0000-000000000000/human_mouse/STAR2_5_index_hg19_mm10.tar.gz",
		"gene_intervals":    "gs://fc-e0000000-0000-0000-0000-000000000000/human_mouse/hg19_mm10_transgenes.genes.intervals",
		"genome_dict":    "gs://fc-e0000000-0000-0000-0000-000000000000/human_mouse/hg19_mm10_transgenes.dict",
		"star_cpus": 32,
		"star_memory": "120G"
	}

The fields star_cpus and star_memory are optional and are used as the default cpus and memory for running STAR with your genome.


Outputs:
^^^^^^^^

The pipeline outputs a list of google bucket urls containing one gene-count matrix per sample. Each gene-count matrix file produced by Drop-seq tools has the suffix 'dge.txt.gz', matrices produced by dropEst have the extension .rds.

.. _FireCloud instructions: https://software.broadinstitute.org/firecloud/documentation/article?id=10574
.. _Drop-seq alignment cookbook: https://github.com/broadinstitute/Drop-seq/blob/master/doc/Drop-seq_Alignment_Cookbook.pdf
.. _McCarroll lab: http://mccarrolllab.org/dropseq-1/
.. _dropEst: https://github.com/hms-dbmi/dropEst
.. _sample sheet:



