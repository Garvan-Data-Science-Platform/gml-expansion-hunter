version 1.0

# ================================== #
#          Expansion Hunter          #
# ================================== #

# This workflow is designed to run ExpansionHunter via a Cromwell server

workflow ExpansionHunter {
    input {
        File reads
        File reads_index
        File ref_fasta
        File ref_fai
        File ref_dict
        String eh_regions
        String sex_param

        # Runtime options
        String docker
        Int preemptible = 2
        Int max_retries = 2
        Int cpu = 16
        Int mem = 10
        Int mem_padding = 1
        Int disk = 100
        Int boot_disk_size = 12
    }

    call ExpansionHunterTask {
        input:
            reads = reads,
            reads_index = reads_index,
            Runtime = Runtime,
            docker = docker,
            preemptible = preemptible,
            max_retries = max_retries,
            cpu = cpu,
            mem = mem,
            mem_padding = mem_padding,
            disk = disk,
            boot_disk_size = boot_disk_size
    }


    output {
        File eh_output = ExpansionHunterTask.eh_output
    }
}

task ExpansionHunterTask {
    input {
        File reads
        File reads_index
        File ref_fasta
        File ref_fai
        File ref_dict
        String eh_regions
        String sex_param

        # Runtime options
        String docker
        Int preemptible = 2
        Int max_retries = 2
        Int cpu = 16
        Int mem = 10
        Int mem_padding = 1
        Int disk = 100
        Int boot_disk_size = 12
    }

    Int command_mem = (mem - mem_padding) * 1000
    String prefix = "eh"

    command <<<
        ExpansionHunter  \
            --reads ~{reads} \
            --reference ~{ref_fasta} \
            --variant-catalog ~{eh_regions}\
            --threads ~{cpu} \
            --analysis-mode streaming \
            --output-prefix ~{prefix} \
            --sex ~{sex_param}
    >>>

    output {
        File eh_output = "eh"
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: mem + " GB"
        disks: "local-disk " + disk + " HDD"
        preemptible: preemptible
        maxRetries: max_retries
        bootDiskSizeGb: boot_disk_size
    }
}
