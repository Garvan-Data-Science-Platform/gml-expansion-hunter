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
        String eh_regions  # JSON
        String sex = "female"
        String sample_id

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
            ref_fasta = ref_fasta,
            ref_fai = ref_fai,
            eh_regions = eh_regions,
            sex = sex,
            sample_id = sample_id,
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
        File output_vcf = ExpansionHunterTask.vcf
        File output_json = ExpansionHunterTask.json
        File output_realigned_bam = ExpansionHunterTask.realigned_bam
    }
}

task ExpansionHunterTask {
    input {
        File reads
        File reads_index
        File ref_fasta
        File ref_fai
        String eh_regions
        String sex = "female"
        String sample_id

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
    String prefix = "output/~{sample_id}"
    String sex_param = if (sex == "M" || sex == "m" || sex == "Male" || sex == "male" || sex == "MALE") then "male" else "female"

    command <<<
        mkdir output

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
        File vcf = "output/~{sample_id}.vcf"
        File json = "output/~{sample_id}.json"
        File realigned_bam = "output/~{sample_id}_realigned.bam"
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
