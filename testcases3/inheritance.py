class creature : 
	def __init__ (self, name:str, lifespan:int, flies:bool, beautiful:bool, dangerous:bool, colour:str):
		self.name:str = name
		self.lifespan:int = lifespan
		self.beautiful:bool = beautiful
		self.dangerous:bool = dangerous
		self.colour:str = colour
		self.huge:bool = self.lifespan == lifespan
		self.huge = self.huge and self.lifespan > 50
		self.huge = self.huge and self.beautiful == False
	def set_lifespan(self, l:int):
		print ("I don't trust your input")
		self.lifespan = l * 2
		print ("I have set lifespan to ")
		print (self.lifespan)
	def is_cunning(self)->bool:
		if self.beautiful and self.dangerous:
			print ("this is a cunning animal: beautiful but dangerous")
			print (self.name)
			return True
		elif self.beautiful:
			print ("This is beautiful and innocuous:")
			print (self.name)
			return False
		return False

class vertebrate (creature):
	def __init__ (self, mammal:bool, habitat:str):
		self.is_mammal:bool = mammal
		self.habitat:str = habitat
		if self.habitat == "forest" and self.is_mammal:
			print ("Assuming this is a lion")
		self.name = "lion"
	
	def is_domestic(self)->bool:
		if self.habitat == "forest":
			return False
		if not self.is_mammal:
			return False
		return True

class reptile (vertebrate):
	def __init__ (self, color:str, habitat:str):
		self.colour = color
		self.habitat = habitat
		self.disgusting:bool = True
		print ("Hello, I am a disgusting reptile");
	def set_croc(self):
		self.name = "crocodile"
		self.disgusting = False
		print ("Crocodiles are too scary for you to get disgusted\n")


def main():
	giraffe:vertebrate = vertebrate(9, "forest")
	giraffe.dangerous = 1 and 0
	giraffe.huge = 1 and 2
	giraffe.colour = "yellow"

	bison:creature = creature("bison", 40, False, True, True, "unknown")
	if bison.dangerous == giraffe.dangerous:
		print ("Bisons and giraffes are equally dangerous")
	elif bison.dangerous > giraffe.dangerous:
		print ("Avoid bisons and flexes but not girrafes")

	if bison.huge:
		print ("bisons are huge")
	else:
		print ("bisons are not huge")
	
	dirt:str = "dirt"
	mystery:reptile = reptile("brown", dirt);
	if mystery.lifespan > 40:
		print ("\"Mystery\" is a disgusting reptile that doesn't die too fast\n");
		mystery.set_croc()

	else:
		mystery.name = "lizard"
		mystery.habitat = "anywhere"
		mystery.lifespan = 3
	if mystery.is_domestic():
		print ("The garbagee values in x86 think this is a domestic creature\n")
		print ("** demonstrating inheritance of methods: multiple call sites\n")

	m2:reptile = mystery
	mystery.set_croc()
	m2.set_croc()
	print ("Passing by reference: mystery's name has been set")
	print (mystery.name)
	print (mystery.disgusting)
	
if __name__ == "__main__":
	main()

