def check_ipv6_addr(t:str)->bool:
  block:int = 0;
  for block in range(8): 
    length:int = 0
    for length in range(len(t)):
      if t[length] == ".":
        break;
    if length == 0: # invalid
      return False
    if length >3: break
    code:int = 0
    while length > 0:
      code = code * 10
      code += ord(t[length - 1]) - ord ('0')
      length -= 1;
    if code > 255:
      return False
    t = t[length + 1]
  print ("Valid IP address")
  return True


def convert_ipv6_to_hex(t:str)->str:
  block:int = 0;
  retstr:str = ""
  for block in range(8): 
    length:int = 0
    for length in range(len(t)):
      if t[length] == ".":
        break;
    if length == 0: # invalid
      return False
    if length >3: break
    code:int = 0
    while length > 0:
      code = code * 10
      code += ord(t[length - 1]) - ord ('0')
      length -= 1;
    if code > 255:
      return ''
    retstr += str (code // 16);
    retstr += str (code % 16);
    retstr += ":"
    t = t[length + 1]
  return retstr

def main():
  ip:str = "avd"
  print (check_ipv6_addr(ip))
  
if __name__ == "__main__":
  main()
