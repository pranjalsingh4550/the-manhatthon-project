base: parser

.PHONY: clean test run debug temp
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser temp.pdf

parser: clean
	bison -d parser.y
	flex lexer.l
	g++ -o parser lex.yy.c parser.tab.c


debug: test
	# only to annotate the output log
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt

test: parser
	./parser -output ast.dot < input.py 2>output.txt
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser
	rm -f lexer lex.yy.c parser.t* parser

run: parser
	./parser < input.py 2>output.txt
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser
	rm -f lexer lex.yy.c parser.t* parser

temp:
	# run parser but don't recompile it. temp is the pdf's name
	./parser < input.py 2>output.txt
	sed -i 's/Shifting/=======================================+\nShifting/; s/^->/\t\t->/' output.txt
	dot -Tpdf -Gordering=out ast.dot > temp.pdf

