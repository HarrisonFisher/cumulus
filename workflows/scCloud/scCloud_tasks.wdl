workflow scCloud_tasks {
}

task run_scCloud_aggregate_matrices {
	File input_count_matrix_csv
	String output_name
	String sccloud_version
	String zones
	String memory
	Int disk_space
	Int preemptible
	String? restrictions
	String? attributes
	Boolean? select_only_singlets
	Int? minimum_number_of_genes
	String? dropseq_genome

	command {
		set -e
		export TMPDIR=/tmp

		python <<CODE
		from subprocess import check_call
		call_args = ['scCloud', 'aggregate_matrix', '${input_count_matrix_csv}', '${output_name}', '--google-cloud']
		if '${restrictions}' is not '':
			ress = '${restrictions}'.split(';')
			for res in ress:
				call_args.extend(['--restriction', res])
		if '${attributes}' is not '':
			call_args.extend(['--attributes', '${attributes}'])
		if '${select_only_singlets}' is 'true':
			call_args.append('--select-only-singlets')
		if '${minimum_number_of_genes}' is not '':
			call_args.extend(['--minimum-number-of-genes', '${minimum_number_of_genes}'])
		if '${dropseq_genome}' is not '':
			call_args.extend(['--dropseq-genome', '${dropseq_genome}'])

		print(' '.join(call_args))
		check_call(call_args)
		CODE
	}

	output {
		File output_10x_h5 = '${output_name}_10x.h5'
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: 1
		preemptible: preemptible
	}
}

