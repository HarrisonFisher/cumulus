Version 1.5.1 `September 15, 2021`
------------------------------------

* Fix the issue of WDLs after Terra platform updates the Cromwell engine.

Version 1.5.0 `July 20, 2021`
------------------------------

* On *demultiplexing* workflow
    * Update *demuxEM* to v0.1.6.
* On *cumulus* workflow
    * Add Nonnegative Matrix Factorization (NMF) feature: ``run_nmf`` and ``nmf_n`` inputs.
    * Add integrative NMF (iNMF) data integration method: ``inmf`` option in ``correction_method`` input; the number of expected factors is also specified by ``nmf_n`` input.
    * When NMF or iNMF is enabled, word cloud plots and gene program UMAP plots of NMF/iNMF results will be generated.
    * Update *Pegasus* to v1.4.2.

Version 1.4.0 `May 17, 2021`
----------------------------

* On *cellranger* workflow
    * Add support for multiomics analysis using linked samples, *cellranger-arc count*, *cellranger multi* and *cellranger count* will be automatically triggered based on the sample sheet
    * Add support for cellranger version 6.0.1 and 6.0.0
    * Add support for cellranger-arc version 2.0.0, 1.0.1, 1.0.0
    * Add support for cellranger-atac version 2.0.0
    * Add support for cumulus_feature_barcoding version 0.6.0, which handles CellPlex CMO tags
    * Add *GRCh38-2020-A_arc_v2.0.0*, *mm10-2020-A_arc_v2.0.0*, *GRCh38-2020-A_arc_v1.0.0* and *mm10-2020-A_arc_v1.0.0* references for *cellranger-arc*.
    * Fixed bugs in cellranger_atac_create_reference
    * Add delete undetermined FASTQs option for mkfastq
* On *demultiplexing* workflow
    * Replace *demuxlet* with *popscle*, which includes both *demuxlet* and *freemuxlet*
* On *cumulus* workflow
    * Fixed bug that ``remap_singlets`` and ``subset_singlets`` don't work when input is in sample sheet format.
* Modified workflows to remove trailing spaces and support spaces within output_directory

Version 1.3.0 `February 2, 2021`
--------------------------------

* On *cumulus* workflow:
    * Change ``cumulus_version`` to ``pegasus_version`` to avoid confusion.
    * Update to use Pegasus v1.3.0 for analysis.

Version 1.2.0 `January 19, 2021`
--------------------------------

* Add *spaceranger* workflow:
    * Wrap up spaceranger version 1.2.1
* On *cellranger* workflow:
    * Fix workflow WDL to support both single index and dual index
    * Add support for cellranger version 5.0.1 and 5.0.0
    * Add support for targeted gene expression analysis
    * Add support for ``--include-introns`` and ``--no-bam`` options for cellranger count
    * Remove ``--force-cells`` option for cellranger vdj as noted in cellranger 5.0.0 release note
    * Add *GRCh38_vdj_v5.0.0* and *GRCm38_vdj_v5.0.0* references
* Bug fix on *cumulus* workflow.
* Reorganize the sidebar of Cumulus documentation website.

Version 1.1.0 `December 28, 2020`
---------------------------------

* On *cumulus* workflow:
    * Add CITE-Seq data analysis back. (See section `Run CITE-Seq analysis <./cumulus.html#run-cite-seq-analysis>`_ for details)
    * Add doublet detection. (See ``infer_doublets``, ``expected_doublet_rate``, and ``doublet_cluster_attribute`` input fields)
    * For tSNE visualization, only support FIt-SNE algorithm. (see ``run_tsne`` and ``plot_tsne`` input fields)
    * Improve efficiency on log-normalization and DE tests.
    * Support multiple marker JSON files used in cell type annotation. (see ``organism`` input field)
    * More preset gene sets provided in gene score calculation. (see ``calc_signature_scores`` input field)
* Add *star_solo* workflow (see `STARsolo section <./starsolo.html>`_ for details):
    * Use `STARsolo <https://github.com/alexdobin/STAR/blob/master/docs/STARsolo.md>`_ to generate count matrices from FASTQ files.
    * Support chemistry protocols such as 10X-V3, 10X-V2, DropSeq, and SeqWell.
