

class Parent():
    a:int=5
    def __init__(self):
        self.b:int=5


class Child(Parent):    
    c:int=5
    def __init__(self):
        self.d:int=5
        super().__init__()


def main():
    p:Parent = Parent()
    print(p.a)
    print(p.b)
    c:Child = Child()
    print(c.a)
    print(c.b)
    print(c.c)
    print(c.d)

if __name__ == "__main__":
    main()