task run_scCloud_cluster {
	File input_10x_file
	String output_name
	String sccloud_version
	String zones
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible
	String? genome
	Boolean? cite_seq
	Boolean? output_filtration_results
	Boolean? plot_filtration_results
	String? plot_filtration_figsize
	Boolean? output_seurat_compatible
	Boolean? output_loom
	Boolean? output_parquet
	Boolean? correct_batch_effect
	String? batch_group_by
	Int? min_genes
	Int? max_genes
	Int? min_umis
	Int? max_umis
	String? mito_prefix
	Float? percent_mito
	Float? gene_percent_cells
	Int? min_genes_on_raw
	Float? counts_per_cell_after
	Int? random_state
	Boolean? run_uncentered_pca
	Boolean? no_variable_gene_selection
	Boolean? no_submat_to_dense
	Int? nPC
	Int? nDC
	Float? diffmap_alpha
	Int? diffmap_K
	Boolean? run_louvain
	Float? louvain_resolution
	String? louvain_affinity
	Boolean? run_approximated_louvain
	Int? approx_louvain_ninit
	Int? approx_louvain_nclusters
	Float? approx_louvain_resolution
	Boolean? run_tsne
	Float? tsne_perplexity
	Boolean? run_fitsne
	Boolean? run_umap
	Boolean? umap_on_diffmap
	Int? umap_K
	Float? umap_min_dist
	Float? umap_spread
	Boolean? run_fle
	Int? fle_K
	Int? fle_n_steps
	String? fle_affinity

	command {
		set -e
		export TMPDIR=/tmp
		monitor_script.sh > monitoring.log &

		python <<CODE
		from subprocess import check_call
		call_args = ['scCloud', 'cluster', '${input_10x_file}', '${output_name}', '-p', '${num_cpu}']
		if '${genome}' is not '':
			call_args.extend(['--genome', '${genome}'])
		if '${cite_seq}' is 'true':
			call_args.append('--cite-seq')
		if '${output_filtration_results}' is 'true':
			call_args.append('--output-filtration-results')
		if '${plot_filtration_results}' is 'true':
			call_args.append('--plot-filtration-results')
		if '${plot_filtration_figsize}' is not '':
			call_args.extend(['--plot-filtration-figsize', '${plot_filtration_figsize}'])
		if '${output_seurat_compatible}' is 'true':
			call_args.append('--output-seurat-compatible')
		if '${output_loom}' is 'true':
			call_args.append('--output-loom')
		if '${correct_batch_effect}' is 'true':
			call_args.append('--correct-batch-effect')
			if '${batch_group_by}' is not '':
				call_args.extend(['--batch-group-by', '${batch_group_by}'])
		if '${min_genes}' is not '':
			call_args.extend(['--min-genes', '${min_genes}'])
		if '${max_genes}' is not '':
			call_args.extend(['--max-genes', '${max_genes}'])
		if '${min_umis}' is not '':
			call_args.extend(['--min-umis', '${min_umis}'])
		if '${max_umis}' is not '':
			call_args.extend(['--max-umis', '${max_umis}'])
		if '${mito_prefix}' is not '':
			call_args.extend(['--mito-prefix', '${mito_prefix}'])
		if '${percent_mito}' is not '' :
			call_args.extend(['--percent-mito', '${percent_mito}'])
		if '${gene_percent_cells}' is not '':
			call_args.extend(['--gene-percent-cells', '${gene_percent_cells}'])
		if '${min_genes_on_raw}' is not '':
			call_args.extend(['--min-genes-on-raw', '${min_genes_on_raw}'])
		if '${counts_per_cell_after}' is not '':
			call_args.extend(['--counts-per-cell-after', '${counts_per_cell_after}'])
		if '${random_state}' is not '':
			call_args.extend(['--random-state', '${random_state}'])
		if '${run_uncentered_pca}' is 'true':
			call_args.append('--run-uncentered-pca')
		if '${no_variable_gene_selection}' is 'true':
			call_args.append('--no-variable-gene-selection')
		if '${no_submat_to_dense}' is 'true':
			call_args.append('--no-submat-to-dense')
		if '${nPC}' is not '':
			call_args.extend(['--nPC', '${nPC}'])
		if '${nDC}' is not '':
			call_args.extend(['--nDC', '${nDC}'])
		if '${diffmap_alpha}' is not '':
			call_args.extend(['--diffmap-alpha', '${diffmap_alpha}'])
		if '${diffmap_K}' is not '':
			call_args.extend(['--diffmap-K', '${diffmap_K}'])
		if '${run_louvain}' is 'true':
			call_args.append('--run-louvain')
		if '${louvain_resolution}' is not '':
			call_args.extend(['--louvain-resolution', '${louvain_resolution}'])
		if '${louvain_affinity}' is not '':
			call_args.extend(['--louvain-affinity', '${louvain_affinity}'])
		if '${run_approximated_louvain}' is 'true':
			call_args.append('--run-approximated-louvain')
		if '${approx_louvain_ninit}' is not '':
			call_args.extend(['--approx-louvain-ninit', '${approx_louvain_ninit}'])
		if '${approx_louvain_nclusters}' is not '':
			call_args.extend(['--approx-louvain-nclusters', '${approx_louvain_nclusters}'])
		if '${approx_louvain_resolution}' is not '':
			call_args.extend(['--approx-louvain-resolution', '${approx_louvain_resolution}'])
		if '${run_tsne}' is 'true':
			call_args.append('--run-tsne')
		if '${tsne_perplexity}' is not '':
			call_args.extend(['--tsne-perplexity', '${tsne_perplexity}'])
		if '${run_fitsne}' is 'true':
			call_args.append('--run-fitsne')
		if '${run_umap}' is 'true':
			call_args.append('--run-umap')
		if '${umap_on_diffmap}' is 'true':
			call_args.append('--umap-on-diffmap')
		if '${umap_K}' is not '':
			call_args.extend(['--umap-K', '${umap_K}'])
		if '${umap_min_dist}' is not '':
			call_args.extend(['--umap-min-dist', '${umap_min_dist}'])
		if '${umap_spread}' is not '':
			call_args.extend(['--umap-spread', '${umap_spread}'])
		if '${run_fle}' is 'true':
			call_args.append('--run-fle')
		if '${fle_K}' is not '':
			call_args.extend(['--fle-K', '${fle_K}'])
		if '${fle_n_steps}' is not '':
			call_args.extend(['--fle-n-steps', '${fle_n_steps}'])
		if '${fle_affinity}' is not '':
			call_args.extend(['--fle-affinity', '${fle_affinity}'])
		print(' '.join(call_args))
		check_call(call_args)
		if '${output_parquet}' is 'true':
			call_args = ['scCloud', 'parquet', '${output_name}.h5ad', '${output_name}', '-p', '${num_cpu}']
			print(' '.join(call_args))
			check_call(call_args)			
		CODE
	}

	output {
		File output_h5ad = "${output_name}.h5ad"
		Array[File] output_seurat_h5ad = glob("${output_name}.seurat.h5ad")
		Array[File] output_filt_xlsx = glob("${output_name}.filt.xlsx")
		Array[File] output_filt_plot = glob("${output_name}.filt.*.pdf")
		Array[File] output_loom_file = glob("${output_name}.loom")
		Array[File] output_parquet_file = glob("${output_name}.parquet")
		File monitoringLog = "monitoring.log"
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}
}

