#!/bin/bash
# This script converts a WEBP image to a TIFF file with specified DPI.

SCRIPT=$(basename "$0")

# Function to show help information
show_help() {
    echo "Usage: $SCRIPT [OPTIONS]"
    echo "Convert a WEBP to a TIFF image file."
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
    echo "  -w, --webp_file NAME      Specify the name of the WEBP input file."
    echo "  -d, --dpi DPI             Specify the dpi you want to use for the TIFF image"
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -w|--webp_file)  # Corrected flag from -s to -w
            webp_file="$2"
            shift
            ;;
        -d|--dpi)
            dpi="$2"
            shift
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done

# Check if the webp file is specified
if [ -z "$webp_file" ]; then
    echo "Error: WEBP file not specified."
    show_help
    exit 1
fi

# Remove the .webp extension from the filename
WEBP_NAME=$(basename -s .webp "$webp_file")

# Convert WEBP to PNG (temporary step)
dwebp "$webp_file" -o "$WEBP_NAME.png"

# Convert PNG to TIFF using specified DPI
convert "$WEBP_NAME.png" -density "$dpi" "$WEBP_NAME.tif"

# Clean up the temporary PNG file
rm "$WEBP_NAME.png"
