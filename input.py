a:int=0

def fun():
  global a;
  a = 5;

def main():
  global a
  a = 10

if __name__ == "__main__":
  main()
  fun()
