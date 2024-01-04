def count_ascending_runs(nums):
    if not nums:
        return 0

    runs = 1
    for i in range(1, len(nums)):
        if nums[i] > nums[i - 1]:
            runs += 1

    return runs

# Example usage
numbers = [1, 2, 3, 5, 2, 4, 6, 8, 10]
result = count_ascending_runs(numbers)
print(f"Number of ascending runs in the input sequence: {result}")
