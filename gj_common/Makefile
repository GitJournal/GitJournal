CC=clang

test: gitjournal.c test.c keygen.c common.c
	$(CC) -o test -g test.c common.c gitjournal.c keygen.c -lgit2 -lssl -lcrypto

build-env: Dockerfile
	docker build -t gitjournal_lib .

shell:
	docker run --rm -it -v `pwd`:/code -w /code gitjournal_lib bash

cppcheck:
	cppcheck --enable=all --suppress=unusedFunction common.c gitjournal.c keygen.c

infer:
	infer run -- make
