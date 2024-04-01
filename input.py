val:float = 5.6
class A:
	def __init__(self,v:int):
		self.plusfive:int = val + 5
		self.true:bool = False
	def fun(self)->int:
		return self.val
	def checkbool(self)->bool:
		return self.true
    def __init__(self, val:int):
        self.val:int=val
    def fun(self)->int:
        return 1

a:A = A(3)
b:int =a.fun()