task run_scCloud_de_analysis {
	File input_h5ad
	String output_name
	String sccloud_version
	String zones	
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible
	String? labels
	Float? alpha
	Boolean? fisher
	Boolean? mwu
	Boolean? roc

	Boolean? annotate_cluster
	String? organism
	Float? minimum_report_score

	Boolean? find_markers_lightgbm
	Boolean? remove_ribo
	Float? min_gain
	Int? random_state

	command {
		set -e
		export TMPDIR=/tmp
		monitor_script.sh > monitoring.log &

		python <<CODE
		from subprocess import check_call
		call_args = ['mv', '-f', '${input_h5ad}', '${output_name}.h5ad']
		print(' '.join(call_args))
		check_call(call_args)			
		call_args = ['scCloud', 'de_analysis', '${output_name}.h5ad', '${output_name}.de.xlsx', '-p', '${num_cpu}']
		if '${labels}' is not '':
			call_args.extend(['--labels', '${labels}'])
		if '${alpha}' is not '':
			call_args.extend(['--alpha', '${alpha}'])
		if '${fisher}' is 'true':
			call_args.append('--fisher')
		if '${mwu}' is 'true':
			call_args.append('--mwu')
		if '${roc}' is 'true':
			call_args.append('--roc')
		print(' '.join(call_args))
		check_call(call_args)
		if '${find_markers_lightgbm}' is 'true':
			call_args = ['scCloud', 'find_markers', '${output_name}.h5ad', '${output_name}.markers.xlsx', '-p', '${num_cpu}']
			if '${labels}' is not '':
				call_args.extend(['--labels', '${labels}'])
			if '${remove_ribo}' is 'true':
				call_args.append('--remove-ribo')
			if '${min_gain}' is not '':
				call_args.extend(['--min-gain', '${min_gain}'])
			if '${random_state}' is not '':
				call_args.extend(['--random-state', '${random_state}'])
			print(' '.join(call_args))
			check_call(call_args)
		if '${annotate_cluster}' is 'true':
			call_args = ['scCloud', 'annotate_cluster', '${output_name}.h5ad', '${output_name}' + '.anno.txt']
			if '${organism}' is not '':
				call_args.extend(['--json-file', '${organism}'])
			if '${minimum_report_score}' is not '':
				call_args.extend(['--minimum-report-score', '${minimum_report_score}'])
			print(' '.join(call_args))
			check_call(call_args)			
		CODE
	}

	output {
		File output_de_h5ad = "${output_name}.h5ad"
		File output_de_xlsx = "${output_name}.de.xlsx"
		Array[File] output_markers_xlsx = glob("${output_name}.markers.xlsx")
		Array[File] output_anno_file = glob("${output_name}.anno.txt")
		File monitoringLog = "monitoring.log"
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}
}

