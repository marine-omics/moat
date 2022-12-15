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
  echo "id,md5,length,analysis,sig_acc,sig_desc,start,end,score,status, date,ipr_acc,ipr_desc,goterm" | tr "," '\t' > interproscan.tsv

  cat ${inputs} >> "interproscan.tsv" 
  """
}
