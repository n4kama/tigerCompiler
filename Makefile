CXX = g++
CXXFLAGS = -std=c++17



all:
	bison -o src/parse.cc src/parse.yy
    flex -o src/scan.cc src/scan.ll
    g++ -std=c++17 -o tc src/scan.cc src/parse.cc

clean:
        $(RM) tc