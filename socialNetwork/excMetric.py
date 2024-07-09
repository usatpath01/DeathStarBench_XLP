import sys

def min_swaps_to_sort(filename):
    with open(filename, 'r') as file:
        numbers = [int(line.strip()) for line in file]

    sorted_numbers = sorted(enumerate(numbers), key=lambda x: x[1])
    index_mapping = {value: index for index, (original_index, value) in enumerate(sorted_numbers)}

    swaps = 0
    visited = [False] * len(numbers)

    for i in range(len(numbers)):
        if visited[i] or index_mapping[numbers[i]] == i:
            continue

        cycle_size = 0
        j = i
        while not visited[j]:
            visited[j] = True
            j = index_mapping[numbers[j]]
            cycle_size += 1

        if cycle_size > 0:
            swaps += (cycle_size - 1)

    return swaps

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script_name.py <filename>")
    else:
        filename = sys.argv[1]
        result = min_swaps_to_sort(filename)
        print(f"Minimum number of swaps required to sort the numbers: {result}")
