cmake_minimum_required(VERSION 3.4.1)

set(lib_src_DIR ${CMAKE_SOURCE_DIR}/../../../libs/${ANDROID_ABI})
include_directories(
        ${lib_src_DIR}/include
        ${CMAKE_SOURCE_DIR}/../../../../../gj_common/
)

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
        ${CMAKE_SOURCE_DIR}/../../../../../gj_common/gitjournal.c
        ${CMAKE_SOURCE_DIR}/../../../../../gj_common/keygen.c
        ${CMAKE_SOURCE_DIR}/../../../../../gj_common/common.c
        git.c
        )

target_compile_options(native-lib PRIVATE -Werror -Wall -Wextra -Wno-missing-field-initializers)

# The order of these libraries is super dooper important
# Otherwise you'll get linker errors
target_link_libraries(native-lib git2-lib ssh2-lib openssl-lib crypto-lib android log)
