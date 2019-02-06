CXX = g++
CXXFLAGS = -std=c++17

all:
	flex -o src/scan.cc src/scan.ll
	bison -o src/parse.cc src/parse.yy
	g++ -std=c++17 -o tc src/scan.cc src/parse.cc
clean:
	$(RM) tc src/scan.cc src/parse.cc