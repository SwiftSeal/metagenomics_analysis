library(tidyverse)
library(phyloseq)
library(vegan)

# read directory path from args
args <- commandArgs(trailingOnly = TRUE)

emu_directory <- args[1]

emu_files <- list.files(path = emu_directory, pattern = "*_rel-abundance-threshold-0.0001.tsv", full.names = TRUE)

# aggregate data into single dataframe
emu_data <- map_dfr(emu_files, ~read_tsv(.x) %>% mutate(sample = .x)) %>%
  mutate(sample = str_remove(sample, "_rel-abundance-threshold-0.0001.tsv")) %>%
  mutate(sample = str_remove(sample, emu_directory)) %>%
  rename_with(~str_replace_all(., " ", "_")) %>%
  mutate(tax_id = paste0("t", tax_id))

# save data
write_tsv(emu_data, "results/emu-data.tsv")

# construct OTU table
emu_otu <- emu_data %>%
  select(!(abundance:species_group)) %>%
  mutate(estimated_counts = round(estimated_counts, 0)) %>%
  pivot_wider(names_from = sample, values_from = estimated_counts) %>%
  column_to_rownames("tax_id") %>%
  replace(is.na(.), 0) %>%
  otu_table(taxa_are_rows = TRUE)

# construct taxonomy table
emu_tax <- emu_data %>%
  select(tax_id, species:phylum) %>%
  distinct() %>%
  column_to_rownames("tax_id")

# default matrix conversion breaks so this is a workaround
emu_tax <- tax_table(as.matrix(emu_tax))

# construct phyloseq object
emu_phyloseq = phyloseq(emu_otu, emu_tax)
saveRDS(emu_phyloseq, "results/emu-phyloseq.rds")

# plot top 10 most abundant genus
top_10_names <- names(sort(taxa_sums(emu_phyloseq), decreasing = TRUE)[1:10])
top_10 <- prune_taxa(top_10_names, emu_phyloseq)
top_10_plot <- plot_bar(top_10, fill = "genus")
ggsave("results/top-10-OTUs.png", top_10_plot, width = 6, height = 4, units = "in", dpi = 300)

# plot rarefaction curve
# S4 object conversion breaks so this is a workaround
tab <- t(otu_table(emu_phyloseq))
class(tab) <- "matrix"

png("results/rarefaction-curve.png", width = 6, height = 4, units = "in", res = 300)
rarecurve(tab, step = 50)
dev.off()
