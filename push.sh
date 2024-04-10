#!/bin/bash

# Directory where you want to store files
STACK_DIR="/home2/yangyq/qiyang-imx6-android6.0-sdk/yyy"

# Check if stack directory exists, if not, create it
mkdir -p "$STACK_DIR"

# Loop over arguments
for file in "$@"; do
  # Check if file exists
  if [[ -f $file ]]; then
    # Copy file to the stack directory
    cp -- "$file" "$STACK_DIR"
    # Store original file path
    echo "$(realpath -- "$file")" >> "$STACK_DIR/stack.list"
  else
    echo "Error: File $file not found."
  fi
done
