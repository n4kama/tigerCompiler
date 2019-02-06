CXX = g++
CXXFLAGS = -std=c++17

EXEC =
SRC =
EXEC_OBJS=

all: $(EXEC) $(SRC)

$(EXEC): $(EXEC_OBJS)
        $(CXX) $(CXXFLAGS) -o $@ $(SRC)

clean:
        $(RM) $(EXEC) $(EXEC_OBJS)