process tmhmm {

    publishDir "$params.outdir/tmhmm", mode: 'copy'

    input:
    path fasta

    output:
    path "*.tmhmm.out"


    script:
    def prefix=${fasta.baseName}
    """
    tmhmm --short < ${fasta} > ${prefix}.tmhmm.out
    """
}

