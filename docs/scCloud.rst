Run single-cell cloud-based analysis module (scCloud) for scRNA-Seq data analysis
---------------------------------------------------------------------------------

Follow the steps below to run **scCloud** on FireCloud.

#. Create a sample sheet, **count_matrix.csv**, which describes the metadata for each 10x channel. The sample sheet should at least contain 2 columns --- *Sample* and *Location*. *Sample* refers to sample names and *Location* refers to the location of the channel-specific count matrix in either 10x format (e.g. ``gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_1/filtered_gene_bc_matrices_h5.h5`` for v2 chemistry, ``gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_1/filtered_feature_bc_matrices.h5``) for v3 chemistry or dropseq format (e.g. ``gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_2/sample_2.umi.dge.txt.gz``). You are free to add any other columns and these columns will be used in selecting channels for futher analysis. In the example below, we have *Source*, which refers to the tissue of origin, *Platform*, which refers to the sequencing platform, *Donor*, which refers to the donor ID, and *Reference*, which refers to the reference genome.

	Example::

		Sample,Source,Platform,Donor,Reference,Location
		sample_1,bone_marrow,NextSeq,1,GRCh38,gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_1/filtered_gene_bc_matrices_h5.h5
		sample_2,bone_marrow,NextSeq,2,GRCh38,gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_2/filtered_gene_bc_matrices_h5.h5
		sample_3,pbmc,NextSeq,1,GRCh38,gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_3/filtered_feature_bc_matrices.h5
		sample_4,pbmc,NextSeq,2,GRCh38,gs://fc-e0000000-0000-0000-0000-000000000000/my_dir/sample_4/filtered_feature_bc_matrices.h5

	If you ran **cellranger_mkfastq_count**, you should obtain a template **count_matrix.csv** file that you can modify from **cellranger_mkfastq_count**'s outputs. 

#. Upload your sample sheet to the workspace.  

	Example::
	
		gsutil cp /foo/bar/projects/my_count_matrix.csv gs://fc-e0000000-0000-0000-0000-000000000000/

#. Import **scCloud** method.

	In FireCloud, select the "Method Configurations" tab then click "Import Configuration". Click "Import From Method Repository". Type **scCloud/scCloud**.

#. Uncheck "Configure inputs/outputs using the Workspace Data Model"

---------------------------------

scCloud steps:
^^^^^^^^^^^^^^

**scCloud** processes single cell data in the following steps:

#. **aggregate_matrix**. This step aggregates channel-specific count matrices into one big count matrix. Users could specify which channels they want to analyze and which sample attributes they want to import to the count matrix in this step.

#. **cluster**. This step is the main analysis step. In this step, **scCloud** performs low quality cell filtration, variable gene selection, batch correction, dimension reduction, diffusion map calculation, graph-based clustering and 2D visualization calculation (e.g. t-SNE/FLE).

#. **de_analysis**. This step is optional. In this step, **scCloud** could calculate potential markers for each cluster by performing a variety of differential expression (DE) analysis. The available DE tests include Welch's t test, Fisher's exact test, and Mann-Whitney U test. **scCloud** could also calculate the area under ROC curve values for putative markers. If *find_markers_lightgbm* is on, **scCloud** will try to identify cluster-specific markers by training a LightGBM classifier. If the samples are human or mouse immune cells, **scCloud** could also optionally annotate putative cell types for each cluster based on known markers.

#. **plot**. This step is optional. In this step, **scCloud** could generate 6 types of figures based on the **cluster** step results. First, **composition** plots are bar plots showing the cell compositions (from different conditions) for each cluster. This type of plots is useful to fast assess library quality and batch effects. Second, **tsne**, **umap**, **fle** plots show the same t-SNE/UMAP/FLE (force-directed layout embedding) colored by different attributes (e.g. cluster labels, conditions) side-by-side. Third, **diffmap** plots are 3D interactive plots showing the diffusion maps. The 3 coordinates are the first 3 PCs of all diffusion components. Lastly, if input is CITE-Seq data, **citeseq_tsne** plots tSNEs based on epitope expression.

