cmake_minimum_required(VERSION 3.5)
project(LdpcC)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES ldpc_encoder.cpp ldpc_encoder.h LDPC_H.h main.cpp)
add_executable(LdpcC ${SOURCE_FILES})