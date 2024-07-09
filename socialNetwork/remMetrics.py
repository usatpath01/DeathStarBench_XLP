import sys

def min_elements_to_remove(filename):
    with open(filename, 'r') as file:
        numbers = [int(line.strip()) for line in file]
    if not numbers:
        return 0

    n = len(numbers)
    lis = [1] * n

    for i in range(1, n):
        for j in range(0, i):
            if numbers[i] > numbers[j] and lis[i] < lis[j] + 1:
                lis[i] = lis[j] + 1

    max_lis = max(lis)
    return n - max_lis

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <filename>")
    else:
        filename = sys.argv[1]
        result = min_elements_to_remove(filename)
        print(f"Minimum elements to remove for the largest increasing subsequence: {result}")
