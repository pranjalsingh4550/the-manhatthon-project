def add1(mylist:list[int]) -> None:
    i:int = 0
    g:float
    t:str
    u:bool
    uu:int

    for i in range(n):
        mylist[i]+=1

def main():
    hey :list[int] = [1,2,3,4,5]

    b:int=3

    add1(hey)
    print(hey[0])

if __name__ == "__main__":
    main()

