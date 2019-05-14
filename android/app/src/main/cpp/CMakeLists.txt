cmake_minimum_required(VERSION 3.4.1)

set(lib_src_DIR ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI})
include_directories(${lib_src_DIR}/include)

add_library(openssl-lib
        STATIC
        IMPORTED)

set_target_properties(openssl-lib
        PROPERTIES IMPORTED_LOCATION
        ${lib_src_DIR}/lib/libssl.a)

add_library(crypto-lib
        STATIC
        IMPORTED)

set_target_properties(crypto-lib
        PROPERTIES IMPORTED_LOCATION
        ${lib_src_DIR}/lib/libcrypto.a)

add_library(ssh-lib
        STATIC
        IMPORTED)

set_target_properties(ssh-lib
        PROPERTIES IMPORTED_LOCATION
        ${lib_src_DIR}/lib/libssh.a)

add_library(ssh2-lib
        STATIC
        IMPORTED)

set_target_properties(ssh2-lib
        PROPERTIES IMPORTED_LOCATION
        ${lib_src_DIR}/lib/libssh2.a)

add_library(git2-lib
        STATIC
        IMPORTED)

set_target_properties(git2-lib
        PROPERTIES IMPORTED_LOCATION
        ${lib_src_DIR}/lib/libgit2.a)

add_library(native-lib
        SHARED
        keygen.c
        git.c
)

# The order of these libraries is super dooper important
# Otherwise you'll get linker errors
target_link_libraries(native-lib git2-lib ssh2-lib ssh-lib openssl-lib crypto-lib android log)
