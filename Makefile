base: parser

.PHONY: clean test run temp
clean:
	rm -f a.out lex.yy.c converter.exe lexer parser.t* parser temp.pdf output.txt ast.dot debug.txt parser.output

parser: clean
	bison -d  -t -v parser.y
	flex lexer.l
	g++ -g -o parser lex.yy.c parser.tab.c -fmax-errors=6 

test: parser
	./parser -input input.py
	gcc -g output.s -o elf_exe

do : test
	gcc -g output.s

done: do
	./a.out
temp:
	./parser < input.py
	gcc -g output.s
	./a.out

my: parser

	./parser < input.py 2>debug.txt

