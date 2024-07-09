import sys
import re
import json

def extract_ids_from_log(log_file):
    # Regular expression pattern to extract IDs from application logs
    id_pattern = r'ID\s*:\s*(\d+)'
    
    # Dictionary to store unique IDs along with their associated host_pid and host_tid pairs
    id_host_map = {}

    # Read each line from the log file
    with open(log_file, 'r') as file:
        for line in file:
            # Check if the line starts with "Host"
            line = line.strip()
            if line.startswith("Host"):
                try:
                    line = ''.join(line.rsplit(',', 1))
                    host_id = int(line.split(" ")[1])
                    # print(f'This is host_id {host_id}')
                    json_data = json.loads(line.split(":", 1)[1].strip())
                    # print(f'This is json data : {json_data}')
                    host_pid = json_data["event_context"]["task_context"]["host_pid"]
                    host_tid = json_data["event_context"]["task_context"]["host_tid"]
                    ids = re.findall(id_pattern, line)
                    for id in ids:
                        if id not in id_host_map:
                            id_host_map[id] = set()
                        id_host_map[id].add((host_id,host_pid, host_tid))
                except (json.JSONDecodeError, KeyError) as e:
                    print(f"Error extracting data from line: {line.strip()}, {e}")
                    continue
                except Exception as e:
                    print(f"Error processing line: {line.strip()}, {e}")
                    continue

    return id_host_map

def extract_logs_with_host(log_file, id_host_map):
    # Regular expression pattern to extract IDs from application logs
    id_pattern = r'ID\s*:\s*(\d+)'
    
    # Read each line from the log file
    with open(log_file, 'r') as file:
        
        for line in file:
            line = line.strip()
            # Check if the line starts with "Host"
            if line.startswith("Host"):
                try:
                    line = ''.join(line.rsplit(',', 1))
                    host_id = int(line.split(" ")[1])
                    # Extract JSON data from the line
                    json_data = json.loads(line.split(":", 1)[1].strip())
                    host_pid = json_data["event_context"]["task_context"]["host_pid"]
                    host_tid = json_data["event_context"]["task_context"]["host_tid"]
                    ids = re.findall(id_pattern, line)
                    for id, host_set in id_host_map.items():
                        if (host_id,host_pid, host_tid) in host_set:
                            yield line
                except (json.JSONDecodeError, KeyError) as e:
                    print(f"Error extracting data from line: {line.strip()}, {e}")
                    continue
                except Exception as e:
                    print(f"Error processing line: {line.strip()}, {e}")
                    continue

if __name__ == "__main__":
    # Check if the user provided a command-line argument
    if len(sys.argv) != 2:
        print("Usage: python script.py <log_file>")
        sys.exit(1)

    # Get the log file path from the command-line argument
    log_file_path = sys.argv[1]

    # Extract unique IDs along with their associated host_pid and host_tid pairs
    id_host_map = extract_ids_from_log(log_file_path)

    # Extract logs associated with each host_pid and host_tid pair for each unique request ID
    for id, host_set in id_host_map.items():
        # Generate filename for each request ID
        filename = f"{id}_logs.txt"
        # Open the file for writing
        with open(filename, 'w') as file:
            # Write logs associated with each host_pid and host_tid pair to the file
            for log in extract_logs_with_host(log_file_path, id_host_map):
                file.write(log+'\n')
