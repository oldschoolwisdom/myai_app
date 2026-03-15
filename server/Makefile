BIN := sdk-server
SRC := $(wildcard *.go)

.PHONY: build clean run

build: $(BIN)

$(BIN): $(SRC)
	go build -o $(BIN) .

clean:
	rm -f $(BIN)

run: build
	./$(BIN)
