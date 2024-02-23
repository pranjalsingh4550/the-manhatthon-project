#!/bin/bash

bison -d parser.y
if [ $? -ne 0 ]; then
    echo "Error in bison"
    exit 1
fi

flex lexer.l

if [ $? -ne 0 ]; then
    echo "Error in flex"
    exit 1
fi

g++ parser.tab.c lex.yy.c -lfl

if [ $? -ne 0 ]; then
    echo "Error in g++"
    exit 1
fi

if [ $# -eq 0 ]; then
    ./a.out < input.py
    exit 1
else
    ./a.out < $1
    exit 1
fi
