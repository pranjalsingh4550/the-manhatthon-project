class person (name:str, advisor:str):
	name:str
	advisor:str
	namelen:int
	degree:str
	def __init__ (nameparam:str, advname:str, degree:str)->None:
		self.name = nameparam
		self.advisor = advname;
		self.namelen = len(nameparam)
		self.degree = degree
		if degree not in ["BTech", "MTech", "PhD", "MSR", "eMasters"]:
			print ("Invalid degree")
			print (degree)
	def print_namelen_with():
		print (self.namelen)

class TA (person, course:str):
	def __init__ (course:str, name:str):
		self.course = course
		self.name = name;
		if name == "Binong": namelen = 7;
		if name == "Binong":
			advisor = "Debadatta Mishra, Swarnendu Biswas"
		elif name[0:3] == "Dev":
			advisor = "Binong"
		else:
			advname = "N/A"
		if len(course) > 6:
			print ("Invalid Course Code"); print (course)
	def check_course_level()->:
		if self.course[2] >= 6:
			print ("PG course")
		else if self.course[2] == "4":
			print ("Basket course: CS4xx series")
		else if self.course[2] == "3":
			print ("Basket A course or UG DC course")
		else if self.course[2] == "2":
			print ("UG Department Compulsory course")
			print ("Possibilities: CS20(1|2|3), CS220, CS253")
		else if self.course[2] == "1":
			print ("Undergraduate Institute Core course")

if __name__ == "__main__":
	main()

