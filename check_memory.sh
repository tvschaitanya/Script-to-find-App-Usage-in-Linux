#!/bin/bash

# Function to truncate long strings with ellipsis
truncate() {
    local string="$1"
    local max_length="$2"
    if [ ${#string} -gt "$max_length" ]; then
        echo "${string:0:$((max_length-3))}..."
    else
        echo "$string"
    fi
}

# Function to find common prefix in process names
find_common_prefix() {
    local first_name="$1"
    local temp_file="$2"
    local prefix="$first_name"
    
    # Read each process name and compare with the first one
    while IFS= read -r line; do
        proc_name=$(echo "$line" | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | xargs)
        # Compare character by character to find the common prefix
        i=0
        new_prefix=""
        while [ $i -lt ${#prefix} ] && [ $i -lt ${#proc_name} ]; do
            if [ "${prefix:$i:1}" != "${proc_name:$i:1}" ]; then
                break
            fi
            new_prefix="${new_prefix}${prefix:$i:1}"
            i=$((i + 1))
        done
        prefix="$new_prefix"
    done < "$temp_file"

    # If the prefix ends with a space or a separator, trim it
    if [[ "$prefix" == */ || "$prefix" == *" " ]]; then
        prefix="${prefix%?}"
    fi

    echo "$prefix"
}

# Function to calculate and display memory for a given process name
calculate_memory() {
    local process_name="$1"
    local total_memory=0
    local process_count=0

    # Temporary file to store process data for sorting
    temp_file=$(mktemp)

    # Use ps to get memory usage (RSS in KB), PID, and process name
    while IFS= read -r line; do
        # Extract memory value (in KB), PID, and process name
        memory=$(echo "$line" | awk '{print $1}')
        pid=$(echo "$line" | awk '{print $2}')
        proc_name=$(echo "$line" | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | xargs)

        # Write to temp file for sorting (memory, pid, proc_name)
        echo "$memory $pid $proc_name" >> "$temp_file"

    done < <(ps -A -o rss,pid,comm | grep -i "$process_name" | grep -v grep)

    # If no processes were found
    if [ ! -s "$temp_file" ]; then
        echo "No processes found matching '$process_name'."
        rm "$temp_file"
        return
    fi

    # Find the common prefix among all process names
    first_line=$(head -n 1 "$temp_file")
    first_proc_name=$(echo "$first_line" | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | xargs)
    common_prefix=$(find_common_prefix "$first_proc_name" "$temp_file")

    # Print table header with PID column
    printf "%-25s %-10s %-10s\n" "Process Name" "PID" "Memory(MB)"
    printf "%-25s %-10s %-10s\n" "------------" "----------" "----------"

    # Note about sorting
    echo "Results are sorted by memory (high to low)."

    # Sort the temp file by memory (first column, numeric, descending) and process
    while IFS= read -r line; do
        # Extract memory, PID, and process name from sorted line
        memory=$(echo "$line" | awk '{print $1}')
        pid=$(echo "$line" | awk '{print $2}')
        proc_name=$(echo "$line" | awk '{for (i=3; i<=NF; i++) printf $i " "; print ""}' | xargs)

        # Remove the common prefix from the process name
        if [ -n "$common_prefix" ]; then
            proc_name=${proc_name#"$common_prefix"}
            # Trim leading spaces or slashes after removing prefix
            proc_name=${proc_name##+([ /])}
        fi

        # Truncate process name to 22 characters (to fit within 25 with ellipsis)
        proc_name=$(truncate "$proc_name" 22)

        # Convert memory from KB to MB using integer division
        memory_mb=$((memory / 1024))  # Integer part
        memory_remainder=$((memory % 1024))  # Remainder for decimal part
        memory_decimal=$((memory_remainder * 100 / 1024))  # Simulate two decimal places
        memory_mb_formatted="$memory_mb.$memory_decimal"

        # Add to total memory (in KB for now, will convert later)
        total_memory=$((total_memory + memory))

        # Increment process count
        process_count=$((process_count + 1))

        # Print process name, PID, and memory in a compact tabular format
        printf "%-25s %-10s %-10s\n" "$proc_name" "$pid" "$memory_mb_formatted"

    done < <(sort -nr "$temp_file")

    # Clean up temp file
    rm "$temp_file"

    # Convert total memory from KB to MB
    total_memory_mb=$((total_memory / 1024))  # Integer part
    total_memory_remainder=$((total_memory % 1024))  # Remainder for decimal part
    total_memory_decimal=$((total_memory_remainder * 100 / 1024))  # Simulate two decimal places
    total_memory_mb_formatted="$total_memory_mb.$total_memory_decimal"

    # Decide unit (MB or GB)
    if [ "$total_memory_mb" -ge 1024 ]; then
        # Convert to GB
        total_memory_gb=$((total_memory_mb / 1024))
        total_memory_gb_remainder=$((total_memory_mb % 1024))
        total_memory_gb_decimal=$((total_memory_gb_remainder * 100 / 1024))
        total_memory_formatted="$total_memory_gb.$total_memory_gb_decimal GB"
    else
        total_memory_formatted="$total_memory_mb_formatted MB"
    fi

    # Print total memory with unit
    printf "%-25s %-10s %-10s\n" "------------" "----------" "----------"
    printf "%-25s %-10s %-10s\n" "Total ($process_count procs)" "" "$total_memory_formatted"
}

# Check if a command-line argument is provided
if [ $# -gt 0 ]; then
    # Use the first command-line argument as the process name
    process_name="$1"
    calculate_memory "$process_name"
else
    # If no argument is provided, prompt the user for input
    echo "Enter the process name to search for (e.g., edge):"
    read process_name

    # Check if the user provided a non-empty input
    if [ -z "$process_name" ]; then
        echo "Error: No process name provided."
        exit 1
    fi

    calculate_memory "$process_name"
fi