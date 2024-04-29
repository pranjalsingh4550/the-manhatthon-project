class Word:
    def __init__(self, key: int, val: str):
        self.key:int = key
        self.val:str = val
class Sentence:
    def __init__(self, sent:list[Word], leng:int):
        self.mylist:list[Word] = sent
        self.myleng:int = leng
    def print(self):
        index_i: int = 0
        leng:int = self.myleng
        for index_i in range(leng):
            word_i:Word = self.mylist[index_i]
            print(index_i)
            # print(word_i.key)
            print(word_i.val)
def main():
    First: Word = Word(0, "First")
    Ninth: Word = Word(8, "Ninth") 
    Fifth: Word = Word(4, "Fifth") 
    Thirteenth: Word = Word(12, "Thirteenth") 
    Third: Word = Word(2, "Third")
    Eleventh: Word = Word(10, "Eleventh")
    Seventh: Word = Word(6, "Seventh")
    Fifteenth: Word = Word(14, "Fifteenth")
    Second: Word = Word(1, "Second")
    Tenth: Word = Word(9, "Tenth")
    Sixth: Word = Word(5, "Sixth")
    Fourteenth: Word = Word(13, "Fourteenth")
    Fourth: Word = Word(3, "Fourth")
    Twelfth: Word = Word(11, "Twelfth")
    Eighth: Word = Word(7, "Eighth")
    Sixteenth: Word = Word(15, "Sixteenth")
    mylist: list[Word] = [ #should be a list of pointers
    First,
    Ninth,
    Fifth,
    Thirteenth,
    Third,
    Eleventh,
    Seventh,
    Fifteenth,
    Second,
    Tenth,
    Sixth,
    Fourteenth,
    Fourth,
    Twelfth,
    Eighth,
    Sixteenth,
    ]
    index_i:int = 0
    index_j:int = 0
    mylen:int = len(mylist)
    for index_i in range(mylen):
        for index_j in range(mylen):
            if (index_j >= index_i):
                break
            word_i:Word = mylist[index_i]
            word_j:Word = mylist[index_j]
            if (word_i.key < word_j.key): #swap the pointers
                mylist[index_i] = word_j
                mylist[index_j] = word_i
    mysent: Sentence = Sentence(mylist, mylen)
    mysent.print()
if __name__ == "__main__":
    main()