In the following, we will first introduce global inputs and then introduce the WDL inputs and outputs for each step separately. But please note that you need to set inputs from all steps simultaneously in the FireCloud WDL. 

Note that we will make the required inputs/outputs bold and all other inputs/outputs are optional.

---------------------------------

global inputs
^^^^^^^^^^^^^

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - **input_count_matrix_csv**
	  - Input CSV file describing metadata of each 10x channel
	  - "gs://fc-e0000000-0000-0000-0000-000000000000/my_count_matrix.csv"
	  - 
	* - **output_name**
	  - This is the prefix for all output files. It should contain the google bucket url, subdirectory name and output name prefix
	  - "gs://fc-e0000000-0000-0000-0000-000000000000/my_results_dir/my_results"
	  - 
	* - genome
	  - A string contains comma-separated genome names. scCloud will read all groups associated with genome names in the list from the hdf5 file. If genome is None, all groups will be considered.
	  - "GRCh38"
	  - 
	* - sccloud_version
	  - scCloud version
	  - "0.7.0"
	  - "0.7.0"
	* - zones
	  - Google cloud zones
	  - "us-east1-b us-east1-c us-east1-d"
	  - "us-east1-b us-east1-c us-east1-d"
	* - num_cpu
	  - Number of cpus per scCloud job
	  - 32
	  - 64
	* - memory
	  - Memory size string
	  - "200G"
	  - "200G"
	* - disk_space
	  - Total disk space
	  - 100
	  - 100
	* - preemptible
	  - Number of preemptible tries
	  - 2
	  - 2

---------------------------------

aggregate_matrix
^^^^^^^^^^^^^^^^

aggregate_matrix inputs
+++++++++++++++++++++++

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - restrictions
	  - Select channels that satisfy all restrictions. Each restriction takes the format of name:value,...,value. Multiple restrictions are separated by ';'
	  - "Source:bone_marrow;Platform:NextSeq"
	  - 
	* - attributes
	  - Specify a comma-separated list of outputted attributes. These attributes should be column names in the count_matrix.csv file
	  - "Source,Platform,Donor"
	  - 
	* - select_only_singlets
	  - If we have demultiplexed data, turning on this option will make scCloud only include barcodes that are predicted as singlets
	  - true
	  - false
	* - minimum_number_of_genes
	  - Only keep barcodes with at least this number of expressed genes
	  - 100
	  - 100
	* - is_dropseq
	  - If inputs are dropseq data
	  - true
	  - false

aggregate_matrix output
+++++++++++++++++++++++

.. list-table::
	:widths: 5 5 20
	:header-rows: 1

	* - Name
	  - Type
	  - Description
	* - **output_10x_h5**
	  - File
	  - Aggregated count matrix in 10x format

---------------------------------

cluster
^^^^^^^

cluster inputs
++++++++++++++

