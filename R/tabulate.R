library(tidyverse)

df <- data.frame(x=c("a","b"),y=c(1,2))
write_tsv(df,"annotations.tsv")
