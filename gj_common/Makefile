CC=clang

test: gitjournal.c test.c keygen.c common.c
	$(CC) -o test -g test.c common.c gitjournal.c keygen.c -lgit2 -lssl -lcrypto
