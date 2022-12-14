process interproscan {

    publishDir "$params.outdir/ipr", mode: 'copy'

    input:
        path(prots)

    output:
        path('*.tsv')           , emit: tsv

    script:

    def args = task.ext.args ?: ''
    """
    interproscan.sh -i ${prots}  --disable-precalc
    """
}

process cat_ipr {

  input:
    path(inputs)

  output:
    path "interproscan.tsv"

  script:
  """
  cat ${inputs} > "interproscan.tsv" 
  """
}
