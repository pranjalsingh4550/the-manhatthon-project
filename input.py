class myClass():
    def __init__(self, cur:int):
        self.num :int = cur
    def hello(self)->int:
        return 1


def main():
    a:int=5
    obj: myClass = myClass(32)
    obj.num=5
    g:int =obj.hello()
