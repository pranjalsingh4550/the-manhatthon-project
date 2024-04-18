def check_ops()->bool:
	if not (44 and 3):
		return False
	l:bool = 44 or 3
	if l == False:
		return False
	k:int = 77 >> 4;
	k = k ** 2
	if not k == 361: return False

	k = 64 & 511
	k = ~k # 1's complement: -65
	if not k +65: return False

	k *= -1
	if not k - 65:
		return False
	return True
	u:int = k % 1034;
	if not k==65:
		return False
	u = k % 4
	o1:str = "this is o1"
	o2:str = "o2"
	o3:str = "o3"
	ll:list[str] = [o1, o2, o3, o1, o2, o3]
	e:str = ll[u]
	print(e)
	print("expecting output o2")
	if not (u ** k == u):
		return False
	e <<= 10
	print(e)
	print ("Expecting value 1024")
	e **= 0
	if not e - 1:
		return False
	return True

def main():
	bool t = check_ops();
	print (t)
		
