nextflow.enable.dsl=2

include { blastp;blastx } from './modules/blast.nf'
include { interproscan } from './modules/interproscan.nf'
include { split_fasta } from './modules/fasta.nf'
include { signalp } from './modules/signalp.nf'
include { tmhmm } from './modules/tmhmm.nf'
include { hmmscan } from './modules/hmmer.nf'

params.blastdb=null
params.pfamdb=null
params.prot=null
params.cds=null
params.skip_interproscan=false
params.split_max=1000

if(!params.outdir){
  log.error "No outdir provided. Provide one with --outdir myoutdir"
  exit 1
}

workflow {

  prot = Channel.fromPath(file(params.prot, checkIfExists:true)) | collect
  cds = Channel.fromPath(file(params.cds, checkIfExists:true)) | collect
  blastdb = Channel.fromPath(file("${params.blastdb}.*")) | collect
  pfamdb = Channel.fromPath(params.pfamdb, checkIfExists:true)) | collect

  
  blastp_result = blastp(prot,blastdb)
  blastx_result = blastx(prot,blastdb)
  signalp_result = signalp(prot)
  tmhmm_result = tmhmm(prot)
  hmmscan_result = hmmscan(prot,pfamdb)

  if(!params.skip_interproscan){
    ipr_result = split_fasta(prot,params.split_max) | interproscan
  }

}

