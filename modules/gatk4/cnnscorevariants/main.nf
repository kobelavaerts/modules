process GATK4_CNNSCOREVARIANTS {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::gatk4=4.2.6.1" : null)
    container 'broadinstitute/gatk:4.2.6.1'

    input:
    tuple val(meta), path(vcf), path(aligned_input), path(intervals)
    path fasta
    path fai
    path dict
    path architecture
    path weights

    output:
    tuple val(meta), path("*.vcf.gz"), emit: vcf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def aligned_input = aligned_input ? "--input $aligned_input" : ""
    def interval_command = intervals ? "--intervals $intervals" : ""
    def architecture = architecture ? "--architecture $architecture" : ""
    def weights = weights ? "--weights $weights" : ""

    def avail_mem = 3
    if (!task.memory) {
        log.info '[GATK CnnScoreVariants] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
    } else {
        avail_mem = task.memory.giga
    }
    """
    gatk --java-options "-Xmx${avail_mem}g" CNNScoreVariants \\
        --variant $vcf \\
        --output ${prefix}.vcf.gz \\
        --reference $fasta \\
        $interval_command \\
        $aligned_input \\
        $architecture \\
        $weights \\
        --tmp-dir . \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}
