                                        # Principal components analysis using log2TPM values

.load_packages <- function(tools) {
  tmp <- as.data.frame(installed.packages()) 
  max_version <- max(as.numeric(substr(tmp$Built, 1, 1)))
  tmp <- tmp[as.numeric(substr(tmp$Built, 1, 1)) == max_version,]

  for (pkg in tools) {
    if (pkg %in% tmp$Package) {
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
    } else {
      print(sprintf("%s %s", pkg, "is not installed. Installing it!"))
      
      if (pkg %in% BiocManager::available(pkg)) {
        BiocManager::install(pkg, dependencies = TRUE, update = TRUE)
      } else {
        install.packages(pkg, dependencies = TRUE, ask = FALSE)
      }
    }
  }
}

# Load required packages or install them if necessary
dependencies <- c("edgeR", 
                  "magrittr",
                  "stringr",
                  "ggfortify",
                  "ggrepel",
                  "ggthemes",
                  "stringi",
                  "dplyr",
                  "tidyverse")

.load_packages(dependencies)


# Check if the script is run from the command line
if (interactive()) {
  # Prompt the user to enter the input files
  cat("Please enter the path to the gene counts table: ")
  tpm_file <- file.choose()
  cat("Please enter the path to the file declaring sample grouping of replicates: ")
  samples_list_file <- file.choose()
} else {
  # Get input files from command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) > 0, file.exists(args))
  tpm_file <- args[1]
  samples_list_file <- args[2]
}

# Open input files
tpm <- read.delim2(tpm_file, header = TRUE)
samples_list <- read.delim2(samples_list_file, header = TRUE, sep = "\t")


## Manipulate data and convert TPM to log2TPM values ------------------------------------------------------------------

# Set first column as rownames
rownames(tpm) <- tpm[,1]
tpm <- tpm[,-1]

# Transform colnames to same syntax
colnames(tpm) <- str_replace(colnames(tpm), "results.|.s.bam|_", "")

# Convert dataframe to matrix, to allow for log2 transformation
tpm <- as.matrix(tpm)

# Function to convert tpm to log2tpm values
logTPM <- function(tpm, dividebyten=TRUE) {
  if(dividebyten) {
    logtpm <- log(tpm/10+1, 2)}
  else if(!dividebyten) {
    logtpm <- log(tpm+1, 2)}
  return(logtpm)
}

logtpms<-logTPM(tpm, dividebyten = FALSE)


## Run PCA analysis ------------------------------------------------------------------

# Prepare data structures
xt = t(logtpms)
xt <- as.data.frame(xt)
groups <- samples_list$V1 # get group column

# Add column with sample name to group replicates
xtl <- xt %>% mutate(Sample = groups)

# Run PCA analysis 
pca_res = prcomp(xtl, center=T, scale.=F)

#svg("PCA.svg")

# Draw auto-PCA plot with color mappings for groups
ggplot(data = pca_res, colour = 'Sample', legend.size = 5) + 
    labs(title = "Principal Component Analysis using log2TPM values" ) +
#    theme_bw() +
#    geom_text_repel( x =  aes( label = rownames(xt) ), show.legend = FALSE  ) +
    theme( plot.title = element_text(face = "bold", hjust = 0.5),
          legend.title = element_text( size = 12),
          legend.text = element_text( size = 12 ),
          axis.title = element_text( size = 12 )
              )
#dev.off()
