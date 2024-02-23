
base: test

.PHONY: clean test
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* 

test: clean
	bison -d parser.y
	flex lexer.l
	g++ -o lexer lex.yy.c parser.tab.c
	./lexer < input.py
	rm -f lexer lex.yy.c parser.t*