Note that we will only list important inputs here. For other inputs, please refer to **scCloud** package documentation.

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - cite_seq
	  - | Data are CITE-Seq data. scCloud will perform analyses on RNA count matrix first. 
	    | Then it will attach the ADT matrix to the RNA matrix with all antibody names changing to 'AD-' + antibody_name. 
	    | Lastly, it will embed the antibody expression using t-SNE (the basis used for plotting is 'citeseq_tsne')
	  - true
	  - false
	* - output_filtration_results
	  - If output cell and gene filtration results to a spreadsheet
	  - true
	  - true
	* - plot_filtration_results
	  - If plot filtration results as PDF files
	  - true
	  - true
	* - plot_filtration_figsize
	  - Figure size for filtration plots. <figsize> is a comma-separated list of two numbers, the width and height of the figure (e.g. 6,4)
	  - 6,4
	  -
	* - output_seurat_compatible
	  - Output seurat-compatible h5ad file. Caution: File size might be large, do not turn this option on for large data sets.
	  - true
	  - false
	* - output_loom
	  - If output loom-formatted file
	  - false
	  - false
	* - output_parquet
	  - If output parquet-formatted file
	  - false
	  - false
	* - correct_batch_effect
	  - If correct batch effects
	  - false
	  - false
	* - batch_group_by
	  - | Batch correction assumes the differences in gene expression between channels are due to batch effects. 
	    | However, in many cases, we know that channels can be partitioned into several groups and each group is biologically different from others. 
	    | In this case, we will only perform batch correction for channels within each group. This option defines the groups. 
	    | If <expression> is None, we assume all channels are from one group. Otherwise, groups are defined according to <expression>.
	    | <expression> takes the form of either ‘attr’, or ‘attr1+attr2+…+attrn’, or ‘attr=value11,…,value1n_1;value21,…,value2n_2;…;valuem1,…,valuemn_m’.
	    | In the first form, ‘attr’ should be an existing sample attribute, and groups are defined by ‘attr’.
	    | In the second form, ‘attr1’,…,’attrn’ are n existing sample attributes and groups are defined by the Cartesian product of these n attributes.
	    | In the last form, there will be m + 1 groups. 
	    | A cell belongs to group i (i > 0) if and only if its sample attribute ‘attr’ has a value among valuei1,…,valuein_i. 
	    | A cell belongs to group 0 if it does not belong to any other groups
	  - "Donor"
	  - None
	* - min_genes
	  - Only keep cells with at least <min_genes> of genes
	  - 500
	  - 500
	* - max_genes
	  - Only keep cells with less than <max_genes> of genes
	  - 6000
	  - 6000
	* - min_umis
	  - Only keep cells with at least <min_umis> of UMIs
	  - 600
	  - 100
	* - max_umis
	  - Only keep cells with less than <max_umis> of UMIs
	  - 60000
	  - 600000
	* - mito_prefix
	  - Prefix for mitochondrial genes
	  - "mt-"
	  - "MT-"
	* - percent_mito
	  - Only keep cells with mitochondrial ratio less than <percent_mito>
	  - 0.1
	  - 0.1
	* - gene_percent_cells
	  - Only use genes that are expressed in at <ratio> * 100 percent of cells to select variable genes
	  - 0.0005
	  - 0.0005
	* - min_genes_on_raw
	  - If input are raw 10x matrix, which include all barcodes, perform a pre-filtration step to keep the data size small. In the pre-filtration step, only keep cells with at least <min_genes_on_raw> of genes
	  - 100
	  - 100
	* - counts_per_cell_after
	  - Total counts per cell after normalization
	  - 1e5
	  - 1e5
	* - random_state
	  - Random number generator seed
	  - 0
	  - 0
	* - nPC
	  - Number of principal components
	  - 50
	  - 50
	* - nDC
	  - Number of diffusion components
	  - 50
	  - 50
	* - diffmap_K
	  - Number of neighbors used for constructing affinity matrix
	  - 100
	  - 100
	* - diffmap_alpha
	  - Power parameter for diffusion-based pseudotime
	  - 0.5
	  - 0.5
	* - diffmap-full-speed
	  - For the sake of reproducibility, we only run one thread for building kNN indices. Turn on this option will allow multiple threads to be used for index building. However, it will also reduce reproducibility due to the racing between multiple threads
	  - true
	  - false
	* - run_louvain
	  - Run louvain clustering algorithm
	  - true
	  - true
	* - louvain_resolution
	  - Resolution parameter for the louvain clustering algorithm
	  - 1.3
	  - 1.3
	* - run_approximated_louvain
	  - Run approximated louvain clustering algorithm
	  - true
	  - false
	* - approx_louvain_ninit
	  - Number of Kmeans tries
	  - 30
	  - 20
	* - approx_louvain_nclusters
	  - Number of clusters for Kmeans initialization
	  - 40
	  - 30
	* - approx_louvain_resolution
	  - Resolution parameter for louvain
	  - 1.3
	  - 1.3
	* - run_tsne
	  - Run multi-core t-SNE for visualization
	  - true
	  - true
	* - tsne_perplexity
	  - t-SNE’s perplexity parameter
	  - 30
	  - 30
	* - run_fitsne
	  - Run FIt-SNE for visualization
	  - true
	  - false
	* - run_umap
	  - Run umap for visualization
	  - true
	  - false
	* - run_fle
	  - Run force-directed layout embedding
	  - true
	  - false
	* - fle_K
	  - K neighbors for building graph for FLE
	  - 50
	  - 50
	* - fle_n_steps
	  - Number of iterations for FLE
	  - 10000
	  - 10000

