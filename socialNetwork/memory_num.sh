#!/bin/bash

# Number of concurrent requests to send
num_concurrent_requests=1000

# Function to send a POST request
send_post_request() {
    curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
         -d "username=user_1234&user_id=1234&text=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1)&media_ids=[]&media_types=[]&post_type=0" \
         http://localhost:8080/wrk2-api/post/compose
}

# Loop to send concurrent requests
for ((i=1; i<=$num_concurrent_requests; i++)); do
    send_post_request 
    echo "Request $i sent"
done

# # Wait for all background jobs to finish
# wait

echo "$num_concurrent_requests concurrent requests have been sent."

