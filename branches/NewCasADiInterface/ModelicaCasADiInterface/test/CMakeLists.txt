
set(LIBS_OPT
  ${LIBS}
  -lcasadi_ipopt_interface
  -lcasadi_optimal_control
  -lcasadi_tinyxml
  -lcasadi_csparse_interface
  -lcasadi
  -lipopt
  -llapack
  -lcoinmumps
  -lblas
  -lgfortran
  -lm
  -lgcc_s
  -lquadmath
  -lcoinmetis
  -lcoinhsl
)

add_subdirectory(unittests)
add_subdirectory(optimizationtests)
add_subdirectory(transfertests)