cluster outputs
+++++++++++++++

.. list-table::
	:widths: 5 5 20
	:header-rows: 1

	* - Name
	  - Type
	  - Description
	* - **output_h5ad**
	  - File
	  - | Output file in h5ad format (output_name.h5ad).
	    | To load this file in python, use ``import scCloud; data = scCloud.tools.read_input('output_name.h5ad', mode = 'a')``.
	    | The log-normalized expression matrix is stored in ``data.X`` as a CSR-format sparse matrix.
	    | The ``obs`` field contains cell related attributes, including clustering results.
	    | For example, ``data.obs_names`` records cell barcodes; ``data.obs['Channel']`` records the channel each cell comes from;
	    | ``data.obs['n_genes']``, ``data.obs['n_counts']``, and ``data.obs['percent_mito']`` record the number of expressed genes, total UMI count, and mitochondrial rate for each cell respectively;
	    | ``data.obs['louvain_labels']`` and ``data.obs['approx_louvain_labels']`` record each cell's cluster labels using different clustring algorithms;
	    | ``data.obs['pseudo_time']`` records the inferred pseudotime for each cell.
	    | The ``var`` field contains gene related attributes.
	    | For example, ``data.var_names`` records gene symbols, ``data.var['gene_ids']`` records Ensembl gene IDs, and ``data.var['selected']`` records selected variable genes.
	    | The ``obsm`` field records embedding coordiates.
	    | For example, ``data.obsm['X_pca']`` records PCA coordinates, ``data.obsm['X_tsne']`` records tSNE coordinates,
	    | ``data.obsm['X_umap']`` records UMAP coordinates, ``data.obsm['X_diffmap']`` records diffusion map coordinates,
	    | ``data.obsm['X_diffmap_pca']`` records the first 3 PCs by projecting the diffusion components using PCA,
	    | and ``data.obsm['X_fle']`` records the force-directed layout coordinates from the diffusion components.
	    | The ``uns`` field stores other related information, such as reference genome (``data.uns['genome']``).
	    | If '--make-output-seurat-compatible' is on, this file can be loaded into R and converted into a Seurat object
	* - output_seurat_h5ad
	  - File
	  - h5ad file in seurat-compatible manner. This file can be loaded into R and converted into a Seurat object
	* - output_filt_xlsx
	  - File
	  - | Spreadsheet containing filtration results (output_name.filt.xlsx).
	    | This file has two sheets --- Cell filtration stats and Gene filtration stats.
	    | The first sheet records cell filtering results and it has 10 columns:
	    | Channel, channel name; kept, number of cells kept; median_n_genes, median number of expressed genes in kept cells; median_n_umis, median number of UMIs in kept cells;
	    | median_percent_mito, median mitochondrial rate as UMIs between mitochondrial genes and all genes in kept cells;
	    | filt, number of cells filtered out; total, total number of cells before filtration, if the input contain all barcodes, this number is the cells left after 'min_genes_on_raw' filtration;
	    | median_n_genes_before, median expressed genes per cell before filtration; median_n_umis_before, median UMIs per cell before filtration;
	    | median_percent_mito_before, median mitochondrial rate per cell before filtration.
	    | The channels are sorted in ascending order with respect to the number of kept cells per channel.
	    | The second sheet records genes that failed to pass the filtering.
	    | This sheet has 3 columns: gene, gene name; n_cells, number of cells this gene is expressed; percent_cells, the fraction of cells this gene is expressed.
	    | Genes are ranked in ascending order according to number of cells the gene is expressed.
	    | Note that only genes not expressed in any cell are removed from the data.
	    | Other filtered genes are marked as non-robust and not used for TPM-like normalization
	* - output_filt_plot
	  - Array[File]
	  - | If not empty, this array contains 3 PDF files.
	    | output_name.filt.gene.pdf, which contains violin plots contrasting gene count distributions before and after filtration per channel.
	    | output_name.filt.UMI.pdf, which contains violin plots contrasting UMI count distributions before and after filtration per channel.
	    | output_name.filt.mito.pdf, which contains violin plots contrasting mitochondrial rate distributions before and after filtration per channel
	* - output_loom_file
	  - File
	  - Outputted loom file (output_name.loom)
	* - output_parquet_file
	  - File
	  - Outputted PARQUET file that contains metadata and expression levels for every gene

