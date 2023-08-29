library(phyloseq)
library(tidyverse)

emu <- readRDS("results/emu-phyloseq.rds")
dada2 <- readRDS("JH33_dada2_trimmed_silva_138.1_2.rds")

# add sample data to emu
emu_samples <- data.frame(
    SampleID = c("1.EO-WET", "2.EO-WET", "20.EO-DRYWET", "4.EO-WET", "26.EO", "30.EO"),
    Description = c("Barke", "Barke", "Barke", "Barke", "Bulk", "Bulk"),
    Library = c("Nanopore", "Nanopore", "Nanopore", "Nanopore", "Nanopore", "Nanopore"),
    row.names = c("1.EO-WET", "2.EO-WET", "20.EO-DRYWET", "4.EO-WET", "26.EO", "30.EO")
)

sample_names(emu) <- emu_samples$SampleID

sample_data(emu) <- emu_samples

# subset dada2 to only include samples in emu
dada2 <- prune_samples(sample_names(dada2) %in% sample_names(emu), dada2)

# do filtering as per previous analysis

## remove mitochondria and chloroplasts
dada2 <- subset_taxa(dada2, (Family!="Mitochondria") | is.na(Family))
dada2 <- subset_taxa(dada2, (Order!="Chloroplast") | is.na(Order))

## remove asv with no assignment at Phylum level
dada2 <- subset_taxa(dada2, Phylum!="")

#! At this point I don't think it's worth including additional filtering steps.
#! They went on to do some abundance filtering but for the purpose of comparing the two methods I don't think it's necessary at this stage!

# make merged df of emu and dada2 richness data
dada2_richness <- estimate_richness(dada2, measures = c("Shannon", "Simpson"))
dada2_richness$Sample <- row.names(dada2_richness)
dada2_richness$Method <- "DADA2"

emu_richness <- estimate_richness(emu, measures = c("Shannon", "Simpson"))
emu_richness$Sample <- row.names(emu_richness)
emu_richness$Method <- "EMU"

richness <- rbind(dada2_richness, emu_richness)

richness <- richness %>%
  pivot_longer(cols = c("Shannon", "Simpson"), names_to = "Measure", values_to = "Value")

# plot richness
ggplot(richness, aes(x = Sample, y = Value, color = Method)) +
  geom_point(size = 10) +
  facet_grid(Measure ~ ., scales = "free_y") + 
  theme_bw()
