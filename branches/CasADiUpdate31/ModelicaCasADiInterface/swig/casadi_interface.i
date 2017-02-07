/*
Copyright (C) 2013 Modelon AB

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

%module modelicacasadi_wrapper

%begin %{
// There seems to be an include file included later (Python.h?) that redefines
// hypot, causing trouble for cmath if it is included afterwards. Include it
// initially instead.
#include <cmath>
%}

// Pull in numpy
// WORKAROUNDS BEGINS: Due to Python-related issues in casadi.i
#define CASADI_NOT_IN_DERIVED
#ifdef SWIGPYTHON
%{
// to perhaps play more nicely with numpy.i
#define SWIG_FILE_WITH_INIT
#include "python/casadi_numpy.hpp"
#define SWIG_PYTHON_CAST_MODE 1
%}

%init %{
// initialize numpy, should only be done once?
import_array();
%}
#endif // SWIGPYTHON
// WORKAROUNDS END


%include "Ref.i" // Must be before %include "std_vector.i". Includes Ref.hpp

%include "exception.i" // Must be before %import "casadi.i"

%import "casadi.i"

// Clear typemaps defined by CasADi, where we want to use our own typemaps in vectors.i instead
%clear std::vector<double>;
%clear std::vector<string>;
%include "vectors.i" // Must be after %import "casadi.i"

%include "std_string.i"
%include "std_vector.i"


%{
#include <exception>
#include "jccexception.h"
%}

%exception {
    try {
        $action
    } catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    } catch (const char* e) {
        SWIG_exception(SWIG_RuntimeError, e);
    } catch (JavaError e) {
        describeAndClearJavaException(e);
        SWIG_exception(SWIG_RuntimeError, "a java error occurred; details were printed");
    }
}


%include "ModelicaCasADi.i"
