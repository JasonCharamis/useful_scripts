#!/bin/bash

# Check if required programs are installed
check_requirements() {
    local missing_deps=()
    
    if ! command -v inkscape >/dev/null 2>&1; then
        missing_deps+=("inkscape")
    fi
    
    if ! command -v convert >/dev/null 2>&1; then
        missing_deps+=("imagemagick")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: Missing required dependencies:"
        printf '%s\n' "${missing_deps[@]}"
        echo "Please install them and try again."
        exit 1
    fi
}

# Display usage information
usage() {
    echo "Usage: svg2tiff.sh [options] <input_file.svg> [output_file.tiff]"
    echo "Options:"
    echo "  -r, --resolution DPI    Set output resolution (default: 300)"
    echo "  -h, --help             Display this help message"
    exit 1
}

# Convert SVG to TIFF
convert_svg_to_tiff() {
    local input_file="$1"
    local output_file="$2"
    local resolution="$3"
    
    # Get base name without .svg extension for PNG
    local base_name="${input_file%.svg}"
    local temp_png="${base_name}.png"
    
    # Convert SVG to PNG using Inkscape
    if ! ~/bin/Inkscape-e7c3feb-x86_64.AppImage --export-type=png --export-dpi="$resolution" \
         --export-filename="$temp_png" "$input_file" >/dev/null 2>&1; then
        echo "Error: Failed to convert SVG to PNG"
        rm -f "$temp_png"
        exit 1
    fi
    
    # Convert PNG to TIFF using ImageMagick
    if ! convert "$temp_png" -compress lzw -depth 8 -density $resolution -quality 100 -alpha remove -trim "$output_file" >/dev/null 2>&1; then
        echo "Error: Failed to convert PNG to TIFF"
        rm -f "$temp_png"
        exit 1
    fi
    
    # Clean up temporary file
    rm -f "$temp_png"
    
    echo "Successfully converted $input_file to $output_file"
}

# Main script
main() {
    check_requirements
    
    local resolution=300
    local quality=100
    
    # Parse command line options
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -r|--resolution) resolution="$2"; shift 2 ;;
            -h|--help) usage ;;
            *) break ;;
        esac
    done
    
    # Check for input file
    if [ "$#" -lt 1 ]; then
        echo "Error: No input file specified"
        usage
    fi
    
    local input_file="$1"
    local output_file="$2"
    
    # Validate input file
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found"
        exit 1
    fi
    
    # Generate output filename if not specified
    if [ -z "$output_file" ]; then
        output_file="${input_file%.svg}.tiff"
    fi
    
    convert_svg_to_tiff "$input_file" "$output_file" "$resolution"
}

main "$@"