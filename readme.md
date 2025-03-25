# Process Memory Usage Monitor

A pure Bash script to monitor and display the memory usage of processes on macOS, with support for dynamic user input, sorting, and a compact tabular output.

## Overview

This script allows users to search for processes by name (e.g., "edge" for Microsoft Edge) and displays a sorted list of matching processes with their memory usage, process IDs (PIDs), and a total memory summary. It is designed to be lightweight, dependency-free, and terminal-friendly, with a focus on usability and readability.

## Features

- **Dynamic Input**: Accepts process names via command-line arguments or interactive prompts.
- **Sorted Output**: Processes are sorted by memory usage (highest to lowest).
- **Compact Display**: 
  - Process names are truncated to fit within a 25-character column, with an ellipsis (`...`) for longer names.
  - Removes common prefixes (e.g., "Microsoft Edge") to minimize repetitive text in process names.
  - Total table width is 45 characters, fitting well in most terminal windows.
- **PID Inclusion**: Displays the process ID for each process.
- **Memory Units**: Shows individual process memory in MB and the total memory in MB or GB, depending on the size.
- **No Dependencies**: Written in pure Bash, using only standard Unix tools (`ps`, `grep`, `awk`, `xargs`, `sort`, `mktemp`, `head`).

## Requirements

- **Operating System**: macOS (tested on macOS with `ps -A` command). For Linux, you may need to adjust the `ps` command (e.g., `ps -eo rss,pid,comm`).
- **Tools**: Standard Unix tools (`bash`, `ps`, `grep`, `awk`, `xargs`, `sort`, `mktemp`, `head`) must be available, which they typically are on macOS and most Unix-like systems.
