# ref: https://vic.demuzere.be/articles/golang-makefile-crosscompile/

G := $(shell go version | cut -d' ' -f 3,4 | sed 's/ /_/g')
V := $(shell git rev-parse --short HEAD)
APPVER := $(shell grep version cmd/root.go | cut -d \" -f2)
PWD := $(shell pwd)
LD_FLAGS := -ldflags="-s -w -X=github.com/sensepost/gowitness/cmd.gitHash=$(V) -X=github.com/sensepost/gowitness/cmd.goVer=$(G)"
BIN_DIR := build

default: clean generate darwin linux windows integrity

clean:
	$(RM) $(BIN_DIR)/gowitness*
	go clean -x

install:
	go install

generate:
	cd web && go generate && cd -

darwin:
	GOOS=darwin GOARCH=amd64 go build $(LD_FLAGS) -o '$(BIN_DIR)/gowitness-$(APPVER)-darwin-amd64'

linux:
	GOOS=linux GOARCH=amd64 go build $(LD_FLAGS) -o '$(BIN_DIR)/gowitness-$(APPVER)-linux-amd64'

windows:
	GOOS=windows GOARCH=amd64 go build $(LD_FLAGS) -o '$(BIN_DIR)/gowitness-$(APPVER)-windows-amd64.exe'

docker:
	go build $(LD_FLAGS) -o gowitness

docker-image:
	docker build -t gowitness:local .

integrity:
	cd $(BIN_DIR) && shasum *

release:
	docker run --rm -v $(PWD):/usr/src/myapp -w /usr/src/myapp golang:1 make
