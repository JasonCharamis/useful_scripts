#!/bin/bash

SCRIPT=$(basename "$0")

show_help() {
    echo "Usage: $SCRIPT [OPTIONS]"
    echo "Convert an PNG to a TIFF image file."
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message and exit"
    echo "  -s, --png_file NAME      Specify the name of PNG input file. This name will also be used for the TIFF output file."
    echo "  -d, --dpi DPI            Specify the dpi you want to use for the TIFF image"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--png_file)
            png_file="$2"
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

if [ -z "$png_file" ]; then
    echo "Error: PNG file not specified."
    show_help
    exit 1
fi

PNG_NAME=$(basename -s .png "$png_file")

inkscape --without-gui --export-png="$PNG_NAME.png" --export-dpi="$dpi" --export-area-drawing "$png_file" && \
convert -compress LZW -alpha remove -trim "$PNG_NAME.png" "$PNG_NAME.tiff" && \
mogrify -alpha off -geometry 1000x "$PNG_NAME.tiff" && \
rm "$PNG_NAME.png"