---------------------------------

de_analysis
^^^^^^^^^^^

de_analysis inputs
++++++++++++++++++

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - perform_de_analysis
	  - If perform de analysis
	  - true
	  - true
	* - cluster_labels
	  - Specify the cluster labels used for differential expression analysis
	  - "louvain_labels"
	  - "louvain_labels" 
	* - alpha
	  - Control false discovery rate at <alpha>
	  - 0.05
	  - 0.05
	* - fisher
	  - Calculate Fisher’s exact test
	  - true
	  - true
	* - mwu
	  - Calculate Mann-Whitney U test
	  - true
	  - false
	* - roc
	  - Calculate area under curve in ROC curve
	  - true
	  - false
	* - find_markers_lightgbm
	  - If also detect markers using LightGBM
	  - true
	  - false
	* - remove_ribo
	  - Remove ribosomal genes with either RPL or RPS as prefixes. Currently only works for human
	  - true
	  - false
	* - min_gain
	  - Only report genes with a feature importance score (in gain) of at least <gain>
	  - 10.0
	  - 1.0 
	* - annotate_cluster
	  - If also annotate cell types for clusters based on DE results
	  - true
	  - false
	* - organism
	  - Organism, could either be "human_immune", "mouse_immune", "human_brain", "mouse_brain" or a Google bucket link to a JSON file describing the markers.
	  - "mouse_brain"
	  - "human_immune"
	* - minimum_report_score
	  - Minimum cell type score to report a potential cell type
	  - 0.5
	  - 0.5

de_analysis outputs
+++++++++++++++++++

.. list-table::
	:widths: 5 5 20
	:header-rows: 1

	* - Name
	  - Type
	  - Description
	* - output_de_h5ad
	  - File
	  - h5ad-formatted results with DE results updated (output_name.h5ad)
	* - output_de_xlsx
	  - File
	  - Spreadsheet reporting DE results (output_name.de.xlsx)
	* - output_markers_xlsx
	  - File
	  - An excel spreadsheet containing detected markers. Each cluster has one tab in the spreadsheet and each tab has three columns, listing markers that are strongly up-regulated, weakly up-regulated and down-regulated
	* - output_anno_file
	  - File
	  - Annotation file (output_name.anno.txt)

How cell type annotation works
++++++++++++++++++++++++++++++

In this subsection, we will describe the format of input JSON cell type marker file, the *ad hoc* cell type inference algorithm, and the format of the output putative cell type file.

JSON file
*********

The top level of the JSON file is an object with two name/value pairs: *title* and *cell_types*. *title* is a string describing what this JSON file is for (e.g. "Mouse brain cell markers"). *cell_types* an array listing all cell types this JSON file defines. In the *cell_types* array, each cell type is described using a separate object with 2 to 3 name/value pairs: *name*, *markers*, and optional *subtypes*. *name* describes the cell type name (e.g. "GABAergic neuron"). *markers* is an array of gene-marker describing objects. Each gene-marker describing object has two name/value pairs: *genes* and *weight*. *genes* is an array of positive and negative gene markers(e.g. ["Rbfox3+", "Flt1-"]). *weight* is a real number between 0.0 and 1.0, which describes how much we trust the markers in *genes*. All markers in *genes* share the weight evenly. If we have 4 markers and the weight is 0.1, each marker has a weight of 0.025. The sum of weights from all gene-marker describing objects should be 1.0. *subtypes* describe cell subtypes for the cell type, which has the same format as the top level JSON object.