task run_scCloud_plot {
	File input_h5ad
	String output_name
	String sccloud_version
	String zones
	String memory
	Int disk_space
	Int preemptible
	String? plot_composition
	String? plot_tsne
	String? plot_umap
	String? plot_fle
	String? plot_diffmap
	String? plot_citeseq_tsne

	command {
		set -e
		export TMPDIR=/tmp

		python <<CODE
		from subprocess import check_call
		if '${plot_composition}' is not '':
			pairs = '${plot_composition}'.split(',')
			for pair in pairs:
				lab, attr = pair.split(':')
				call_args = ['scCloud', 'plot', 'composition', '--cluster-labels', lab, '--attribute', attr, '--style', 'normalized', '--not-stacked', '${input_h5ad}', '${output_name}.' + lab + '+' + attr + '.composition.pdf']
				print(' '.join(call_args))
				check_call(call_args)
		if '${plot_tsne}' is not '':
			call_args = ['scCloud', 'plot', 'scatter', '--attributes', '${plot_tsne}', '${input_h5ad}', '${output_name}.tsne.pdf']
			print(' '.join(call_args))
			check_call(call_args)
		if '${plot_umap}' is not '':
			call_args = ['scCloud', 'plot', 'scatter', '--basis', 'umap', '--attributes', '${plot_umap}', '${input_h5ad}', '${output_name}.umap.pdf']
			print(' '.join(call_args))
			check_call(call_args)
		if '${plot_fle}' is not '':
			call_args = ['scCloud', 'plot', 'scatter', '--basis', 'fle', '--attributes', '${plot_fle}', '${input_h5ad}', '${output_name}.fle.pdf']
			print(' '.join(call_args))
			check_call(call_args)
		if '${plot_diffmap}' is not '':
			attrs = '${plot_diffmap}'.split(',')
			for attr in attrs:
				call_args = ['scCloud', 'iplot', '--attribute', attr, 'diffmap_pca', '${input_h5ad}', '${output_name}.' + attr + '.diffmap_pca.html']
				print(' '.join(call_args))
				check_call(call_args)
		if '${plot_citeseq_tsne}' is not '':
			call_args = ['scCloud', 'plot', 'scatter', '--basis', 'citeseq_tsne', '--attributes', '${plot_citeseq_tsne}', '${input_h5ad}', '${output_name}.epitope.tsne.pdf']
			print(' '.join(call_args))
			check_call(call_args)
		CODE
	}

	output {
		Array[File] output_pdfs = glob("*.pdf")
		Array[File] output_htmls = glob("*.html")
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: 1
		preemptible: preemptible
	}
}

task run_scCloud_scp_output {
	File input_h5ad
	String output_name
	Boolean output_dense
	String sccloud_version
	String zones
	String memory
	Int disk_space
	Int preemptible

	command {
		set -e
		export TMPDIR=/tmp
		scCloud scp_output ${true='--dense' false='' output_dense} ${input_h5ad} ${output_name}
	}

	output {
		Array[File] output_scp_files = glob("${output_name}.scp.*")
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: 1
		preemptible: preemptible
	}
}

