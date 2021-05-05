version 1.0

workflow cellranger_arc_mkfastq {
	input {
		# Input BCL directory, gs url
		String input_bcl_directory
		# 3 column CSV file (Lane, Sample, Index)
		File input_csv_file

		String output_directory

		# Whether to delete input bcl directory. If false, you should delete this folder yourself so as to not incur storage charges.
		Boolean delete_input_bcl_directory = false
		# Number of allowed mismatches per index
		Int? barcode_mismatches


		String cellranger_arc_version = "1.0.0"
		# Google cloud zones, default to "us-central1-b", which is consistent with CromWell's genomics.default-zones attribute
		String zones = "us-central1-b"
		# Number of cpus per cellranger-arc job
		Int num_cpu = 32
		# Memory string, e.g. 120G
		String memory = "120G"
		# Disk space in GB
		Int disk_space = 1500
		# Number of preemptible tries
		Int preemptible = 2

		String docker_registry = "gcr.io/broad-cumulus"
	}


	call run_cellranger_arc_mkfastq {
		input:
			input_bcl_directory = sub(input_bcl_directory, "/+$", ""),
			input_csv_file = input_csv_file,
			output_directory = sub(output_directory, "/+$", ""),
			delete_input_bcl_directory = delete_input_bcl_directory,
			barcode_mismatches = barcode_mismatches,
			cellranger_arc_version = cellranger_arc_version,
			zones = zones,
			num_cpu = num_cpu,
			memory = memory,
			docker_registry = docker_registry,
			disk_space = disk_space,
			preemptible = preemptible
	}

	output {
		String output_fastqs_directory = run_cellranger_arc_mkfastq.output_fastqs_directory
		String output_fastqs_flowcell_directory = run_cellranger_arc_mkfastq.output_fastqs_flowcell_directory
	}
}

task run_cellranger_arc_mkfastq {
	input {
		String input_bcl_directory
		File input_csv_file
		String output_directory
		Boolean delete_input_bcl_directory
		String cellranger_arc_version
		String zones
		String docker_registry
		Int num_cpu
		String memory
		Int disk_space
		Int preemptible
		Int? barcode_mismatches
	}

	String run_id = basename(input_bcl_directory)


	command {
		set -e

		monitor_script.sh &

		gsutil -q -m cp -r ~{input_bcl_directory} .

		cellranger-arc mkfastq --id=results --run=~{run_id} --csv=~{input_csv_file} --jobmode=local --qc ~{"--barcode-mismatches " + barcode_mismatches}

		python <<CODE
		import os
		import glob
		import pandas as pd
		from subprocess import check_call
		with open("output_fastqs_flowcell_directory.txt", "w") as fout:
			flowcell = [name for name in os.listdir('results/outs/fastq_path') if name != 'Reports' and name != 'Stats' and os.path.isdir('results/outs/fastq_path/' + name)][0]
			fout.write('~{output_directory}/~{run_id}_fastqs/fastq_path/' + flowcell + '\n')
		CODE

		gsutil -q -m rsync -d -r results/outs "~{output_directory}"/~{run_id}_fastqs
		# cp -r results/outs "~{output_directory}"/~{run_id}_fastqs

		python <<CODE
		from subprocess import check_call, check_output, CalledProcessError
		if '~{delete_input_bcl_directory}' is 'true':
			try:
				call_args = ['gsutil', '-q', 'stat', '~{output_directory}/~{run_id}_fastqs/input_samplesheet.csv']
				print(' '.join(call_args))
				check_output(call_args)
				call_args = ['gsutil', '-q', '-m', 'rm', '-r', '~{input_bcl_directory}']
				print(' '.join(call_args))
				check_call(call_args)
				print('~{input_bcl_directory} is deleted!')
			except CalledProcessError:
				print("Failed to delete BCL directory.")
		CODE
	}

	output {
		String output_fastqs_directory = "~{output_directory}/~{run_id}_fastqs"
		String output_fastqs_flowcell_directory = read_lines("output_fastqs_flowcell_directory.txt")[0]
	}

	runtime {
		docker: "~{docker_registry}/cellranger-arc:~{cellranger_arc_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ~{disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}
}
