setwd("/scratch/aleu1/BC/out")
library(GenomicAlignments)
library(dplyr)
library(stringr)


args <- commandArgs(TRUE)
print(args)

file <- paste(args,"sort.bam",sep="_")



 stack <- stackStringsFromBam(file,
                               param=GRanges("Reference_barcode:73-97"),
                               use.names = TRUE,
                               what = "seq")
 data <- stack %>%
    as.data.frame() %>%
    dplyr::rename(barcode=x) %>%
    group_by(barcode) %>%
    dplyr::count() %>%
    arrange(desc(n)) %>%
    dplyr::rename(counts=n) %>%
    mutate(length_barcode=str_length(barcode))

 write.table(data,file=paste(args,"barcode.txt",sep="_"),append=FALSE,quote=FALSE, sep=",") # it writes in your working directory txt files with the baroceds





