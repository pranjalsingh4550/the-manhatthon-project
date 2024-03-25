

class Parent():
    def __init__(self):
        self.b:int=5


class Child(Parent):    
    def __init__(self):
        self.d:int=5

line:int = 12
line2:int = 13

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
class mm:
	def __init__(self):
		self.a:int = 1

myobj:mm