See below for an example JSON snippet::

	{
	  "title" : "Mouse brain cell markers",
	    "cell_types" : [
	      {
	        "name" : "Glutamatergic neuron",
	        "markers" : [
	          {
	            "genes" : ["Rbfox3+", "Reln+", "Slc17a6+", "Slc17a7+"],
	            "weight" : 1.0
	          }
	        ],
	        "subtypes" : {
	          "title" : "Glutamatergic neuron subtype markers",
	            "cell_types" : [
	              {
	                "name" : "Glutamatergic layer 4",
	                "markers" : [
	                  {
	                    "genes" : ["Rorb+", "Paqr8+"],
	                    "weight" : 1.0
	                  }
	                ]
	              }
	            ]
	        }
	      }
	    ]
	}

Algorithm
*********

We have already calculated the up-regulated and down-regulated genes for each cluster in the differential expression analysis step.

We first load gene markers for each cell type from the JSON file. We exclude marker genes that are not expressed in our data, and their associated weights. 

We then scan each cluster to determine its putative cell types. For each cluster and putative cell type, we calculate a score between 0 and 1, which describes how likely cells from the cluster are of the specific cell type. The higher the score, the more likely cells are from the cell type. To calculate the score, we assign each marker a maximum impact value of 2. For a positive marker, if it is not up-regulated, its impact value is 0. Otherwise, if it additionally has a fold change in percentage of cells expressing this marker (within cluster vs. out of cluster) no less than 1.5, it has an impact value of 2 and is recorded as a strong supporting marker. If the fold change (fc) is less than 1.5, it has an impact value of 1 + (fc - 1) / 0.5 and is recorded as a weak supporting marker. For a negative marker, if it is up-regulated, its impact value is 0. If it is neither up-regulated nor down-regulated, its impact value is 1. Otherwise, if it additionally has 1 over fold change (fc) no less than 1.5, it has an impact value of 2 and is recorded as a strong supporting marker. If 1/fc is less than 1.5, it has an impact value of 1 + (1/fc - 1) / 0.5 and is recorded as a weak supporting marker. The score is calculated as the weighted sum of impact values weighted over the sum of weights multiplied by 2 from all expressed markers. If the score is larger than 0.5 and the cell type has cell subtypes, each cell subtype will also be evaluated. 

Output annotation file
**********************

For each cluster, putative cell types with scores larger than *minimum_report_score* will be reported in descending order with respect to their scores. The report of one putative cell type contains the *name* of the cell type, the *score*, the average percentage (*avgp*) of cells expressing marker within the cluster between all positive supporting markers, *strong support* markers and *weak support* markers. For each supporting marker, the marker name and percentag of cells expressing it within the cluster are reported.

---------------------------------

plot
^^^^

plot inputs
+++++++++++

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - plot_composition
	  - | Takes the format of "label:attr,label:attr,...,label:attr".
	    | If non-empty, generate composition plot for each "label:attr" pair. 
	    | "label" refers to cluster labels and "attr" refers to sample conditions
	  - "louvain_labels:Donor"
	  - None
	* - plot_tsne
	  - | Takes the format of "attr,attr,...,attr". 
	    | If non-empty, plot attr colored t-SNEs side by side
	  - "louvain_labels,Donor"
	  - None
	* - plot_umap
	  - | Takes the format of "attr,attr,...,attr". 
	    | If non-empty, plot attr colored UMAP side by side
	  - "louvain_labels,Donor"
	  - None
	* - plot_fle
	  - | Takes the format of "attr,attr,...,attr". 
	    | If non-empty, plot attr colored FLE (force-directed layout embedding) side by side
	  - "louvain_labels,Donor"
	  - None
	* - plot_diffmap
	  - | Takes the format of "attr,attr,...,attr".
	    | If non-empty, generate attr colored 3D interactive plot. 
	    | The 3 coordinates are the first 3 PCs of all diffusion components
	  - "louvain_labels,Donor"
	  - None
	* - plot_citeseq_tsne
	  - | plot cells based on t-SNE coordinates estimated from antibody expressions.
		| Takes the format of "attr,attr,...,attr". 
	    | If non-empty, plot attr colored t-SNEs side by side
	  - "louvain_labels"
	  - None

