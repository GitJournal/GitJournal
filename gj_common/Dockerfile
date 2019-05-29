FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y build-essential libssl-dev autoconf git gettext
RUN apt-get install -y zlib1g-dev vim
RUN apt-get install -y clang cmake

COPY ./build-libgit2.sh /
RUN ./build-libgit2.sh
