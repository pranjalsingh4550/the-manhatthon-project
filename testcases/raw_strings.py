#Deven string test suite
"""hello \ """


#all should pass
1 #normal
"lol"
2 #normal with escaped chars
"lol\n"
3 #normal with escaped string
"lol\""
4 #normal with line continuation
"lol\
lol\
lol"
5 #raw
r"lol"
5.5
R"lol"
6 #raw with backslashes
r"lol\\"
6.5
r"lol\""
7 #triple
"""lol"""
8 #triple with quotes
"""lol"lol""lol"""
9 #triple with newline
"""lol
lol"""
10 #triple with backslash and newline
"""lol  \   
lol"""
10.5
"""lol
\ lol"""
11 #triple with backslash quotes
"""lol\"""lol"""
11.5
"""lol"\""lol"""
