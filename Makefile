base: parser

.PHONY: clean test run temp
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser temp.pdf output.txt ast.dot debug.txt parser.output

parser: clean
	bison -d parser.y
	flex lexer.l
	g++ -o parser lex.yy.c parser.tab.c 

test: parser
	./parser -verbose shift -output ast.dot < input.py 2>output.txt
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf 
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser output.txt

temp:
	# run parser but don't recompile it. temp is the pdf's name
	./parser < input.py 2>output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf

