all:
	flex -o src/parse/scan.cc src/parse/scan.ll
	bison -d -o src/parse/parse.cc src/parse/parse.yy
	g++ -o tc -std=c++17 src/parse/scan.cc src/parse/parse.cc
clean:
	$(RM) tc src/parse/scan.cc src/parse/parse.cc src/parse/parse.hh src/parse/position.hh src/parse/stack.hh