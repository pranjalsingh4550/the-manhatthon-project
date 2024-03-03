def coprime (a:int, b:int) -> bool: # approach - iterate to min (sqrt (a), sqrt(b))
  if a == b:
    return False
  smaller:int = a
  if a>b:
    smaller = b
  iter:int = 2
  while (iter ** 2 < smaller):
    if a%iter == 0 and b%iter == 0:
      print (iter)
      return False
    else:
      iter += 1
  print ("Input numbers are coprime")
  return True

def eulerphi (a:int)->int: # computes the euler=phi function
  sum:int = 0
  t:int = 1;
  for t in range (1,a):
    if coprime (t,a):
      sum += 1
  return sum

def isprime (a:int)->int:
  iter:int = 2;
  while iter * iter < a:
    if a % iter == 0:
      return False
      break
    else:
      iter = iter + 1
  if iter ** 2 > a:
    return True

def euler_phi2 (a:int)->int: # computer euler-phi function using the formula
  b:int = a
  prime:int = 2
  power_of_prime:int = 0;
  result:int = 1
  while b > 1:
    if (isprime (prime) == False):
      prime += 1
      continue
    if b%prime == 0:
      b /= prime
    while (b % prime == 0):
      b/= prime
      result *= prime
    prime = prime + 1
  return result;

def main () ->bool:
  t:int = 1
  for t in range (1,100):
    if eulerphi(t) - euler_phi2(t):
      print ("Not matching")
      return False
  return True;

if __name__ == "__main__":
  main()
