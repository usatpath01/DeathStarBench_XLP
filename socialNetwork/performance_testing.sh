#!/bin/bash

# Random number for this run 
random_number=$(shuf -i 1-1000 -n 1)

# Function to calculate quartiles
calculate_quartiles() {
    local array=("$@")
    local length=${#array[@]}
    
    # Sort the array
    sorted_array=($(printf '%s\n' "${array[@]}" | sort -n))
    
    # Remove the highest 10 values
    trimmed_array=("${sorted_array[@]:0:$length-10}")
    local trimmed_length=${#trimmed_array[@]}
    # Calculate quartiles
    q1_index=$((trimmed_length / 4))
    q3_index=$((3 * trimmed_length / 4))
    
    min="${trimmed_array[0]}"
    q1="${trimmed_array[q1_index]}"
    median="${trimmed_array[trimmed_length / 2]}"
    q3="${trimmed_array[q3_index]}"
    max="${trimmed_array[trimmed_length - 1]}"
    
    echo "$min,$q1,$median,$q3,$max"
}

# Function to send requests and log data
send_requests_and_log() 
{
    local curl_command="$1"
    local endpoint_name="$2"
    local http_method="$3"
    local logging_type="$4"
    # Array to store request times
    request_times=()
    # Send 1000 requests
    for ((i=1; i<=20; i++)); do
        # Send the request and record the time
        start_time=$(date +%s%N)
        eval "$curl_command" >/dev/null 2>&1
        end_time=$(date +%s%N)
        
        # Calculate the request time in milliseconds
        request_time=$((($end_time - $start_time) / 1000000))
        
        # Append the request time to the array
        request_times+=("$request_time")
        
        echo "Request $i completed in $request_time ms"
    done
    # Calculate quartiles
    quartiles=$(calculate_quartiles "${request_times[@]}")
    # Log data to output file
    echo "$quartiles,$logging_type,$http_method,$endpoint_name" >> "$output_file"
}

# No Logger Requests
send_requests_no_log()
{
    local curl_command="$1"
    local endpoint_name="$2"
    local http_method="$3"
    local logging_type="NO"

    send_requests_and_log "$curl_command" "$endpoint_name" "$http_method" "$logging_type"

}

send_requests_xlp()
{
    local curl_command="$1"
    local endpoint_name="$2"
    local http_method="$3"
    local logging_type="XLP"

    # Start the Docker container
    docker run --name xlp --rm -d  --privileged --pid=host --cgroupns=host \
        -v /boot/config-$(uname -r):/boot/config-$(uname -r):ro \
        -v /sys/kernel/debug/:/sys/kernel/debug/ anon98484/xlp  >/dev/null

    send_requests_and_log "$curl_command" "$endpoint_name" "$http_method" "$logging_type"

    # Stop the Docker container
    docker stop xlp
    # docker rm xlp
}


send_requests_tracee()
{
    local curl_command="$1"
    local endpoint_name="$2"
    local http_method="$3"
    local logging_type="Tracee"

    echo "STARTING TRACEE"

    docker run  --name tracee --rm -d -it     --pid=host --cgroupns=host --privileged     -v /etc/os-release:/etc/os-release-host:ro     -e LIBBPFGO_OSRELEASE_FILE=/etc/os-release-host     aquasec/tracee:latest --output json --containers --events read,write,bind,connect,accept,accept4,clone,close,creat,dup,dup2,dup3,execve,exit,exit_group,fork,open,openat,rename,renameat,unlink,unlinkat,vfork  >/dev/null

    send_requests_and_log "$curl_command" "$endpoint_name" "$http_method" "$logging_type"

    docker stop tracee
    # docker rm tracee
}


# Create a file to store request times
output_file="request_times.csv"
> "$output_file"
echo "Min,Q1,Median,Q3,Max,Logging Type,GET/POST,Endpoint Name" > "$output_file"

# Register dummy users
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "first_name=dummy1&last_name=dummy1&username=dummy1&password=dummy1" http://10.5.20.184:8080/api/user/register
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "first_name=dummy2&last_name=dummy2&username=dummy2&password=dummy2" http://10.5.20.184:8080/api/user/register
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "first_name=dummy3&last_name=dummy3&username=dummy3&password=dummy3" http://10.5.20.184:8080/api/user/register

# POST REQUEST CREATE POST
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "username=username_1234&user_id=1234&text=$(cat /dev/urandom | tr -dc '\''a-zA-Z0-9'\'' | fold -w 256 | head -n 1)&media_ids=[]&media_types=[]&post_type=0" \
"http://10.5.20.184:8080/wrk2-api/post/compose"'
endpoint_name="COMPOSE POST"
http_method="POST"

send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"

# POST REQUEST REGISTER USER
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "first_name=user_$i_$random_number&last_name=user_$i_$random_number&username=user_$i_$random_number&password=user_$i_$random_number" \
"http://10.5.20.184:8080/api/user/register"'
endpoint_name="REGISTER USER"
http_method="POST"
send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "first_name=user_$i_$random_number_xlp&last_name=user_$i_$random_number_xlp&username=user_$i_$random_number_xlp&password=user_$i_$random_number_tracee" \
"http://10.5.20.184:8080/api/user/register"'
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "first_name=user_$i_$random_number_tracee&last_name=user_$i_$random_number_tracee&username=user_$i_$random_number_tracee&password=user_$i_$random_number_tracee" \
"http://10.5.20.184:8080/api/user/register"'
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"


# POST REQUEST FOLLOW USER
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "user_name=user_$i_$random_number&followee_name=dummy1" \
"http://10.5.20.184:8080/wrk2-api/user/follow"'
endpoint_name="FOLLOW USER"
http_method="POST"
send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "user_name=user_$i_$random_number&followee_name=dummy2" \
"http://10.5.20.184:8080/wrk2-api/user/follow"'
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
curl_command='curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
-d "user_name=user_$i_$random_number&followee_name=dummy3" \
"http://10.5.20.184:8080/wrk2-api/user/follow"'
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"

# GET REQUEST READ USER TIMELINE
curl_command='curl -X GET -H "Content-Type: application/x-www-form-urlencoded" \
"http://10.5.20.184:8080/wrk2-api/user-timeline/read?user_id=1234&start=$(shuf -i 0-10 -n 1)&stop=$((start + 10))"'
endpoint_name="READ USER TIMELINE"
http_method="GET"
send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"


# GET REQUEST READ HOME TIMELINE
curl_command='curl -X GET -H "Content-Type: application/x-www-form-urlencoded" \
"http://10.5.20.184:8080/wrk2-api/home-timeline/read?user_id=1234&start=$(shuf -i 0-10 -n 1)&stop=$((start + 10))"'
endpoint_name="READ HOME TIMELINE"
http_method="GET"
send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"

# GET REQUEST GET FOLLOWERS 
# Login first
curl -X POST -c cookies.txt -H "Content-Type: application/x-www-form-urlencoded" -d "username=dummy1&password=dummy1" http://10.5.20.184:8080/api/user/login
curl_command='curl -X GET -b cookies.txt  \
"http://10.5.20.184:8080/api/user/get_follower"'
endpoint_name="GET FOLLOWERS"
http_method="GET"
send_requests_no_log "$curl_command" "$endpoint_name" "$http_method"
send_requests_xlp "$curl_command" "$endpoint_name" "$http_method"
send_requests_tracee "$curl_command" "$endpoint_name" "$http_method"


# Delete session cookies
rm cookies.txt