task run_scCloud_subcluster {
	File input_h5ad
	String output_name
	String sccloud_version
	String zones
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible
	String subset_selections 
	Boolean? correct_batch_effect
	Boolean? output_loom
	Boolean? output_parquet
	Int? random_state
	Boolean? run_uncentered_pca
	Boolean? no_variable_gene_selection
	Boolean? no_submat_to_dense
	Int? nPC
	Int? nDC
	Float? diffmap_alpha
	Int? diffmap_K
	String? calculate_pseudotime
	Boolean? run_louvain
	Float? louvain_resolution
	String? louvain_affinity
	Boolean? run_approximated_louvain
	Int? approx_louvain_ninit
	Int? approx_louvain_nclusters
	Float? approx_louvain_resolution
	Boolean? run_tsne
	Float? tsne_perplexity
	Boolean? run_fitsne
	Boolean? run_umap
	Boolean? umap_on_diffmap
	Int? umap_K
	Float? umap_min_dist
	Float? umap_spread
	Boolean? run_fle
	Int? fle_K
	Int? fle_n_steps
	String? fle_affinity

	command {
		set -e
		export TMPDIR=/tmp
		monitor_script.sh > monitoring.log &

		python <<CODE
		from subprocess import check_call
		call_args = ['scCloud', 'subcluster', '${input_h5ad}', '${output_name}', '-p', '${num_cpu}']
		if '${subset_selections}' is not '':
			sels = '${subset_selections}'.split(';')
			for sel in sels:
				call_args.extend(['--subset-selection', sel])
		if '${correct_batch_effect}' is 'true':
			call_args.append('--correct-batch-effect')
		if '${output_loom}' is 'true':
			call_args.append('--output-loom')
		if '${random_state}' is not '':
			call_args.extend(['--random-state', '${random_state}'])
		if '${run_uncentered_pca}' is 'true':
			call_args.append('--run-uncentered-pca')
		if '${no_variable_gene_selection}' is 'true':
			call_args.append('--no-variable-gene-selection')
		if '${no_submat_to_dense}' is 'true':
			call_args.append('--no-submat-to-dense')
		if '${nPC}' is not '':
			call_args.extend(['--nPC', '${nPC}'])
		if '${nDC}' is not '':
			call_args.extend(['--nDC', '${nDC}'])
		if '${diffmap_alpha}' is not '':
			call_args.extend(['--diffmap-alpha', '${diffmap_alpha}'])
		if '${diffmap_K}' is not '':
			call_args.extend(['--diffmap-K', '${diffmap_K}'])
		if '${calculate_pseudotime}' is not '':
			call_args.extend(['--calculate-pseudotime', '${calculate_pseudotime}'])
		if '${run_louvain}' is 'true':
			call_args.append('--run-louvain')
		if '${louvain_resolution}' is not '':
			call_args.extend(['--louvain-resolution', '${louvain_resolution}'])
		if '${louvain_affinity}' is not '':
			call_args.extend(['--louvain-affinity', '${louvain_affinity}'])
		if '${run_approximated_louvain}' is 'true':
			call_args.append('--run-approximated-louvain')
		if '${approx_louvain_ninit}' is not '':
			call_args.extend(['--approx-louvain-ninit', '${approx_louvain_ninit}'])
		if '${approx_louvain_nclusters}' is not '':
			call_args.extend(['--approx-louvain-nclusters', '${approx_louvain_nclusters}'])
		if '${approx_louvain_resolution}' is not '':
			call_args.extend(['--approx-louvain-resolution', '${approx_louvain_resolution}'])
		if '${run_tsne}' is 'true':
			call_args.append('--run-tsne')
		if '${tsne_perplexity}' is not '':
			call_args.extend(['--tsne-perplexity', '${tsne_perplexity}'])
		if '${run_fitsne}' is 'true':
			call_args.append('--run-fitsne')
		if '${run_umap}' is 'true':
			call_args.append('--run-umap')
		if '${umap_on_diffmap}' is 'true':
			call_args.append('--umap-on-diffmap')
		if '${umap_K}' is not '':
			call_args.extend(['--umap-K', '${umap_K}'])
		if '${umap_min_dist}' is not '':
			call_args.extend(['--umap-min-dist', '${umap_min_dist}'])
		if '${umap_spread}' is not '':
			call_args.extend(['--umap-spread', '${umap_spread}'])
		if '${run_fle}' is 'true':
			call_args.append('--run-fle')
		if '${fle_K}' is not '':
			call_args.extend(['--fle-K', '${fle_K}'])
		if '${fle_n_steps}' is not '':
			call_args.extend(['--fle-n-steps', '${fle_n_steps}'])
		if '${fle_affinity}' is not '':
			call_args.extend(['--fle-affinity', '${fle_affinity}'])
		print(' '.join(call_args))
		check_call(call_args)
		if '${output_parquet}' is 'true':
			call_args = ['scCloud', 'parquet', '${output_name}.h5ad', '${output_name}', '-p', '${num_cpu}']
			print(' '.join(call_args))
			check_call(call_args)
		CODE
	}

	output {
		File output_h5ad = "${output_name}.h5ad"
		Array[File] output_loom_file = glob("${output_name}.loom")
		Array[File] output_parquet_file = glob("${output_name}.parquet")
		File monitoringLog = "monitoring.log"
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}
}

