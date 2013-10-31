#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.


add_executable(test_construct_tests testJMConstructExposedToCasADi.cpp "${MC_PATHS_H}")
target_link_libraries(test_construct_tests ModelicaCasADi ${LIBS_OPT})

add_executable(test_modelica_transfer testModelicaTransfer.cpp "${MC_PATHS_H}")
target_link_libraries(test_modelica_transfer ModelicaCasADi ${LIBS_OPT})

add_executable(test_optimica_transfer testOptimicaTransfer.cpp "${MC_PATHS_H}")
target_link_libraries(test_optimica_transfer ModelicaCasADi ${LIBS_OPT})
