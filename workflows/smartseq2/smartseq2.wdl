version 1.0


import "https://api.firecloud.org/ga4gh/v1/tools/cumulus:smartseq2_per_plate/versions/6/plain-WDL/descriptor" as ss2pp
#import "smartseq2_per_plate.wdl" as ss2pp

workflow smartseq2 {
	input {
		# 3-4 columns (Cell, Plate, Read1, and optionally Read2). gs URL
		File input_csv_file
		# Output directory, gs URL
		String output_directory
		# Reference to align reads against, GRCm38, GRCh38, or mm10
		String reference
		# Align reads with 'aligner': hisat2-hca, star, bowtie2 (default: hisat2-hca)
		String aligner = "hisat2-hca"

		# Convert transcript BAM file into genome BAM file
		Boolean output_genome_bam = false
		# TPM-normalized counts reflect both the relative expression levels and the cell sequencing depth.
		Boolean normalize_tpm_by_sequencing_depth = true
		# smartseq2 version, default to "1.1.0"
		String smartseq2_version = "1.1.0"
		# Google cloud zones, default to "us-central1-a us-central1-b us-central1-c us-central1-f us-east1-b us-east1-c us-east1-d us-west1-a us-west1-b us-west1-c"
		String zones = "us-central1-a us-central1-b us-central1-c us-central1-f us-east1-b us-east1-c us-east1-d us-west1-a us-west1-b us-west1-c"
		# Number of cpus per job
		Int num_cpu = 4
		# Memory string
		String memory = (if aligner != "star" then "3.60G" else "32G")
		# factor to multiply size of R1 and R2 by for RSEM
		Float disk_space_multiplier = 11
		# Number of preemptible tries 
		Int preemptible = 2
		# Disk space for count matrix generation task
		Int generate_count_matrix_disk_space = 10
		# Which docker registry to use: cumulusprod (default) or quay.io/cumulus
		String docker_registry = "cumulusprod"	
	}

	# Output directory, with trailing slashes stripped
	String output_directory_stripped = sub(output_directory, "/+$", "")

	call parse_input_csv {
		input:
			input_csv_file = input_csv_file,
			output_directory = output_directory_stripped,
			smartseq2_version = smartseq2_version,
			zones = zones,
			preemptible = preemptible,
			docker_registry = docker_registry
	}

	scatter (plate_name in parse_input_csv.plate_names) {
		call ss2pp.smartseq2_per_plate {
			input:
				sample_sheet = parse_input_csv.pn2ss[plate_name],
				plate_name = plate_name,
				output_directory = output_directory_stripped,
				reference = reference,
				aligner = aligner,
				normalize_tpm_by_sequencing_depth = normalize_tpm_by_sequencing_depth,
				output_genome_bam = output_genome_bam,
				smartseq2_version = smartseq2_version,
				zones = zones,
				num_cpu = num_cpu,
				memory = memory,
				disk_space_multiplier = disk_space_multiplier,
				generate_count_matrix_disk_space=generate_count_matrix_disk_space,
				preemptible = preemptible,
				docker_registry = docker_registry
		}
	}

	output {

		Array[Array[File]] rsem_gene = smartseq2_per_plate.rsem_gene
		Array[Array[File]] rsem_isoform = smartseq2_per_plate.rsem_isoform
		Array[Array[File]] rsem_trans_bam = smartseq2_per_plate.rsem_trans_bam
		Array[Array[File]] rsem_time = smartseq2_per_plate.rsem_time
		Array[Array[File]] aligner_log = smartseq2_per_plate.aligner_log
		Array[Array[File]] rsem_cnt =smartseq2_per_plate.rsem_cnt
		Array[Array[File]] rsem_model = smartseq2_per_plate.rsem_model
		Array[Array[File]] rsem_theta = smartseq2_per_plate.rsem_theta
		Array[Array[Array[File]]] rsem_genome_bam = smartseq2_per_plate.rsem_genome_bam

		Array[String] output_count_matrix = smartseq2_per_plate.output_count_matrix
		Array[String] output_qc_report = smartseq2_per_plate.output_qc_report
	}
}

task parse_input_csv {
	input {
		File input_csv_file
		String output_directory
		String smartseq2_version
		String zones
		Int preemptible
		String docker_registry	
	}

	command {
		set -e
		export TMPDIR=/tmp

		python <<CODE
		import pandas as pd 
		from subprocess import check_call

		df = pd.read_csv('~{input_csv_file}', header = 0, dtype=str, index_col = 0)
		with open('plate_names.txt', 'w') as fo1, open('pn2ss.txt', 'w') as fo2:
			for plate_name in df['Plate'].unique():
				plate_df = df.loc[df['Plate'] == plate_name, ]
				if ('Read2' not in plate_df.columns) or (plate_df['Read2'].isna().sum() > 0):
					plate_df = plate_df[['Read1']]
				else:
					plate_df = plate_df[['Read1', 'Read2']]
				plate_df.to_csv(plate_name + '_sample_sheet.csv')
				call_args = ['gsutil', '-q', 'cp', plate_name + '_sample_sheet.csv', '~{output_directory}/']
				# call_args = ['cp', plate_name + '_sample_sheet.csv', '~{output_directory}/']
				print(' '.join(call_args))
				check_call(call_args)
				fo1.write(plate_name + '\n')
				fo2.write(plate_name + '\t~{output_directory}/' + plate_name + '_sample_sheet.csv\n')
		CODE
	}

	output {
		Array[String] plate_names = read_lines('plate_names.txt')
		Map[String, String] pn2ss = read_map('pn2ss.txt')
	}

	runtime {
		docker: "~{docker_registry}/smartseq2:~{smartseq2_version}"
		zones: zones
		preemptible: preemptible
	}
}
