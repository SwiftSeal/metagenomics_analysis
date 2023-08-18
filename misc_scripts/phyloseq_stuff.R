library(phyloseq)
library(vegan)
library(tidyverse)

emu_directory <- "emu"


emu_files <- list.files(path = emu_directory, pattern = "*_rel-abundance-threshold-0.0001.tsv", full.names = TRUE)

emu_data <- map_dfr(emu_files, ~read_tsv(.x) %>% mutate(sample = .x)) %>%
    mutate(sample = str_remove(sample, "_rel-abundance-threshold-0.0001.tsv")) %>%
    mutate(sample = str_remove(sample, emu_directory)) %>%
    mutate(sample = str_remove(sample, "/")) %>%
    separate_wider_delim(lineage, names = c("domain", "phylum", "class", "order", "family", "genus", "species"), delim = ";", too_few = "align_start", too_many = "drop") %>%
    mutate(across(domain:species, ~ifelse(. == "", NA, .))) %>%
    #preappend "t" to tax_id
    mutate(tax_id = paste0("t", tax_id))

# get taxonomy table
emu_taxonomy <- emu_data %>%
    select(tax_id, domain:species) %>%
    distinct() %>%
    column_to_rownames("tax_id")

# get abundance table
emu_abundance <- emu_data %>%
    select(tax_id, sample, abundance) %>%
    pivot_wider(names_from = sample, values_from = abundance) %>%
    replace(is.na(.), 0) %>%
    column_to_rownames("tax_id")

otu <- otu_table(emu_abundance, taxa_are_rows = TRUE)
tax <- tax_table(as.matrix(emu_taxonomy))

# convert to phyloseq object
emu_phyloseq <- phyloseq(otu, tax)

plot_bar(emu_phyloseq, fill = "phylum")

plot_richness(emu_phyloseq, measures = c("Shannon", "Simpson"))