task organize_results {
	String output_name
	String sccloud_version
	String zones
	Int disk_space
	Int preemptible
	File? output_10x_h5
	File? output_h5ad
	Array[File]? output_seurat_h5ad
	Array[File]? output_filt_xlsx
	Array[File]? output_filt_plot
	Array[File]? output_loom_file
	Array[File]? output_parquet_file
	File? output_de_h5ad
	File? output_de_xlsx
	Array[File]? output_markers_xlsx
	Array[File]? output_anno_file
	Array[File]? output_pdfs
	Array[File]? output_htmls
	Array[File]? output_scp_files

	command {
		set -e
		export TMPDIR=/tmp

		python <<CODE
		import os
		from subprocess import check_call
		dest = os.path.dirname('${output_name}') + '/'

		# check_call(['mkdir', '-p', dest])
		
		files = ['${output_10x_h5}', '${sep=" " output_seurat_h5ad}', '${sep=" " output_filt_xlsx}', '${sep=" " output_loom_file}', '${sep=" " output_parquet_file}', '${output_de_xlsx}', '${sep=" " output_markers_xlsx}', '${sep=" " output_anno_file}']
		files.append('${output_h5ad}' if '${output_de_h5ad}' is '' else '${output_de_h5ad}')
		files.extend('${sep="," output_filt_plot}'.split(','))
		files.extend('${sep="," output_pdfs}'.split(','))
		files.extend('${sep="," output_htmls}'.split(','))
		files.extend('${sep="," output_scp_files}'.split(','))
		for file in files:
			if file is not '':
				# call_args = ['cp', file, dest]
				call_args = ['gsutil', '-q', 'cp', file, dest]
				print(' '.join(call_args))
				check_call(call_args)
		CODE
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: "30 GB"
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: 1
		preemptible: preemptible
	}
}

task generate_hashing_cite_seq_tasks {
	File input_sample_sheet
	String sccloud_version
	String zones
	Int preemptible

	command {
		set -e
		export TMPDIR=/tmp

		python <<CODE
		import pandas as pd 
		from subprocess import check_call

		df = pd.read_csv('${input_sample_sheet}', header = 0, index_col = 0)
		with open('hashing.txt', 'w') as fo1, open('cite_seq.txt', 'w') as fo2, open('id2rna.txt', 'w') as fo3, open('id2adt.txt', 'w') as fo4, open('id2type.txt', 'w') as fo5:
			for outname, row in df.iterrows():
				if row['TYPE'] == 'cite-seq':
					fo2.write(outname + '\n')
				else:
					assert row['TYPE'] in ['cell-hashing', 'nuclei-hashing']
					fo1.write(outname + '\n')
				fo3.write(outname + '\t' + row['RNA'] + '\n')
				fo4.write(outname + '\t' + row['ADT'] + '\n')
				fo5.write(outname + '\t' + row['TYPE'] + '\n')
		CODE
	}

	output {
		Array[String] hashing_ids = read_lines('hashing.txt')
		Array[String] cite_seq_ids = read_lines('cite_seq.txt')
		Map[String, String] id2rna = read_map('id2rna.txt')
		Map[String, String] id2adt = read_map('id2adt.txt')
		Map[String, String] id2type = read_map('id2type.txt')
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		preemptible: preemptible
	}
}

