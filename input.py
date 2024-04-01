val:float = 5.6
class A:
  def __init__(self,v:int):
    self.plusfive:int = val + 5
    self.true:bool = False
  def fun(self)->int:
    print(1)
    return self.val
  def checkbool(self)->bool:
    return self.true

a:A = A(3)
b:int =a.fun()

