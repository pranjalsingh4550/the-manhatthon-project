#simple recursion
def factorial(n:int)->int:
    if (n <= 0):
        return 1
    return n*factorial(n-1)
#two recursion
def fibo(n: int) -> int:
    if n <= 0:
        return 1
    ret:int = fibo(n - 1) + fibo(n - 2)
    return ret

def main():
    i:int =0
    for i in range(10):
        print(factorial(i))
    for i in range(10):
        print(fibo(i))

if __name__ == "__main__":
    main()
    
