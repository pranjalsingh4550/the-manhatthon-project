#simple recursion
def factorial(n:int)->int:
    print(n)
    if (n <= 0):
        return 1
    return n*factorial(n-1)
#two recursion
def fibo(n: int) -> int:
    print(n)
    if n <= 0:
        return 1
    ret:int = fibo(n - 1) + fibo(n - 2)
    return ret
#partition
# def partition(mylist:list[int], idx: int):
#     length: int = len(mylist)
#     val: int = mylist[idx]
#     mylist[idx] = mylist[0]
#     mylist[0] = val
#     start: int = 1
#     end: int = len(mylist) - 1
#     while (start < end):
#         if (mylist[start] < val):
#             start += 1
#             continue
#         if (mylist[end] > val):
#             end -= 1
#             continue
#         temp:int = mylist[start]
#         mylist[start] = mylist[end]
#         mylist[end] = temp
#     mylist[0] = mylist[start]
#     mylist[start] = val
#quicksort
def main():
    fact:int = factorial(10)
    print(fact)
    fib:int = fibo(10)
    print(fib)
    # mylist:list[int] = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]
#     mylen: int = len(mylist)
#     partition(mylist, 1)
#     i: int = 0
#     for i in range(mylen):
#         print(mylist[i])
if __name__ == "__main__":
    main()
    
    