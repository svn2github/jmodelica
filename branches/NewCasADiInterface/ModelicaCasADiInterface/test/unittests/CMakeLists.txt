
add_executable(unittests test.cpp)
target_link_libraries(unittests ModelicaCasADi)
target_link_libraries(unittests ${LIBS})
