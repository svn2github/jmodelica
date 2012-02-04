include_directories (${JM_CLIBS_SOURCE_DIR}/Utils ${JM_CLIBS_SOURCE_DIR}/FMIXML/include ..)
link_directories (${JM_CLIBS_SOURCE_DIR}/Utils  ${JM_CLIBS_SOURCE_DIR}/FMIXML)

add_executable (jm_vector_test jm_vector_test.c)
target_link_libraries (jm_vector_test jm_utils)


add_executable (fmixml_parser_test FMIXML_parser_test.c )
target_link_libraries (fmixml_parser_test  fmixml jm_utils expat)


