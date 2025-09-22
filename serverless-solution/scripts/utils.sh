#!/bin/bash

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local temp
    local color_counter=0
    
    tput civis
    
    while kill -0 $pid 2>/dev/null; do
        temp=${spinstr#?}
        
        # Looks weird, i know... but this cycle between colors every ~1 second
        if [ $((color_counter % 10)) -lt 5 ]; then
            printf "\r\033[91m%c\033[0m" "$spinstr"
        else
            printf "\r\033[95m%c\033[0m" "$spinstr"
        fi
        
        spinstr=$temp${spinstr%"$temp"}
        color_counter=$((color_counter + 1))

        sleep $delay
    done
    
    printf "\r"
    tput cnorm
}

print_success() {
    echo -e "\033[32m✓ $1\033[0m"
}

print_error() {
    echo -e "\033[31m✗ $1\033[0m"
}

print_info() {
    echo -e "\033[34m* $1\033[0m"
}

print_warning() {
    echo -e "\033[33m! $1\033[0m"
}