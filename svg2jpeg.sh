#!/bin/bash

SCRIPT=$(basename "$0")

show_help() {
    echo "Usage: $SCRIPT [OPTIONS]"
    echo "Convert an SVG to a JPEG image file."
    echo ""
    echo "Options:"
    echo "  -h, --help               Show this help message and exit"
    echo "  -s, --svg_file NAME      Specify the name of SVG input file. This name will also be used for the JPEG output file."
    echo "  -d, --dpi DPI            Specify the dpi you want to use for the JPEG image"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--svg_file)
            svg_file="$2"
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

if [ -z "$svg_file" ]; then
    echo "Error: SVG file not specified."
    show_help
    exit 1
fi

SVG_NAME=$(basename -s .svg "$svg_file")

inkscape --without-gui --export-png="$SVG_NAME.png" --export-dpi="$dpi" --export-area-drawing "$svg_file" && \
convert -compress LZW -alpha remove -trim "$SVG_NAME.png" "$SVG_NAME.jpeg" && \
mogrify -alpha off -geometry 1000x "$SVG_NAME.jpeg" && \
rm "$SVG_NAME.png"
