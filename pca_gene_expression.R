
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

#' Principal Component Analysis (PCA) from gene expression (RNAseq) data using log2 Transformed TPM values
#'
#' This function performs a Principal Component Analysis (PCA) on a log2-transformed TPM (Transcripts Per Million) matrix and generates a PCA plot
#'
#' @param tpm_file A data frame or matrix containing the TPM values. The first column should contain the row names.
#' @param samples_list A data frame or vector containing the sample group information. The first column should contain the group names and the second the sample names.
#' @param log_number The base of the logarithm to use for the transformation. Default is 2.
#' @param save A logical value indicating whether to save the PCA plot as an SVG file. Default is TRUE.
#' @param filename A string with the filename of output file. Default is 'PCA.svg'
#' @param interactive A logical value indicating whether to get input files interactively by the user or defined as arguments. Default: FALSE.
#' 
#' @return The PCA plot as a ggplot object.
#' @examples
#' 
#' pca (tpm_file = "counts.tpm.tsv",
#'     samples_list = "samples.list",
#'     log_number = 2,
#'     save = TRUE,
#'     interactive = FALSE)
#'   
#' @export

pca <- function(tpm_file = NULL, 
                samples_list = NULL, 
                log_number = 2, 
                fontsize = 12,
                save = TRUE,
                filename = NULL,
                interactive = FALSE ) {
  
  # Convert TPM values to log2TPM values
  
  # Check if the script is run from the command line
  if ( interactive == TRUE ) {
    if (!is.null(tpm_file) || !is.null(samples_list)) {
      stop("Option interactive is TRUE and input files are also provided.")
    } 
  
    cat("Please choose the file with TPM values.\n")
    tpm_file <- file.choose()
    
    cat("Please choose the file with sample groupings\n")
    samples_list <- file.choose()
    
  } 
  
  tpm <- read.delim2(tpm_file, header = TRUE)
  sample_groupings <- read.delim2(samples_list, header = FALSE)
  
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
  xt <- t(logtpms)
  xtl <- as_tibble( xt ) %>% mutate(Group = sample_groupings$V2)
  
  # Run PCA analysis
  pca_res = prcomp(xt, center = T, scale. = F)
  pve <- pca_res$sdev^2 / sum(pca_res$sdev^2) * 100
  PC1_variation_percent <- as.numeric(round(pve[1], 2))
  PC2_variation_percent <- as.numeric(round(pve[2], 2))
  
  # Create PCA plot
  PCA_plot <- ggplot(data = pca_res, aes(x = pca_res$x[, 1], y = pca_res$x[, 2])) +
    geom_point(data = xtl, shape = 19, aes(color = Group), size = (fontsize/2)-5) +
    geom_text_repel(data = xtl, aes(label = rownames(pca_res$x), color = Group), size = (fontsize/2)-3) +
    labs(
      title = expression(bold("Principal Component Analysis using log2TPM values")),
      x = paste("PC1: ", PC1_variation_percent, "%"),
      y = paste("PC2: ", PC2_variation_percent, "%")
    ) +
    theme_clean() +
    theme(
      plot.title = element_text(color = "black", size = fontsize+5, family = "Arial", face = "bold", hjust = 0.6),
      axis.title.x = element_text(color = "black", size = fontsize, family = "Arial", face = "bold"),
      axis.title.y = element_text(color = "black", size = fontsize, family = "Arial", face = "bold"),
      plot.margin = margin(r = 0.1, unit = "cm")
    ) +
    guides(color = guide_legend(
      override.aes = list(
        shape = 19, # Change the shape of the legend ticks
        size = (fontsize/2)-3 # Change the size of the legend ticks
      ),
      text = element_text(size = (fontsize/2)-3) # Change the legend text size here
    ))
  
  if (exists("PCA_plot")) {
    if (save == TRUE) {
      if ( is.null(filename) ) {
        ggsave(plot = PCA_plot, filename = "PCA.svg", dpi = 600)
      } else {
         ggsave(plot = PCA_plot, filename = filename, dpi = 600)
      }
    } else {
        if ( !is.null(filename) ) {
          warning("Option to save is disabled.")
        } else {
            print("Plot will not be saved. Returning PCA plot")
      }
    }
    
    return(PCA_plot)
  }
}


# Get input files from command line arguments
if (!interactive()) {
    args <- commandArgs(trailingOnly = TRUE)
    stopifnot(length(args) > 0, file.exists(args))
    
    pca( tpm_file = args[1], samples_list = args[2] )
}


