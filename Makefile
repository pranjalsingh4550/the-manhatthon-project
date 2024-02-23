
.PHONY: clean test
clean:
	rm -f a.out lex.yy.c converter.exe lexer

lexer:
	flex lexer.l
	g++ -o lexer lex.yy.c main.c

test:
	flex lexer.l
	g++ -o lexer lex.yy.c main.c
	./lexer < test.py
	rm -f lexer lex.yy.c
