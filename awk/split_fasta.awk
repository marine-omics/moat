{ 
	if( (NR-1)%nrec==0 ){
		file=sprintf("%s%d.fa",species_in,(NR-1));
	} 
	printf(">%s\t%s\n%s\n",$name,$comment,$seq) >> file
}