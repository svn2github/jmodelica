
add_executable(test_construct_tests testJMConstructExposedToCasADi.cpp "${MC_PATHS_H}")
target_link_libraries(test_construct_tests ModelicaCasADi ${LIBS_OPT})

add_executable(test_modelica_transfer testModelicaTransfer.cpp "${MC_PATHS_H}")
target_link_libraries(test_modelica_transfer ModelicaCasADi ${LIBS_OPT})

add_executable(test_optimica_transfer testOptimicaTransfer.cpp "${MC_PATHS_H}")
target_link_libraries(test_optimica_transfer ModelicaCasADi ${LIBS_OPT})
