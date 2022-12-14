process interproscan {

    input:
        path(prots)

    output:
        path('*.tsv')           , emit: tsv

    script:

    def args = task.ext.args ?: ''
    """
    interproscan.sh -i ${prots}  --disable-precalc -f tsv -goterms -cpu ${task.cpus}
    """
}

process cat_ipr {

    publishDir "$params.outdir/ipr", mode: 'copy'


  input:
    path(inputs)

  output:
    path "interproscan.tsv"

  script:
  """
  cat ${inputs} > "interproscan.tsv" 
  """
}
