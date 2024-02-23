
.PHONY: clean test
clean:
	rm -f a.out lex.yy.c converter.exe lexer

lexer:
	flex lexer.l
	g++ -o lexer lex.yy.c main.c

test:
	bison -d parser.y
	if [ $? -ne 0 ]; then exit 1; fi
	flex lexer.l
	if [ $? -ne 0 ]; then exit 1; fi
	g++ -o lexer lex.yy.c parser.tab.c
	if [ $? -ne 0 ]; then exit 1; fi
	./lexer < input.py
	rm -f lexer lex.yy.c parser.t* 