plot outputs
++++++++++++

.. list-table::
	:widths: 5 5 20
	:header-rows: 1

	* - Name
	  - Type
	  - Description
	* - output_pdfs
	  - Array[File]
	  - Outputted pdf files
	* - output_htmls
	  - Array[File]
	  - Outputted html files

---------------------------------

Run CITE-Seq analysis
---------------------

To run CITE-Seq analysis, turn on ``cite_seq`` option. 

An embedding of epitope expressions via t-SNE is available at basis ``X_citeseq_tsne``. 

To plot this epitope embedding, turn on ``plot_citeseq_tsne`` option.

---------------------------------

Run subcluster analysis
-----------------------

Once we have **scCloud** outputs, we could further analyze a subset of cells by running **scCloud_subcluster**. To run **scCloud_subcluster**, follow the following steps:

#. Import **scCloud_subcluster** method.

	In FireCloud, select the "Method Configurations" tab then click "Import Configuration". Click "Import From Method Repository". Type **scCloud/scCloud_subcluster**.

#. Uncheck "Configure inputs/outputs using the Workspace Data Model".

scCloud_subcluster steps:
^^^^^^^^^^^^^^^^^^^^^^^^^^

*scCloud_subcluster* processes the subset of single cells in the following steps:

#. **subcluster**. In this step, **scCloud_subcluster** first select the subset of cells from **scCloud** outputs according to user-provided criteria. It then performs batch correction, dimension reduction, diffusion map calculation, graph-based clustering and 2D visualization calculation (e.g. t-SNE/FLE).

#. **de_analysis**. This step is optional. In this step, **scCloud_subcluster** could calculate potential markers for each cluster by performing a variety of differential expression (DE) analysis. The available DE tests include Welch's t test, Fisher's exact test, and Mann-Whitney U test. **scCloud_subcluster** could also calculate the area under ROC curve values for putative markers. If the samples are human or mouse immune cells, **scCloud_subcluster** could also optionally annotate putative cell types for each cluster based on known markers.

#. **plot**. This step is optional. In this step, **scCloud_subcluster** could generate 5 types of figures based on the **subcluster** step results. First, **composition** plots are bar plots showing the cell compositions (from different conditions) for each cluster. This type of plots is useful to fast assess library quality and batch effects. Second, **tsne**, **umap**, **fle** plots show the same t-SNE/UMAP/FLE (force-directed layout embedding) colored by different attributes (e.g. cluster labels, conditions) side-by-side. Lastly, **diffmap** plots are 3D interactive plots showing the diffusion maps. The 3 coordinates are the first 3 PCs of all diffusion components.

scCloud_subcluster's inputs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since **scCloud_subcluster** shares many inputs/outputs with **scCloud**, we will only cover inputs/outputs that are specific to **scCloud_subcluster**.

Note that we will make the required inputs/outputs bold and all other inputs/outputs are optional.

