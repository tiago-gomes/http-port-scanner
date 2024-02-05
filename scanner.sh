#!/bin/bash

# Function to check if port 80 is open and retrieve headers
check_port() {
    ip=$1
    response=$(curl -sI "http://$ip" -m 2)
    http_code=$(echo "$response" | head -n 1 | awk '{print $2}')

    if [ "$http_code" == "200" ] || [ "$http_code" == "501" ]; then
        echo "IP: $ip, HTTP Code: $http_code"
        echo "Headers:"
        echo "$response"
        echo "---------------------------"
    fi
}

# Function to increment IP address
increment_ip() {
    IFS='.' read -r -a ip_arr <<< "$1"
    for i in {3..0}; do
        ip_arr[$i]=$((ip_arr[$i]+1))
        [ "${ip_arr[$i]}" -le 255 ] && break
        [ $i -gt 0 ] && ip_arr[$i]=0
    done
    echo "${ip_arr[0]}.${ip_arr[1]}.${ip_arr[2]}.${ip_arr[3]}"
}

# Get user input for IP address
read -p "Enter the starting IP address: " start_ip
read -p "Enter the ending IP address: " end_ip

# Loop through the IP range and check port 80
current_ip="$start_ip"
while [[ "$current_ip" != "$end_ip" ]]; do
    check_port "$current_ip" &
    current_ip=$(increment_ip "$current_ip")
done

# Check the last IP address in the range
check_port "$end_ip" &

# Wait for all background processes to finish
wait
