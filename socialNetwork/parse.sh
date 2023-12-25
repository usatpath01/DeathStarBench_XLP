#!/bin/bash

input_output_file="$1"

# # Filter lines with " Request Order : "
grep -oP "Request Order : \K[1-6]" $input_output_file > ~/xlp_logs/docker_logs_filtered.txt
mv ~/xlp_logs/docker_logs_filtered.txt $input_output_file
# Process and update the numbers in the input/output file


# Check if the input/output file exists
if [ ! -f "$input_output_file" ]; then
    echo "Input/output file '$input_output_file' not found."
    exit 1
fi

# Temporary file to store processed numbers
temp_file=$(mktemp)

i=0
j=0
k=0
l=0 
m=0 
n=0
# Read the numbers from the input file and process them
while IFS= read -r line; do
    case "$line" in
        1) new_num=$((1 + i * 6)); i=$((i + 1)) ;;
        2) new_num=$((2 + j * 6)); j=$((j + 1)) ;;
        3) new_num=$((3 + k * 6)); k=$((k + 1)) ;;
        4) new_num=$((4 + l * 6)); l=$((l + 1)) ;;
        5) new_num=$((5 + m * 6)); m=$((m + 1)) ;;
        6) new_num=$((6 + n * 6)); n=$((n + 1)) ;;
        *) new_num="$line" ;;
    esac
    echo "$new_num" >> "$temp_file"
done < "$input_output_file"

# Replace the content of the input/output file with the processed numbers
mv "$temp_file" "$input_output_file"

echo "Numbers processed in $input_output_file"