.. list-table::
	:widths: 5 20 10 5
	:header-rows: 1

	* - Name
	  - Description
	  - Example
	  - Default
	* - **input_h5ad**
	  - Input h5ad file containing *scCloud* results
	  - "gs://fc-e0000000-0000-0000-0000-000000000000/my_results_dir/my_results.h5ad"
	  - 
	* - **output_name**
	  - This is the prefix for all output files. It should contain the google bucket url, subdirectory name and output name prefix
	  - "gs://fc-e0000000-0000-0000-0000-000000000000/my_results_dir/my_results_sub"
	  - 
	* - **subset_selections**
	  - | Specify which cells will be included in the subcluster analysis.
	    | This field contains one or more <subset_selection> strings separated by ';'. 
	    | Each <subset_selection> string takes the format of 'attr:value,…,value', which means select cells with attr in the values. 
	    | If multiple <subset_selection> strings are specified, the subset of cells selected is the intersection of these strings
	  - "louvain_labels:3,6"
	  - 
	* - calculate_pseudotime
	  - Calculate diffusion-based pseudotimes based on <roots>. <roots> should be a comma-separated list of cell barcodes
	  - "sample_1-ACCCGGGTTT-1"
	  - None
	* - num_cpu
	  - Number of cpus per scCloud job
	  - 32
	  - 64
	* - memory
	  - Memory size string
	  - "200G"
	  - "200G"
	* - disk_space
	  - Total disk space
	  - 100
	  - 100
	* - preemptible
	  - Number of preemptible tries
	  - 2
	  - 2

scCloud_subcluster's outputs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
	:widths: 5 5 20
	:header-rows: 1

	* - Name
	  - Type
	  - Description
	* - **output_h5ad**
	  - File
	  - h5ad-formatted HDF5 file containing all results (output_name.h5ad). If de_analysis is on, this file should be the same as *output_de_h5ad*
	* - output_loom_file
	  - File
	  - Outputted loom file (output_name.loom)
	* - output_parquet_file
	  - File
	  - Outputted PARQUET file that contains metadata and expression levels for every gene
	* - output_de_h5ad
	  - File
	  - h5ad-formatted results with DE results updated (output_name.h5ad)
	* - output_de_xlsx
	  - File
	  - Spreadsheet reporting DE results (output_name.de.xlsx)
	* - output_pdfs
	  - Array[File]
	  - Outputted pdf files
	* - output_htmls
	  - Array[File]
	  - Outputted html files

---------------------------------

Load ``scCloud`` results into ``Seurat``  
-----------------------------------------

First, you need to set ``make_output_seurat_compatible`` to ``true`` in ``scCloud`` to make sure ``output_name.h5ad`` is Seurat-compatible.
Please note that python, the `anndata`_ python library, and the reticulate R library are required to load the result into Seurat.

Execute the R code below to load the results into ``Seurat`` version 2::

	library(Seurat)
	library(reticulate)
	source("https://raw.githubusercontent.com/klarman-cell-observatory/KCO/master/workflows/scCloud/h5ad2seurat.R")
	ad <- import("anndata", convert = FALSE)
	test_ad <- ad$read_h5ad("output_name.seurat.h5ad")
	test <- Convert.anndata.base.AnnData(test_ad, to = "seurat")

The resulting seurat object will have three data slots. *raw.data* records filtered raw count matrix. *data* records filtered and log-normalized expression matrix. *scale.data* records variable-gene-selected, standardized expression matrix that are ready to perform PCA.

---------------------------------

Visualize ``scCloud`` results in Python
----------------------------------------

Ensure you have **scCloud** installed.

Load the output::

	import scCloud
	adata = scCloud.tools.read_input("output_name.h5ad")

Violin plot of the computed quality measures::

	scCloud.plotting.plot_qc_violin(adata, 'gene', 'output_name.gene.qc.pdf')
	scCloud.plotting.plot_qc_violin(adata, 'count', 'output_name.count.qc.pdf')
	scCloud.plotting.plot_qc_violin(adata, 'mito', 'output_name.mito.qc.pdf')

tSNE colored by louvain cluster labels and channel::

	fig = scCloud.plotting.plot_scatter(adata, 'tsne', ['louvain_labels', 'Channel'])
	fig.savefig('output_file.pdf', dpi = 500)

UMAP colored by genes of interest::

	fig = scCloud.plotting.plot_scatter_genes(adata, 'umap', ['CD4', 'CD8A'])
	fig.savefig('output_file.pdf', dpi = 500)


.. _anndata: https://anndata.readthedocs.io/en/latest/
