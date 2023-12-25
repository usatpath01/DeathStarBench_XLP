#!/bin/bash

# Number of requests to send
num_requests=5

# Function to send a POST request
send_post_request() {
    curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
         -d "username=username_123&user_id=123&text=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1)&media_ids=[]&media_types=[]&post_type=0" \
         http://localhost:8080/wrk2-api/post/compose
}

# Loop to send multiple requests
for ((i=1; i<=$num_requests; i++)); do
    send_post_request
    echo "Request $i sent."
    sleep 5
done

echo $num_requests " requests have been sent."
