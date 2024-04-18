def main():
    i:int = 0
    j: int = 2000
    while (i < j):
        i += 200
        while (j < 100):
            j += 1
        print(i)
        print(j)
    i = 0
    while (i < 2):
        j = 0
        while (j < 2):
            k: int = 0
            while k < 2:
                l: int = 0
                while l < 2:
                    print("a")
                    print("")
                    l +=1
                k += 1
            j += 1
        i += 1
    print(k)
    print(l)
    i = 0
    j = 0
    while i < 5 or j < 1000 and True:
        i += 1
        j += i
        print(j)
if __name__ == "__main__":
    main()