
base: test

.PHONY: clean test
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser

parser: clean
	bison -d parser.y
	flex lexer.l
	g++ -o parser lex.yy.c parser.tab.c
1=errors-put.txtfmax-	

test: parser
	./parser < input.py 2>output.txt
	rm -f lexer lex.yy.c parser.t* parser
