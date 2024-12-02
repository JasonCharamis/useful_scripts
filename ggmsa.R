
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
dependencies <- c(
    "ggmsa", 
    "ggplot2",
)

.load_packages(dependencies)

# Define a function to visualize MSA using ggmsa
visualize_msa <- function(aln_filename, range, output_name = "MSA") {
  ggmsa(aln_filename, 
        start = range[1], 
        end = range[2], 
        seq_number = TRUE, 
        number_interval = 5,
        seq_name = TRUE, 
        color = "Chemistry_AA", 
        show.legend = TRUE) +
    geom_seqlogo(color = "Chemistry_AA") 
}