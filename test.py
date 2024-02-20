
def fun():
    day=int()
    month=int()
    year=int()
    hour=int()
    minute=int()
    second=int()
    if 1900 < year < 2100 and 1 <= month <= 12 \
    and 1 <= day <= 31 and 0 <= hour < 24 \
    and 0 <= minute < 60 and 0 <= second < 60:   # Looks like a valid date
        return 1
    else:
        return 0
      
        # vflerlfluibf79# asf3##33sdfsadg
print(fun())
