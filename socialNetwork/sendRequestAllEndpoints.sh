#!/bin/bash

# Number of requests to send
num_requests=100

# Number of fixed "Compose post" requests
num_compose_requests=50

# Function to send a POST request
send_post_request() {
    curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
         -d "username=username_1234&user_id=1234&text=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 256 | head -n 1)&media_ids=[]&media_types=[]&post_type=0" \
         http://10.5.20.145:8080/wrk2-api/post/compose
}

# Function to send a GET request to user timeline
send_user_timeline_request() {
    #curl -X GET http://10.5.20.145:8080/wrk2-api/user-timeline/read?user_id=1234&start=10&stop=20
    curl -X GET http://10.5.20.145:8080/wrk2-api/user-timeline/read\?user_id\=1234\&start\=10\&stop\=20
}

# Function to send a GET request to home timeline
send_home_timeline_request() {
    #curl -X GET http://10.5.20.145:8080/wrk2-api/home-timeline/read?user_id=1234&start=10&stop=200
    curl -X GET http://10.5.20.145:8080/wrk2-api/home-timeline/read\?user_id\=1234\&start\=10\&stop\=200
}

# Fixed number of "Compose post" requests
for ((i=1; i<=$num_compose_requests; i++)); do
    send_post_request
done

# Loop to send multiple requests (remaining requests)
for ((i=1; i<=$num_requests - $num_compose_requests; i++)); do
    # Generate a random number between 1 and 3
    rand_num=$((1 + RANDOM % 3))

    # Send requests based on the random number
    case $rand_num in
        1) send_post_request ;;
        2) send_user_timeline_request ;;
        3) send_home_timeline_request ;;
    esac
done

echo $num_requests" requests have been sent."
