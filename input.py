
class A:
    def __init__(self,val:int):
        self.val=val
    def fun(self)->int:
        return self.val+5

a:A = A(2)
b:int =a.fun()
