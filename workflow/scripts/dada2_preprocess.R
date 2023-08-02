library(dada2)

F27 <- "AGAGTTTGATCMTGGCTCAG"
R1492 <- "TACCTTGTTACGACTT"

# get argument values
input_dir <- commandArgs(trailingOnly = TRUE)[1]
silva_db <- commandArgs(trailingOnly = TRUE)[2]
output_dir <- commandArgs(trailingOnly = TRUE)[3]

# get fastq paths from input directory
fastq_paths <- list.files(input_dir, pattern = ".fastq$", full.names = TRUE)


# remove primers
no_primers_paths <- file.path(output_dir, "no_primers", basename(fastq_paths))
no_primers <- removePrimers(fastq_paths, no_primers_paths, primer.fwd = F27, primer.rev = dada2:::rc(R1492), orient = TRUE)

# filter and trim
filtered_paths <- file.path(output_dir, "filtered", basename(fastq_paths))
filtered <- filterAndTrim(no_primers_paths, filtered_paths, minQ=3, minLen=1000, maxLen=1600, maxN=0, rm.phix=FALSE, maxEE=2)

# dereplicate
dereplicated <- derepFastq(filtered_paths)

# learn error rates
error_rates <- learnErrors(dereplicated, errorEstimationFunction=PacBioErrfun, BAND_SIZE=32, multithread=TRUE)

# denoise
denoised <- dada(dereplicated, error_rates, BAND_SIZE = 32, multithread=TRUE)

# make sequence table
sequence_table <- makeSequenceTable(denoised)

# assign taxonomies to silva database
taxonomy <- assignTaxonomy(sequence_table, silva_db, multithread=TRUE)

# save all the objects
save(no_primers, filtered, dereplicated, error_rates, denoised, sequence_table, taxonomy, file = file.path(output_dir, "dada2.RData"))