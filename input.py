def bubbleSort(array: list[int]) -> None:
    i: int = 0
    # n: int = len(array)
    for i in range(10):
      swapped: bool = False
      j: int = 0
      for j in range(0, 20):
        if array[j] > array[j + 1]:
          temp: int = array[j]
          array[j] = array[j + 1]
          array[j + 1] = temp
          swapped = True
      if not swapped:
        break

def main():
    data: list[int] = [-2, 45, 0, 11, -9]
    # bubbleSort(data)

    # print('Sorted Array in Ascending Order:')
    i: int = 0
    # n:int= len(data)
    for i in range(10):
    #   print(data[i])
        j:int = data[i]
    

if __name__ == "__main__":
    main()
