def min_elements_to_remove(nums):
    if not nums:
        return 0

    n = len(nums)
    lis = [1] * n

    for i in range(1, n):
        for j in range(0, i):
            if nums[i] > nums[j] and lis[i] < lis[j] + 1:
                lis[i] = lis[j] + 1

    max_lis = max(lis)
    return n - max_lis

# Example usage
numbers = [10, 22, 9, 33, 21, 50, 41, 60, 80]
result = min_elements_to_remove(numbers)
print(f"Minimum elements to remove for the largest increasing subsequence: {result}")
