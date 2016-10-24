#    Copyright (C) 2014 Modelon AB

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published
#    by the Free Software Foundation, or optionally, under the terms of the
#    Common Public License version 1.0 as published by IBM.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.

#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not,
#    see <http://www.gnu.org/licenses/> or
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.

# NOTE: CMake 2.8.6 is required since this is the version used in development.
# The script is KNOWN NOT TO WORK WITH 2.8.3 and below (ExternalProject 
# interface changes). CMake 2.8.4 and 2.8.5 are not tested.
cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()
set(MSLCSOURCES ${TOP_SRC}/ThirdParty/MSL/Modelica/Resources/C-Sources)
set(CSPARSECSOURCES ${TOP_SRC}/ThirdParty/CSparse/csparse)
message(STATUS MSLCSOURCES=${MSLCSOURCES})
message(STATUS CSPARSECSOURCES=${CSPARSECSOURCES})

set(JMISources   
    jmi.h
    jmi_array_none.h
    jmi_block_residual.h
    jmi_me.h
    jmi_util.h
    jmi_global.h
    jmi_delay.h
    jmi_delay_impl.h
    jmi_dynamic_state.h
    jmi_chattering.h
    jmi_math.h
    jmi_types.h
    
    jmi_util.c
    jmi_global.c
    jmi.c
    jmi_array_none.c
    jmi_dyn_mem.c
    jmi_dyn_mem_.c
    jmi_block_residual.c
    jmi_cs.c
    jmi_me.c
    jmi_delay.c
    jmi_dynamic_state.c
    jmi_chattering.c
    jmi_math.c

    # Logging sources
	jmi_callbacks.h
    jmi_log.h
    jmi_log_impl.h
    jmi_log.c

    # Block solver sources
    jmi_block_solver.h
    jmi_block_solver_impl.h
	jmi_block_log.h
    jmi_kinsol_solver.h
    jmi_brent_solver.h
    jmi_minpack_solver.h
    jmi_linear_solver.h
    jmi_simple_newton.h

    jmi_block_solver.c
	jmi_block_log.c
    jmi_kinsol_solver.c
    jmi_brent_solver.c
    jmi_minpack_solver.c
    jmi_linear_solver.c
    jmi_simple_newton.c

    # Co-simulation support sources
    jmi_cs.h    
    jmi_ode_cvode.h
    jmi_ode_euler.h
    jmi_ode_solver.h
    jmi_ode_problem.h
    
    jmi_ode_cvode.c
    jmi_ode_euler.c
    jmi_ode_solver.c
    jmi_ode_problem.c
)

# Source files for ModelicaExternalC
set(MODELICAEXTERNALCSources
    jmi_global.h
    ModelicaUtilities.h
    
    jmi_global.c
    ModelicaUtilities.c
    
    ${MSLCSOURCES}/ModelicaInternal.c
    ${MSLCSOURCES}/ModelicaStrings.c
    ${MSLCSOURCES}/ModelicaRandom.c
    ${MSLCSOURCES}/ModelicaFFT.c
)

# Source files for Zlib
set(ZLIB_SOURCES
    ${MSLCSOURCES}/zlib/adler32.c
    ${MSLCSOURCES}/zlib/compress.c
    ${MSLCSOURCES}/zlib/crc32.c
    ${MSLCSOURCES}/zlib/deflate.c
    ${MSLCSOURCES}/zlib/gzclose.c
    ${MSLCSOURCES}/zlib/gzlib.c
    ${MSLCSOURCES}/zlib/gzread.c
    ${MSLCSOURCES}/zlib/gzwrite.c
    ${MSLCSOURCES}/zlib/infback.c
    ${MSLCSOURCES}/zlib/inffast.c
    ${MSLCSOURCES}/zlib/inflate.c
    ${MSLCSOURCES}/zlib/inftrees.c
    ${MSLCSOURCES}/zlib/trees.c
    ${MSLCSOURCES}/zlib/uncompr.c
    ${MSLCSOURCES}/zlib/zutil.c
)

