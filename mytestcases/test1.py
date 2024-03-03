class person ():
  name=str
  advisor=str
  namelen=int
  degree=str
  def __init__ (self,nameparam:str, advname:str, degree:str):
    self.name = nameparam
    self.advisor = advname;
    self.namelen = len(nameparam)
    self.degree = degree
    if degree not in ["BTech", "MTech", "PhD", "MSR", "eMasters"]:
      print ("Invalid degree")
    print (degree)
  def print_namelen_with(self):
    print (self.namelen)

class TA (person):
  def __init__ (self,course:str, name:str):
    self.course = course
    self.name = name;
    if name == "Binong": namelen = 7;
    if name == "Binong":
      advisor = "Debadatta Mishra, Swarnendu Biswas"
    elif name[1] == "Dev":
      advisor = "Binong"
    else:
      advname = "N/A"
    if len(course) > 6:
      print ("Invalid Course Code"); print (course)
  def check_course_level(self)->None:
    if self.course[2] >= "6":
      print ("PG course")
    elif self.course[2] == "4":
      print ("Basket course: CS4xx series")
    elif self.course[2] == "3":
      print ("Basket A course or UG DC course")
    elif self.course[2] == "2":
      print ("UG Department Compulsory course")
      print ("Possibilities: CS20(1|2|3), CS220, CS253")
    elif self.course[2] == "1":
      print ("Undergraduate Institute Core course")

def main():
  obj:TA = TA("CS600", "Binong")
  obj.print_namelen_with()
  obj.check_course_level()
  obj:TA = TA("CS300", "Dev")
  obj.print_namelen_with()
  obj.check_course_level()


if __name__ == "__main__":
	main()

