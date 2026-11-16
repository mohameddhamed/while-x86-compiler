CXX ?= g++
CXXFLAGS = -std=c++11 -Wall -Isrc
FLEX ?= flex
BISONCPP ?= bisonc++

SRC_DIR = src
RUNTIME_DIR = runtime
BIN_DIR = bin

TARGET = $(BIN_DIR)/while

all: $(TARGET) ./while

$(SRC_DIR)/lex.yy.cc: $(SRC_DIR)/while.l
	cd $(SRC_DIR) && $(FLEX) while.l

$(SRC_DIR)/parse.cc $(SRC_DIR)/Parserbase.h: $(SRC_DIR)/while.y
	cd $(SRC_DIR) && $(BISONCPP) while.y

$(TARGET): $(SRC_DIR)/lex.yy.cc $(SRC_DIR)/parse.cc $(SRC_DIR)/while.cc
	mkdir -p $(BIN_DIR)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC_DIR)/while.cc $(SRC_DIR)/parse.cc $(SRC_DIR)/lex.yy.cc

./while: $(TARGET)
	cp $(TARGET) ./while

test: $(TARGET)
	@bash -x tests/run_tests.sh $(TARGET)

clean:
	rm -rf $(BIN_DIR) ./while
	rm -f $(SRC_DIR)/lex.yy.cc $(SRC_DIR)/parse.cc $(SRC_DIR)/Parserbase.h $(SRC_DIR)/*~
	rm -f tests/*.asm tests/*.o tests/*.bin tests/*.out

.PHONY: all test clean
