val:float = 5.6
class A:
	def __init__(self,v:int):
		self.plusfive:int = v + 5
		self.true:bool = False
	def fun(self)->int:
		return self.val
	def checkbool(self)->bool:
		return self.true

def main():
	a:A = A(3)
	a.true= a.fun()

if __name__ == "__main__":
    	main()
