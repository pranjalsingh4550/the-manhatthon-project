base: parser

.PHONY: clean test run temp
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser temp.pdf output.txt ast.dot debug.txt parser.output

parser: clean
	bison -d  -t -v parser.y
	flex lexer.l
	g++ -g -o parser lex.yy.c parser.tab.c -fmax-errors=6 

test: parser
	./parser  -output ast.dot < input.py 2>output.txt
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf 
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser output.txt

temp:
	# run parser but don't recompile it. temp is the pdf's name
	./parser < input.py 2>output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf

my: parser

	./parser < input.py 2>debug.txt

