class thing:
    def __init__(self, val: int):
        self.val:int = val
def thing_extractor(mything: thing) -> int:
    return mything.val
def main():
    _1:thing = thing(1)
    _2:thing = thing(2)
    _3:thing = thing(3)
    _4:thing = thing(4)
    _5:thing = thing(5)
    _6:thing = thing(6)
    _7:thing = thing(7)
    _8:thing = thing(8)
    _9:thing = thing(9)
    _10:thing = thing(10)
    _11:thing = thing(11)
    _12:thing = thing(12)
    _13:thing = thing(13)
    _14:thing = thing(14)
    _15:thing = thing(15)
    _16:thing = thing(16)
    _17:thing = thing(17)
    _18:thing = thing(18)
    _19:thing = thing(19)
    _20:thing = thing(20)    
    mylist: list[thing] = [
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,
    _9,
    _10,
    _11,
    _12,
    _13,
    _14,
    _15,
    _16,
    _17,
    _18,
    _19,
    _20,
    ]
    mylen:int = len(mylist) - 1
    while mylen >= 0:
        if mylen == 5:
            print("Haha")
            mylen -= 1
            continue
        a_thing: thing = mylist[mylen]
        myval: int = thing_extractor(a_thing)
        print(myval)
        mylen = mylen - 1

if __name__ == "__main__":
    main()