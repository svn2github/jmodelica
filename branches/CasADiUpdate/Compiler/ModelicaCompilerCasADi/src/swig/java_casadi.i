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

%module casadi

// Expose the swig-generated function getCPtr as public in the proxy objects;
// we need it to get back the underlying object.
SWIG_JAVABODY_METHODS(protected, public, SWIGTYPE)

%{
#include <iostream>
#include <cstdlib>
#include "jni.h"

#include "symbolic/casadi.hpp"

using namespace CasADi;
using namespace std;
%}

%pragma(java) jniclasscode=%{
    static {
        System.loadLibrary("ifcasadi");
    }
%}

%include "std_string.i"
%include "std_vector.i"
%include "std_pair.i"

%rename(__neg__) operator-;
%rename(_null) CasADi::CRSSparsity::null;
%rename(toString) __repr__;
%rename(deref1)  CasADi::MXFunction::operator->;
%rename(deref2)  CasADi::FX::operator->;

%include "symbolic/printable_object.hpp"
%include "symbolic/shared_object.hpp"
%include "symbolic/generic_type.hpp"
%include "symbolic/options_functionality.hpp"
%include "symbolic/matrix/sparsity.hpp"
%include "symbolic/mx/mx.hpp"
%include "symbolic/mx/mx_tools.hpp"
%include "symbolic/function/function.hpp"
%include "symbolic/function/mx_function.hpp"

namespace std {
   %template(MXVector) vector<CasADi::MX>;
};