task run_scCloud_demuxEM {
	File input_adt_csv
	File input_raw_gene_bc_matrices_h5
	String output_dir
	String output_name
	String sccloud_version
	String zones
	Int num_cpu
	String memory
	Int disk_space
	Int preemptible
	String hash_type
	String? genome
	Int? min_num_genes
	Float? max_background_probability
	Int? random_state
	Boolean? generate_diagnostic_plots
	String? generate_gender_plot

	command {
		set -e
		export TMPDIR=/tmp
		monitor_script.sh > monitoring.log &

		python <<CODE
		from subprocess import check_call
		call_args = ['scCloud', 'demuxEM', '${input_adt_csv}', '${input_raw_gene_bc_matrices_h5}', '${output_name}', '-p', '${num_cpu}', '--hash-type', '${hash_type}']
		if '${genome}' is not '':
			call_args.extend(['--genome', '${genome}'])
		if '${min_num_genes}' is not '':
			call_args.extend(['--min-num-genes', '${min_num_genes}'])
		if '${max_background_probability}' is not '':
			call_args.extend(['--max-background-probability', '${max_background_probability}'])
		if '${random_state}' is not '':
			call_args.extend(['--random-state', '${random_state}'])
		if '${generate_diagnostic_plots}' is 'true':
			call_args.append('--generate-diagnostic-plots')
		if '${generate_gender_plot}' is not '':
			call_args.extend(['--generate-gender-plot', '${generate_gender_plot}'])
		print(' '.join(call_args))
		check_call(call_args)
		CODE

		gsutil -q cp ${output_name}_demux_10x.h5 ${output_dir}/${output_name}/
		gsutil -q cp ${output_name}_ADTs.h5ad ${output_dir}/${output_name}/
		gsutil -q cp ${output_name}_demux.h5ad ${output_dir}/${output_name}/
		gsutil -q -m cp ${output_name}.*.pdf ${output_dir}/${output_name}/
		# mkdir -p ${output_dir}/${output_name}
		# cp ${output_name}_demux_10x.h5 ${output_dir}/${output_name}/
		# cp ${output_name}_ADTs.h5ad ${output_dir}/${output_name}/
		# cp ${output_name}_demux.h5ad ${output_dir}/${output_name}/
		# cp ${output_name}.*.pdf ${output_dir}/${output_name}/
	}

	output {
		String output_folder = "${output_dir}/${output_name}"
		File monitoringLog = "monitoring.log"
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: num_cpu
		preemptible: preemptible
	}
}

task run_scCloud_merge_rna_adt {
	File input_raw_gene_bc_matrices_h5
	File input_adt_csv
	File antibody_control_csv
	String output_dir
	String output_name
	String sccloud_version
	String zones
	String memory
	Int disk_space
	Int preemptible

	command {
		set -e
		export TMPDIR=/tmp
		monitor_script.sh > monitoring.log &

		scCloud merge_rna_adt ${input_raw_gene_bc_matrices_h5} ${input_adt_csv} ${antibody_control_csv} ${output_name}_merged_10x.h5

		gsutil -q cp ${output_name}_merged_10x.h5 ${output_dir}/${output_name}/
		# mkdir -p ${output_dir}/${output_name}
		# cp ${output_name}_merged_10x.h5 ${output_dir}/${output_name}/
	}

	output {
		String output_folder = "${output_dir}/${output_name}"
		File monitoringLog = "monitoring.log"
	}

	runtime {
		docker: "regevlab/sccloud-${sccloud_version}"
		zones: zones
		memory: memory
		bootDiskSizeGb: 12
		disks: "local-disk ${disk_space} HDD"
		cpu: 1
		preemptible: preemptible
	}
}
