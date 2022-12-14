nextflow.enable.dsl=2

include { blastp;blastx } from './modules/blast.nf'
include { interproscan;cat_ipr } from './modules/interproscan.nf'
include { split_fasta } from './modules/fasta.nf'
include { signalp } from './modules/signalp.nf'
include { tmhmm } from './modules/tmhmm.nf'
include { hmmscan } from './modules/hmmer.nf'
include { make_table } from './modules/r_tabulate.nf'

params.blastdb=null
params.pfamdb=null
params.prot=null
params.cds=null
params.skip_interproscan=false
params.split_max=1000
params.blast_eval=0.00001

if(!params.outdir){
  log.error "No outdir provided. Provide one with --outdir myoutdir"
  exit 1
}

workflow {

  prot = Channel.fromPath(file(params.prot, checkIfExists:true)) | collect

  if (!params.blastdb){
    log.error("No blast database provided. Provide one via the blastdb parameter")
  }
  blastdb = Channel.fromPath(file("${params.blastdb}.*", checkIfExists:true)) | collect

  
  blastp_result = blastp(prot,blastdb)
  signalp_result = signalp(prot)
  tmhmm_result = tmhmm(prot)

  ch_all_results = blastp_result.mix(signalp_result,tmhmm_result)

  if(params.cds ){
    cds = Channel.fromPath(file(params.cds, checkIfExists:true)) | collect
    blastx_result = blastx(cds,blastdb)
    ch_all_results = ch_all_results.mix(blastx_result)
  } else {
    log.warn("No cds or prot2cds_map provided. Skipping blastx")    
  }

  if(params.pfamdb){
    pfamdb = Channel.fromPath(file("${params.pfamdb}.*")) | collect
    hmmscan_result = hmmscan(prot,pfamdb)
    ch_all_results = ch_all_results.mix(hmmscan_result)
  } else {
    log.warn("No Pfam database provided. Skipping hmmscan")
  }

  if(!params.skip_interproscan){
    ch_sf = split_fasta(prot,params.split_max)

    ipr_result = ch_sf | flatten | interproscan | collect | cat_ipr
    ch_all_results = ch_all_results.mix(ipr_result)
  } else {
   log.warn("Skipping interproscan") 
  }

  all_results = ch_all_results | collect
  all_results.view()

  make_table(all_results,params.blast_eval,"${projectDir}/R/tabulate.R")

}


