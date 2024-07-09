#!/usr/bin/env bash

# Number of requests to send
num_requests=1000

# Function to send a POST request
send_post_request() {
    curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
         -d "username=username_1234&user_id=1234&text=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1)&media_ids=[]&media_types=[]&post_type=0" \
         http://10.5.20.145:8080/wrk2-api/post/compose
}

# Loop to send multiple requests
for ((i=1; i<=$num_requests; i++)); do
    send_post_request &
    sleep 0.01
    done
    # Sleep for 1 millisecond


# Wait for all background jobs to finish
wait

echo $num_requests" requests have been sent."
