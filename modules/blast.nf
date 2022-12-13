process blastp {

  publishDir "$params.outdir/blast", mode: 'copy'

  input:
    path(query)
    path(db)

  output:
    path("*.outfmt6"), emit:ref

  script:
  def dbname = "${db[0].baseName}"
  """
  blastp -query ${query} -db ${dbname} -num_threads ${task.cpus} -max_target_seqs 5 -outfmt 6 > ${query.baseName}.blastp.outfmt6
  """
}

process blastx {

  publishDir "$params.outdir/blast", mode: 'copy'

  input:
    path(query)
    path(db)

  output:
    path("*.outfmt6"), emit:ref

  script:
  def dbname = "${db[0].baseName}"
  """
  blastx -query ${query} -db ${dbname} -num_threads ${task.cpus} -max_target_seqs 5 -outfmt 6 > ${query.baseName}.blastx.outfmt6
  """
}
