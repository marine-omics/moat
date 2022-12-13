process split_fasta {

  input:
    path(fasta)
    val(max_size)

  output:
    path "*.fa", emit: report

  script:
  """
  cat ${fasta} | bioawk -c 'fastx' -v species_in=${fasta.baseName} -v nrec=${max_size} -f /usr/local/bin/split_fasta.awk
  
  """
}
