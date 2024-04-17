
def true_false()->None:
	if True:
		print ("This should be printed")
		l:int = 15
		while l:
			print ("l is ")
			print (l)
			if l%4 == 1:
				l = l-1
			else if l%4 == 2:
				l = l - 2
			else:
				l = l/2
		print (True)
	else if (5**2 > 45)
		print ("5**2 is greater than 45")
	else if 2**5 == 45:
		k:int = 231
		print ("I think 2^5 equals 45")
	return

def fun3(o:bool)->int:
	f:int = o
	a:int = f << 5
	f += a
	if f//a == 2:
		return True
	else if f // a == 3:
		return 1
	return False

def main():
	true_false()
	
	i:bool = fun3(False)


if __name__ == "__main__":
	main()
