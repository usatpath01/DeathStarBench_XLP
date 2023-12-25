#!/bin/bash
# curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "first_name=x2&last_name=x2&username=x2&password=x2&user_id=x2" http://localhost:8080/api/user/register
curl -X POST -c cookies.txt -H "Content-Type: application/x-www-form-urlencoded" -d "username=neha&password=1234" http://localhost:8080/api/user/login
curl -X GET -b cookies.txt http://localhost:8080/api/user/get_follower

# curl -X GET -H "Content-Type: application/x-www-form-urlencoded" http://localhost:8080/api/user/get_followe
# curl -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "user_name=mark&followee_name=neha" http://localhost:8080/wrk2-api/user/follow
