process hmmscan {

  publishDir "$params.outdir/pfam", mode: 'copy'

  input:
    path(query)
    path(db)

  output:
    path("*.pfam.out"), emit:ref
    path("pfam.log"), emit:log

  script:
  def dbname = "${db[0].baseName}"
  def prefix = ${query.baseName}
  """
  hmmscan --cpu ${task.cpus} --domtblout ${prefix}.pfam.out ${db} ${query} > pfam.log
  """
}