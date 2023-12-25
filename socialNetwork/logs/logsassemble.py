import os
import re
import json
from datetime import datetime

# Function to extract timestamps from a line
def extract_timestamp(line):
    timestamp_patterns = [
        r'(\d{2} \w{3} \d{4} \d{2}:\d{2}:\d{2}\.\d{3})',  # Type 1 timestamp pattern
        r'"t":{"\$date":"(.*?)"'  # Type 2 timestamp pattern
    ]
    
    for pattern in timestamp_patterns:
        match = re.search(pattern, line)
        if match:
            timestamp_str = match.group(1)
            try:
                return datetime.strptime(timestamp_str, '%d %b %Y %H:%M:%S.%f') if pattern == timestamp_patterns[0] else datetime.strptime(timestamp_str, '%Y-%m-%dT%H:%M:%S.%f%z')
            except ValueError:
                return None
    return None

# Function to process a text file
def process_file(file_path):
    logs = []
    with open(file_path, 'r') as file:
        for line in file:
            timestamp = extract_timestamp(line)
            if timestamp:
                logs.append({'timestamp': timestamp.strftime('%Y-%m-%d %H:%M:%S'), 'log': line.strip(), 'file': os.path.basename(file_path)})
    return logs

# Main function
def main():
    print("Welcome to the Log Processor!")

    # Get input file paths from the user
    input_files = []
    while True:
        file_path = input("Enter the path of an input text file (or 'done' to finish): ")
        if file_path.lower() == 'done':
            break
        if os.path.exists(file_path):
            input_files.append(file_path)
        else:
            print("File not found! Please provide a valid file path.")

    if not input_files:
        print("No valid input files provided. Exiting.")
        return

    output_file = input("Enter the name of the output JSON file (e.g., logs.json): ")

    all_logs = []
    for file_name in input_files:
        logs = process_file(file_name)
        all_logs.extend(logs)

    all_logs.sort(key=lambda x: x['timestamp'])  # Sort logs by timestamp

    with open(output_file, 'w') as json_file:
        json.dump(all_logs, json_file, indent=4)

    print(f"Logs have been processed and saved to {output_file}")

if __name__ == "__main__":
    main()
