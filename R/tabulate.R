library(tidyverse)

## Functions
concat_terms <- function(terms){
  ut <- unique(terms)
  ut <- ut[!is.na(ut)]
  paste(ut,collapse = ";")
}
##


args <- commandArgs(trailingOnly=TRUE)


report_dir <- args[1]

bleval <- as.numeric(args[2]) 

bl6_cols <- c("qaccver","saccver","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore")


bpfile <- list.files(report_dir,"*.blastp.outfmt6",full.names = T)

blastp <- read_tsv(bpfile,col_names = bl6_cols,show_col_types = FALSE) %>% 
  select(id = qaccver, evalue,saccver) %>% add_column(method = "blastp")


bxfile <- list.files(report_dir,"*.blastx.outfmt6",full.names = T)
if ( length(bxfile) == 1){

	blastx <- read_tsv(bxfile,col_names = bl6_cols,show_col_types = FALSE)  %>% 
  		select(id = qaccver, evalue,saccver) %>% add_column(method = "blastx")
  	blast <- rbind(blastp, blastx) %>% 
	  group_by(id) %>% 
  		slice_min(evalue,n=1,with_ties = FALSE)
} else {
  	blast <- blastp %>% 
	  group_by(id) %>% 
  		slice_min(evalue,n=1,with_ties = FALSE)
}

full_table <- blast %>% 
  filter(evalue < bleval) %>% 
  rename(Swissprot_acc=saccver)



iprfile <- list.files(report_dir,"interproscan.tsv",full.names = T)
if ( length(iprfile) == 1){

	iprscan <- read_tsv(iprfile,col_names = TRUE,show_col_types = FALSE, na = c("","-"))
	iprscan_golong <- iprscan %>% 
	  separate_rows(goterm, sep ="\\|")

	ipr_summary <- iprscan_golong %>% 
	  group_by(id,analysis) %>% 
	  summarise(sig_acc=concat_terms(sig_acc), sig_desc=concat_terms(sig_desc), ipr_acc = concat_terms(ipr_acc),ipr_desc = concat_terms(ipr_desc), ipr_go = concat_terms(goterm))

	write_tsv(ipr_summary,"interproscan_summary.tsv")

	pfam_w <- ipr_summary %>% 
	  filter(analysis %in% c("Pfam")) %>% 
	  select(-ipr_desc,-ipr_acc) %>% 
	  pivot_wider(names_from = analysis, values_from = c(sig_desc,sig_acc)) 

	superfam_w <- ipr_summary %>% 
	  filter(analysis %in% c("SUPERFAMILY")) %>% 
	  select(-ipr_desc,-ipr_acc,-ipr_go) %>% 
	  pivot_wider(names_from = analysis, values_from = c(sig_desc,sig_acc))

	ipr_slim <- pfam_w %>% 
	  left_join(superfam_w) %>% 
	  rename(Pfam_desc=sig_desc_Pfam,Pfam_acc=sig_acc_Pfam,SUPERFAMILY_desc=sig_desc_SUPERFAMILY,SUPERFAMILY_acc=sig_acc_SUPERFAMILY)

	full_table <- full_table %>%
		full_join(ipr_slim,by="id") 
}


spfile <- list.files(report_dir,"*signalp.out",full.names = T)

signalp <- read_tsv(spfile,comment = "#",col_names = c("id","source","feature","start","end","score","n","a","class"),show_col_types = FALSE) %>% 
  select(id,signal_peptide=class)

tmhmm_file <- list.files(report_dir,"*tmhmm.out",full.names = T)

tmhmm <- read_tsv(tmhmm_file,comment = "#",col_names = c("id","len","ExpAA","First60","PredHel","Topology"),show_col_types = FALSE) %>% 
  tidyr::extract(Topology,into = "tmhmm_topology",regex = "Topology=(.*)") %>% 
  select(id,tmhmm_topology)

full_table <- full_table %>% 
  full_join(signalp,by="id") %>% 
  full_join(tmhmm)

write_tsv(full_table,"annotation.tsv")

