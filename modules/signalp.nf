process signalp {

    publishDir "$params.outdir/signalp", mode: 'copy'

    input:
    path fasta

    output:
    path "*.signalp.out"


    script:
    def prefix="${fasta.baseName}"
    """
    signalp -f short -n ${prefix}.signalp.out ${fasta}
    """
}

