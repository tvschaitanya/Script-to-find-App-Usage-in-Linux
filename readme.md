# Process Memory Usage Monitor

A pure Bash script to monitor and calculate the total memory usage of processes on macOS, designed for testing and comparing applications like browsers, with a compact and sorted tabular output.

## Overview

This script helps users analyze the memory usage of processes on macOS by searching for processes by name and displaying their memory usage, process IDs (PIDs), and a total memory summary. It was created to simplify the process of comparing memory usage across applications, such as testing different web browsers (e.g., Chrome, Firefox, Safari) using the Activity Monitor. Instead of manually calculating memory usage, this script automates the process, providing a sorted list of processes and their total memory consumption in a terminal-friendly format.

## Features

- **Dynamic Input**: Accepts process names via command-line arguments or interactive prompts.
- **Sorted Output**: Processes are sorted by memory usage (highest to lowest).
- **Compact Display**: 
  - Process names are truncated to fit within a 25-character column, with an ellipsis (`...`) for longer names.
  - Removes common prefixes (e.g., "Google Chrome") to minimize repetitive text in process names.
  - Total table width is 45 characters, fitting well in most terminal windows.
- **PID Inclusion**: Displays the process ID for each process.
- **Memory Units**: Shows individual process memory in MB and the total memory in MB or GB, depending on the size.
- **No Dependencies**: Written in pure Bash, using only standard Unix tools (`ps`, `grep`, `awk`, `xargs`, `sort`, `mktemp`, `head`).

## Use Case

This script is particularly useful for:
- **Comparing Browsers**: When testing web browsers on macOS, you can quickly calculate the total memory usage of all related processes (e.g., "Chrome", "Firefox", "Safari") without manually adding up values in Activity Monitor.
- **Monitoring Applications**: Analyze the memory footprint of any application by searching for its process name.
- **Performance Testing**: Identify which processes are consuming the most memory, helping with optimization and debugging.

## Requirements

- **Operating System**: macOS (tested on macOS with `ps -A` command). For Linux, you may need to adjust the `ps` command (e.g., `ps -eo rss,pid,comm`).
- **Tools**: Standard Unix tools (`bash`, `ps`, `grep`, `awk`, `xargs`, `sort`, `mktemp`, `head`) must be available, which they typically are on macOS and most Unix-like systems.
