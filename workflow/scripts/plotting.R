library(tidyverse)

# read directory path from args
args <- commandArgs(trailingOnly = TRUE)

emu_directory <- args[1]

emu_files <- list.files(path = emu_directory, pattern = "*_rel-abundance-threshold-0.0001.tsv", full.names = TRUE)

# aggregate data into single dataframe
emu_data <- map_dfr(emu_files, ~read_tsv(.x) %>% mutate(sample = .x)) %>%
    mutate(sample = str_remove(sample, "_rel-abundance-threshold-0.0001.tsv")) %>%
    mutate(sample str_remove(sample, emu_directory)) %>%
    separate_wider_delim(lineage, names = c("domain", "phylum", "class", "order", "family", "genus", "species"), delim = ";", too_few = "align_start", too_many = "drop")

# save data
write_tsv(emu_data, "results/emu-data.tsv")

# get top 10 genera
top_genera <- emu_data %>%
    filter(genus != "") %>%
    group_by(sample, genus) %>%
    summarise(rel_abundance = sum(abundance)) %>%
    group_by(sample) %>%
    slice_max(rel_abundance, n = 10) %>%
    ggplot(aes(y = sample, x = rel_abundance, fill = genus)) +
    geom_col(position = "stack") +
    scale_x_continuous(labels = scales::percent) +
    labs(x = "Relative abundance", y = "Sample", fill = "Genus")

ggsave("results/top-10-genera.pdf", top_genera, width = 8, height = 4, units = "in")