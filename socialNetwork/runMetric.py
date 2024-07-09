import sys

def count_ascending_runs(filename):
    with open(filename, 'r') as file:
        numbers = [int(line.strip()) for line in file]
    if not numbers:
        return 0

    runs = 1
    for i in range(1, len(numbers)):
        if numbers[i] > numbers[i - 1]:
            runs += 1

    return runs

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <filename>")
    else:
        filename = sys.argv[1]
        result = count_ascending_runs(filename)
        print(f"Number of ascending runs in the input sequence: {result}")
