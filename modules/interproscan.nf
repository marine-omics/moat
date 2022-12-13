process interproscan {

    publishDir "$params.outdir/ipr", mode: 'copy'

    input:
        path(prots)

    output:
        path('*.tsv')           , emit: tsv
        path('*.gff3')           , emit: gff3
        path('*.log')            , emit: log

    script:

    def args = task.ext.args ?: ''
    """
    interproscan.sh -i ${prots}  --disable-precalc
    """
}

