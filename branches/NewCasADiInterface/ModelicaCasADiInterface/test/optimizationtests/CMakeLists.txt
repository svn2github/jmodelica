
add_executable(test_optimization trajCreator.cpp "${MC_PATHS_H}")
target_link_libraries(test_optimization ModelicaCasADi)
target_link_libraries(test_optimization ${LIBS_OPT})
