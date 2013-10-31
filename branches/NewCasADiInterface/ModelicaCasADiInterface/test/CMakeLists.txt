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
