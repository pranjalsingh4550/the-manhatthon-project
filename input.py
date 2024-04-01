
class A:
    def __init__(self, val:int):
        self.val:int=val
    def fun(self)->int:
        return 1

a:A = A(3)
b:int =a.fun()
