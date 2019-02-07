all:
	flex -o src/scan.cc src/scan.ll
	bison -d -o src/parse.cc src/parse.yy
	g++ -o tc -std=c++17 src/scan.cc src/parse.cc
clean:
	$(RM) tc src/scan.cc src/parse.cc src/parse.hh src/position.hh src/stack.hh