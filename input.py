class person ():
  def __init__ (self,nameparam:str, advname:str, degree:str):
    self.name :str= nameparam
    self.advisor:str = advname;
    # self.namelen:str = len(nameparam)
    self.namelen:str = "len not working on strings"
    self.degree:str = degree
    if degree >= "BTech":
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

# def main():
#   a:int=5


# if __name__ == "__main__":
# 	main()
