#!/bin/bash

# Output directory for log files
output_dir="./logs"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Get a list of container IDs for currently running containers
container_ids=$(docker ps -q)

# Loop through each container and collect logs
for container_id in $container_ids; do
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's|/||')
    docker logs "$container_id" > "$output_dir/${container_name}_logs.txt" 2>&1 > /dev/null
    echo "Logs for $container_name saved to $output_dir/${container_name}_logs.txt"
done

echo "Log collection completed."

