process make_table {

    label 'tidyverse'

    publishDir "$params.outdir/final_table", mode: 'copy'

    input:
        path(result_files)
        val(blast_eval)
        path 'tabulate.R'

    output:
        path('*.tsv')           , emit: tsv

    script:

    def args = task.ext.args ?: ''
    """
    Rscript tabulate.R . ${blast_eval}
    """
}
