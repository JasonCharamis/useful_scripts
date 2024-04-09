
#' Library of functions for PCA analysis and plotting using normalized gene expression values (Transcripts Per Million-TPM) generated from an RNAseq or related experiments.
#' @import edgeR
#' @import magrittr
#' @import stringr
#' @import ggfortify
#' @import ggrepel
#' @import ggthemes
#' @import stringi
#' @import dplyr
#' @import tidyverse

#' @title .load_packages
#' @description This function checks if a package is installed. If not, it installs the package using BiocManager if available, otherwise using install.packages.
#' @param tools A character vector of package names to be checked and installed.
#' @return NULL
#' @export

# Function to check if a package is installed, and if not, install it.
# Function to install or load a package

#' @description This function checks if a package is installed. If not, it installs the package using BiocManager if available, otherwise using install.packages.
#' @param tools A character vector of package names to be checked and installed.
#' @return NULL
#' @export

# Function to check if a package is installed, and if not, install it.
# Function to install or load a package

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


#' Convert TPM values to log-transformed values
#'
#' This function converts a matrix or data frame of TPM (Transcripts Per Million) values to log-transformed values.
#'
#' @param tpm A matrix or data frame containing the TPM values.
#' @param log_number The base of the logarithm to use for the transformation. Default is 2.
#' @param dividebyten A logical value indicating whether to divide the TPM values by 10 before the log transformation. Default is TRUE.
#'
#' @return A matrix or data frame of log-transformed TPM values.
#'
#' @examples
#' tpm <- matrix(c(100, 200, 50, 150), nrow = 2, ncol = 2)
#' log2tpm <- logTPM(tpm)
#' log10tpm <- logTPM(tpm, log_number = 10)
#'
#' @export

logTPM <- function(tpm, log_number = 2, dividebyten = TRUE) {
  if (dividebyten) {
    logtpm <- log(tpm / 10 + 1, log_number)
  } else if (!dividebyten) {
    logtpm <- log(tpm + 1, log_number)
  }
  return(logtpm)
}

#' Principal Component Analysis (PCA) using log2 Transformed TPM values
#'
#' This function performs a Principal Component Analysis (PCA) on a log2-transformed TPM (Transcripts Per Million) matrix and generates a PCA plot
#'
#' @param tpm A data frame or matrix containing the TPM values. The first column should contain the row names.
#' @param samples_list A data frame or vector containing the sample group information. The first column should contain the group names and the second the sample names.
#' @param log_number The base of the logarithm to use for the transformation. Default is 2.
#' @param save A logical value indicating whether to save the PCA plot as an SVG file. Default is TRUE.
#'
#' @return The PCA plot as a ggplot object.
#' @examples
#' tpm <- read.delim2("counts.tpm.tsv", header = TRUE)
#' samples_list <- read.delim2("samples.list", header = FALSE)
#' pca_plot <- pca(tpm, samples_list)
#'
#' @export

pca <- function(tpm, samples_list, log_number = 2, save = TRUE) {
  # Convert TPM values to log2TPM values
  rownames(tpm) <- tpm[, 1]
  tpm <- tpm[, -1]
  tpm_n <- sapply(colnames(tpm), function(x) {
    tpms <- as.numeric(tpm[, x])
    tpms <- matrix(tpms, ncol = 1)
    rownames(tpms) <- rownames(tpm)
    colnames(tpms) <- x
    return(tpms)
  })
  
  # Normalize to log2TPM values
  logtpms <- logTPM(tpm_n, log_number = log_number, dividebyten = FALSE)
  
  # Run PCA analysis
  xt = t(logtpms)
  xt <- as.data.frame(xt)
  groups <- samples_list$V1
  xtl <- xt %>% add_column(Group = groups)
  colnames(xt) <- colnames(xt)
  
  pca_res = prcomp(xt, center = T, scale. = F)
  pve <- pca_res$sdev^2 / sum(pca_res$sdev^2) * 100
  PC1_variation_percent <- as.numeric(round(pve[1], 2))
  PC2_variation_percent <- as.numeric(round(pve[2], 2))
  
  # Create PCA plot
  PCA_plot <- ggplot(data = pca_res, aes(x = pca_res$x[, 1], y = pca_res$x[, 2])) +
    geom_point(data = xtl, shape = 19, aes(color = Group)) +
    geom_text_repel(data = xtl, aes(label = rownames(pca_res$x), color = Group), stat = "identity") +
    labs(
      title = expression(bold("Principal Component Analysis using log2TPM values")),
      x = paste("PC1: ", PC1_variation_percent, "%"),
      y = paste("PC2: ", PC2_variation_percent, "%")
    ) +
    theme_clean() +
    theme(
      plot.title = element_text(color = "black", size = 12, family = "Arial", face = "bold", hjust = 0.6),
      axis.title.x = element_text(color = "black", size = 12, family = "Arial", face = "bold"),
      axis.title.y = element_text(color = "black", size = 12, family = "Arial", face = "bold")
    ) +
    guides(color = guide_legend(
      override.aes = list(
        shape = 19, # Change the shape of the legend ticks
        size = 2 # Change the size of the legend ticks
      )
    ))
  
  if (exists("PCA_plot")) {
    if (save == TRUE) {
      ggsave(plot = PCA_plot, filename = "PCA.svg", dpi = 600)
    } else {
      print("Plot will not be saved. Returning PCA plot")
    }
    return(PCA_plot)
  }
}


# Check if the script is run from the command line
if (interactive()) {
  tpm <- read.delim2("counts.tpm.tsv", header = TRUE)
  samples_list <- read.delim2("samples.list", header = FALSE)
} else {
  # Get input files from command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) > 0, file.exists(args))
  tpm <-  read.delim(args[1], header = TRUE)
  samples_list <- read.delim2(args[2], header = TRUE)
}

pca (tpm = tpm,
     samples_list = samples_list,
     log_number = 2,
     save = TRUE)