* Update the example of analyzing hashing and CITE-Seq data (see `Example section <./examples/example_hashing_citeseq.html>`_) with the new workflows.
* Bug fix.

Version 1.0.0 `September 23, 2020`
----------------------------------

* Add *demultiplexing* workflow for cell-hashing/nucleus-hashing/genetic-pooling analysis.
* Add support on CellRanger version ``4.0.0``.
* Update *cumulus* workflow with Pegasus version ``1.0.0``:
    * Use ``zarr`` file format to handle data, which has a better I/O performance in general.
    * Support focus analysis on Unimodal data, and appending other Unimodal data to it. (``focus`` and ``append`` inputs in *cluster* step).
    * Quality-Control: Change ``percent_mito`` default from ``10.0`` to ``20.0``; by default remove bounds on UMIs (``min_umis`` and ``max_umis`` inputs in *cluster* step).
    * Quality-Control: Automatically figure out name prefix of mitochondrial genes for ``GRCh38`` and ``mm10`` genome reference data.
    * Support signature / gene module score calculation. (``calc_signature_scores`` input in *cluster* step)
    * Add *Scanorama* method to batch correction. (``correction_method`` input in *cluster* step).
    * Calculate UMAP embedding by default, instead of FIt-SNE.
    * Differential Expression (DE) analysis: remove inputs ``mwu`` and ``auc`` as they are calculated by default. And cell-type annotation uses MWU test result by default.
* Remove *cumulus_subcluster* workflow.

Version 0.15.0 `May 6, 2020`
----------------------------

* Update all workflows to OpenWDL version 1.0.
* Cumulus now supports multi-job execution from Terra data table input.
* Cumulus generates Cirrocumulus input in ``.cirro`` folder, instead of a huge ``.parquet`` file.

Version 0.14.0 `February 28, 2020`
----------------------------------

* Added support for gene-count matrices generation using alternative tools (STARsolo, Optimus, Salmon alevin, Kallisto BUStools).
* Cumulus can process demultiplexed data with remapped singlets names and subset of singlets.
* Update VDJ related inputs in Cellranger workflow.
* SMART-Seq2 and Count workflows are in OpenWDL version 1.0.

Version 0.13.0 `February 7, 2020`
---------------------------------

* Added support for aggregating scATAC-seq samples.
* Cumulus now accepts mtx format input.

Version 0.12.0 `December 14, 2019`
----------------------------------

* Added support for building references for sc/snRNA-seq, scATAC-seq, single-cell immune profiling, and SMART-Seq2 data.

Version 0.11.0 `December 4, 2019`
---------------------------------

* Reorganized Cumulus documentation.

Version 0.10.0 `October 2, 2019`
--------------------------------

* scCloud is renamed to Cumulus.
* Cumulus can accept either a sample sheet or a single file.

Version 0.7.0 `Feburary 14, 2019`
---------------------------------

* Added support for 10x genomics scATAC assays.
* scCloud runs FIt-SNE as default.

Version 0.6.0 `January 31, 2019`
--------------------------------

* Added support for 10x genomics V3 chemistry.
* Added support for extracting feature matrix for Perturb-Seq data.
* Added R script to convert output_name.seurat.h5ad to Seurat object. Now the raw.data slot stores filtered raw counts.
* Added min_umis and max_umis to filter cells based on UMI counts.
* Added QC plots and improved filtration spreadsheet.
* Added support for plotting UMAP and FLE.
* Now users can upload their JSON file to annotate cell types.
* Improved documentation.
* Added lightGBM based marker detection.

Version 0.5.0 `November 18, 2018`
---------------------------------

* Added support for plated-based SMART-Seq2 scRNA-Seq data.

Version 0.4.0 `October 26, 2018`
--------------------------------

* Added CITE-Seq module for analyzing CITE-Seq data.

Version 0.3.0 `October 24, 2018`
--------------------------------

* Added the demuxEM module for demultiplexing cell-hashing/nuclei-hashing data.

Version 0.2.0 `October 19, 2018`
--------------------------------

* Added support for V(D)J and CITE-Seq/cell-hashing/nuclei-hashing.

Version 0.1.0 `July 27, 2018`
-----------------------------

* KCO tools released!
