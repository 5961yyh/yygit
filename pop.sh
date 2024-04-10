#!/bin/bash

# Directory where you stored files
STACK_DIR="/home2/yangyq/qiyang-imx6-android6.0-sdk/yyy"

# Check if the stack list file exists
if [[ ! -f "$STACK_DIR/stack.list" ]]; then
  echo "Stack is empty."
  exit 1
fi

# Read the last file path from the stack
last_file=$(tail -n 1 "$STACK_DIR/stack.list")

# Check if last file exists in stack directory
if [[ -f "$STACK_DIR/$(basename -- "$last_file")" ]]; then
  # Move the file back to its original location
  mv -- "$STACK_DIR/$(basename -- "$last_file")" "$last_file"
  # Remove the last line from stack.list
  sed -i '$ d' "$STACK_DIR/stack.list"
else
  echo "Error: File $(basename -- "$last_file") not found in stack."
fi
