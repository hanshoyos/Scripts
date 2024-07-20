#!/bin/bash

# Prompt for the ISO file name
read -p "Enter the name of the ISO file (with extension): " ISO_FILE

# Define the part prefix and the reassembled file name
PART_PREFIX="${ISO_FILE}.part"
REASSEMBLED_FILE="reassembled_${ISO_FILE}"

# Generate a checksum for the original file
echo "Generating checksum for the original file..."
shasum -a 256 "$ISO_FILE" > original_checksum.txt
echo "Checksum for the original file saved to original_checksum.txt."

# Split the original file into 1.9GB parts
echo "Splitting the file into 1.9GB parts..."
split -b 1900m "$ISO_FILE" "$PART_PREFIX"

# List the parts to verify
echo "Parts created:"
ls -lh ${PART_PREFIX}*

# Create reassemble script
REASSEMBLE_SCRIPT="reassemble_${ISO_FILE}.sh"
echo "Creating reassemble script..."
cat <<EOL > $REASSEMBLE_SCRIPT
#!/bin/bash

# Reassemble the parts into a single file
echo "Reassembling the parts..."
cat ${PART_PREFIX}* > "$REASSEMBLED_FILE"

# List the reassembled file to verify
echo "Reassembled file:"
ls -lh "$REASSEMBLED_FILE"

# Generate checksums for the reassembled file
echo "Generating checksum for the reassembled file..."
shasum -a 256 "$REASSEMBLED_FILE" > reassembled_checksum.txt

# Compare the checksums
echo "Comparing checksums..."
if diff original_checksum.txt reassembled_checksum.txt > /dev/null; then
  echo "Checksum verification passed. The files are identical."
else
  echo "Checksum verification failed. The files are not identical."
fi

# Clean up the checksum files
echo "Cleaning up..."
rm reassembled_checksum.txt

echo "Done."
EOL

# Make the reassemble script executable
chmod +x $REASSEMBLE_SCRIPT
echo "Reassemble script created: $REASSEMBLE_SCRIPT"

echo "Done."
