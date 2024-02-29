def main():
  data: list[int] = [-2, 45, 0, 11, -9]
  bubbleSort(data)

  print('Sorted Array in Ascending Order:')
  i: int = 0
  for i in range(len(data)):
    print(data[i])
  

if __name__ == "__main__":
  main()
