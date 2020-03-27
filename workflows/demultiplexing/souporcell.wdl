version 1.0

workflow souporcell {
    input {
        String sample_id
        String output_directory
        String input_rna
        String input_tag_file
        String genome_url
        String input_genotype
        Int min_num_genes
        Int num_clusters
        String donor_rename = ''
        String souporcell_version = "2020.03"

        String docker_registry = "cumulusprod"
        Int num_cpu = 32
        Int disk_space = 500
        Int memory = 120
        Int preemptible = 2
        String zones = "us-central1-a us-central1-b us-central1-c us-central1-f us-east1-b us-east1-c us-east1-d us-west1-a us-west1-b us-west1-c"
    }

    call run_souporcell {
        input:
            sample_id = sample_id,
            output_directory = output_directory,
            input_rna = input_rna,
            input_tag_file = input_tag_file,
            genome = genome_url,
            input_genotype = input_genotype,
            min_num_genes = min_num_genes,
            num_clusters = num_clusters,
            donor_rename = donor_rename,
            souporcell_version = souporcell_version,
            docker_registry = docker_registry,
            num_cpu = num_cpu,
            disk_space = disk_space,
            memory = memory,
            preemptible = preemptible,
            zones = zones
    }

    output {
        String output_folder = "~{output_directory}"
        File output_zarr = run_souporcell.output_zarr
    }

}

task run_souporcell {
    input {
        String sample_id
        String output_directory
        File input_rna
        File input_tag_file
        File genome
        File input_genotype
        Int min_num_genes
        Int num_clusters
        String donor_rename
        String souporcell_version

        String docker_registry
        Int num_cpu
        Int disk_space
        Int memory
        Int preemptible
        String zones
    }

    command {
        set -e
        export TMPDIR=/tmp
        monitor_script.sh > monitoring.log &

        mkdir genome_ref
        tar -zxf "~{genome}" -C genome_ref --strip-components 1
        rm "~{genome}"

        mkdir result
        python /opt/extract_barcodes_for_souporcell.py ~{input_rna} result/~{sample_id}.barcodes.tsv ~{min_num_genes}
        souporcell_pipeline.py -i ~{input_tag_file} -b result/~{sample_id}.barcodes.tsv -f genome_ref/fasta/genome.fa -t ~{num_cpu} -o result -k ~{num_clusters}

        python <<CODE
        from subprocess import check_call

        call_args = ['python', '/opt/match_donors.py']
        if donor_rename is not '':
            call_args.extend(['--donor-names', '${donor_rename}'])

        call_args.append('result/cluster_genotypes.vcf')

        if '~{input_genotype}' is not 'null':
            call_args.append('~{input_genotype}')

        call_args.extend(['result/clusters.tsv', '~{input_rna}', 'result/~{sample_id}_demux.zarr'])

        print(' '.join(call_args))
        check_call(call_args, stdout = 'result/match_donors.log')
        CODE

        mkdir buffer
        cp result/match_donors.log buffer
        cp result/~{sample_id}_demux.zarr buffer
        cp result/clusters.tsv buffer
        gsutil -q -m rsync -r buffer ~{output_directory}/~{sample_id}
        # mkdir -p ~{output_directory}/~{sample_id}
        # cp -r buffer/* ~{output_directory}/~{sample_id}
    }

    output {
        String output_folder = "~{output_directory}/~{sample_id}"
        File output_zarr = "~{output_directory}/~{sample_id}/~{sample_id}_demux.zarr"
    }

    runtime {
        docker: "~{docker_registry}/souporcell:~{souporcell_version}"
        zones: zones
        memory: "~{memory}G"
        disks: "local-disk ~{disk_space} HDD"
        cpu: "~{num_cpu}"
        preemptible: "~{preemptible}"
    }
}