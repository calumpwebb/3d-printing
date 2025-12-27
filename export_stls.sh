#!/bin/bash
# Export STL files for all print_ modes in a scad file

if [ $# -ne 2 ]; then
    echo "Usage: $0 <scad_file> <output_dir>"
    echo "Example: $0 accessory_mount.scad ./accessortls"
    exit 1
fi

SCAD_FILE="$1"
OUTPUT_DIR="$2"
BASENAME=$(basename "$SCAD_FILE" .scad)

if [ ! -f "$SCAD_FILE" ]; then
    echo "Error: File '$SCAD_FILE' not found"
    exit 1
fi

# Extract print_ modes from the display_mode line in the scad file
MODES=$(grep -oE 'print_[a-z_]+' "$SCAD_FILE" | sort -u)

if [ -z "$MODES" ]; then
    echo "Error: No print_ modes found in '$SCAD_FILE'"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Exporting STLs from $SCAD_FILE to $OUTPUT_DIR/"

for mode in $MODES; do
    OUTPUT_FILE="${OUTPUT_DIR}/${BASENAME}_${mode}.stl"
    echo "  ${BASENAME}_${mode}.stl..."
    openscad -o "$OUTPUT_FILE" -D "display_mode=\"${mode}\"" "$SCAD_FILE"
done

echo "Done!"
