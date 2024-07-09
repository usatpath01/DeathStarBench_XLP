#!/bin/bash

# for i in $(docker container ls --format "{{.ID}}"); do docker inspect -f '{{.State.Pid}}' $i; done
# Initialize an array to store process IDs

# Initialize an array to store process IDs
#process_ids=()

# Iterate over Docker container IDs
#for i in $(docker container ls --format "{{.ID}}"); do
  # Extract the process ID from the docker inspect output
#  pid=$(docker inspect -f '{{.State.Pid}}' $i)
  
  # Add the process ID to the array
#  process_ids+=("$pid")
#done

# Print the process IDs
#echo "Process IDs: ${process_ids[@]}"

process_ids=( 26324 25902 26391 26028 25441)
# Iterate over the array
for i in "${process_ids[@]}"
do
  sudo pidstat -drsuvwn -p "$i" 1 > "pidstat_$i.txt" &
done

wait
echo "done"