set(CSPARSE_SOURCES
    ${CSPARSECSOURCES}/Include/cs.h
    
    ${CSPARSECSOURCES}/Source/cs_add.c        
    ${CSPARSECSOURCES}/Source/cs_amd.c        
    ${CSPARSECSOURCES}/Source/cs_chol.c       
    ${CSPARSECSOURCES}/Source/cs_cholsol.c    
    ${CSPARSECSOURCES}/Source/cs_compress.c   
    ${CSPARSECSOURCES}/Source/cs_counts.c     
    ${CSPARSECSOURCES}/Source/cs_cumsum.c     
    ${CSPARSECSOURCES}/Source/cs_dfs.c        
    ${CSPARSECSOURCES}/Source/cs_dmperm.c     
    ${CSPARSECSOURCES}/Source/cs_droptol.c    
    ${CSPARSECSOURCES}/Source/cs_dropzeros.c  
    ${CSPARSECSOURCES}/Source/cs_dupl.c       
    ${CSPARSECSOURCES}/Source/cs_entry.c      
    ${CSPARSECSOURCES}/Source/cs_ereach.c     
    ${CSPARSECSOURCES}/Source/cs_etree.c      
    ${CSPARSECSOURCES}/Source/cs_fkeep.c      
    ${CSPARSECSOURCES}/Source/cs_gaxpy.c                 
    ${CSPARSECSOURCES}/Source/cs_happly.c     
    ${CSPARSECSOURCES}/Source/cs_house.c
    ${CSPARSECSOURCES}/Source/cs_inplace.c      
    ${CSPARSECSOURCES}/Source/cs_ipvec.c     
    ${CSPARSECSOURCES}/Source/cs_leaf.c       
    ${CSPARSECSOURCES}/Source/cs_load.c       
    ${CSPARSECSOURCES}/Source/cs_lsolve.c     
    ${CSPARSECSOURCES}/Source/cs_ltsolve.c    
    ${CSPARSECSOURCES}/Source/cs_lu.c         
    ${CSPARSECSOURCES}/Source/cs_lusol.c      
    ${CSPARSECSOURCES}/Source/cs_malloc.c    
    ${CSPARSECSOURCES}/Source/cs_maxtrans.c  
    ${CSPARSECSOURCES}/Source/cs_multiply.c  
    ${CSPARSECSOURCES}/Source/cs_norm.c       
    ${CSPARSECSOURCES}/Source/cs_permute.c    
    ${CSPARSECSOURCES}/Source/cs_pinv.c      
    ${CSPARSECSOURCES}/Source/cs_post.c      
    ${CSPARSECSOURCES}/Source/cs_print.c     
    ${CSPARSECSOURCES}/Source/cs_pvec.c      
    ${CSPARSECSOURCES}/Source/cs_qr.c         
    ${CSPARSECSOURCES}/Source/cs_qrsol.c      
    ${CSPARSECSOURCES}/Source/cs_randperm.c   
    ${CSPARSECSOURCES}/Source/cs_reach.c     
    ${CSPARSECSOURCES}/Source/cs_scatter.c    
    ${CSPARSECSOURCES}/Source/cs_scc.c        
    ${CSPARSECSOURCES}/Source/cs_schol.c      
    ${CSPARSECSOURCES}/Source/cs_spsolve.c    
    ${CSPARSECSOURCES}/Source/cs_sqr.c        
    ${CSPARSECSOURCES}/Source/cs_symperm.c    
    ${CSPARSECSOURCES}/Source/cs_tdfs.c       
    ${CSPARSECSOURCES}/Source/cs_transpose.c  
    ${CSPARSECSOURCES}/Source/cs_updown.c     
    ${CSPARSECSOURCES}/Source/cs_usolve.c     
    ${CSPARSECSOURCES}/Source/cs_util.c       
    ${CSPARSECSOURCES}/Source/cs_utsolve.c    
)

include_directories(module_include)

#Build jmi library
add_library(jmi STATIC ${JMISources})
if(NOT MSVC)
    set_target_properties(jmi PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -Wno-long-long -O2")
    if (WIN32)
        include_directories(${TOP_SRC}/ThirdParty/pthreads/include)
    endif()
endif()

if(WIN32)
    #Flag that is needed for compiling lib togheter with MINPACK, no dll is created.
    add_definitions(-DCMINPACK_NO_DLL)
    
endif()

if(JMI_SUNDIALS AND JMI_LAPACK AND JMI_MINPACK)
    add_executable(jmi_block_solver_test jmi_block_solver_test.c)
    target_link_libraries(jmi_block_solver_test jmi ${JMI_SUNDIALS} ${JMI_LAPACK} ${JMI_MINPACK} ${JMI_CSPARSE})
endif()

#Build ModelicaExternalC library
include_directories(${MSLCSOURCES})
include_directories(${MSLCSOURCES}/zlib)
add_library(ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})
if(NOT MSVC)
    set_target_properties(ModelicaExternalC PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic")
endif()

#Build ModelicaStandardTables library
add_definitions("-DDUMMY_FUNCTION_USERTAB -DHAVE_ZLIB")
add_library(ModelicaStandardTables STATIC ${MSLCSOURCES}/ModelicaStandardTables.c)
if(NOT MSVC)
    set_target_properties(ModelicaStandardTables PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build ModelicaIO library
add_library(ModelicaIO STATIC ${MSLCSOURCES}/ModelicaIO.c)
if(NOT MSVC)
    set_target_properties(ModelicaIO PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build ModelicaMatIO library
add_library(ModelicaMatIO STATIC ${MSLCSOURCES}/ModelicaMatIO.c)
if(NOT MSVC)
    set_target_properties(ModelicaMatIO PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Build Zlib library
add_library(zlib STATIC ${ZLIB_SOURCES})
if(NOT MSVC)
    set_target_properties(ModelicaStandardTables PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

include_directories(${CSPARSECSOURCES}/Include)
add_library(csparse STATIC ${CSPARSE_SOURCES})
if(NOT MSVC)
    set_target_properties(csparse PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Install the libraries
install(TARGETS jmi ModelicaExternalC ModelicaStandardTables ModelicaIO ModelicaMatIO zlib csparse
    DESTINATION "${RTLIB_LIB_DIR}")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${RTLIB_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h")
    
install(DIRECTORY "${MSLCSOURCES}/"
    DESTINATION "${RTLIB_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h")
    
install(DIRECTORY "${CSPARSECSOURCES}/Include/"
    DESTINATION "${RTLIB_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h")

