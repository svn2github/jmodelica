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

%module ifcasadi

// Expose the swig-generated function getCPtr as public in the proxy objects;
// we need it to get back the underlying object.
SWIG_JAVABODY_METHODS(public, public, SWIGTYPE)

%{
#include <iostream>
#include <cstdlib>
#include "jni.h"

#define WITH_DEPRECATED_FEATURES
#include "casadi/casadi.hpp"

using namespace casadi;
using namespace std;
%}

%pragma(java) jniclasscode=%{
    static {
        System.loadLibrary("ifcasadi");
    }
%}

%include "casadi_wrap.i"

%casadi_wrap(casadi::PrintableObject)
%casadi_wrap(casadi::SharedObject)
%casadi_wrap(casadi::MX)
%casadi_wrap(casadi::Function)

%casadi_wrap( std::vector<casadi::MX> )

%include "std_string.i"
%include "std_vector.i"
%include "std_pair.i"

%rename(__neg__) operator-;
%rename(_null) casadi::Sparsity::null;
%rename(toString) __repr__;
%rename(deref2)  casadi::Function::operator->;

#define CASADI_EXPORT

%include "casadi/core/casadi_types.hpp"

%include "casadi/core/printable_object.hpp"
%include "casadi/core/shared_object.hpp"
%include "casadi/core/mx/mx.hpp"


%include "ifcasadi.hpp"

namespace std {
    %template(MXVector) vector<casadi::MX>;
};

%rename(JFunction) casadi::Function;
%include "casadi/core/function/function.hpp"

namespace casadi {
    %extend MX {
        MX __add__(const MX& y) { return *$self+y; }
        MX __sub__(const MX& y) { return *$self-y; }
        MX __mul__(const MX& y) { return *$self*y; }
        //MX rdivide(const MX& y) { return y / *$self; }
        MX __div__(const MX& y) { return *$self / y; }
        MX __lt__(const MX& y) { return *$self<y; }
        MX __le__(const MX& y) { return *$self<=y; }
        MX __gt__(const MX& y) { return *$self>y; }
        MX __ge__(const MX& y) { return *$self>=y; }
        MX __eq__(const MX& y) { return *$self==y; }
        MX __ne__(const MX& y) { return *$self!=y; }
        MX logic_and(const MX& y) { return *$self&&y; } //
        MX logic_or(const MX& y) { return *$self||y; } //
        MX logic_not() { return !*$self; } //
        MX fabs() { return fabs(*$self); }
        MX sqrt() { return sqrt(*$self); }
        MX sin() { return sin(*$self); }
        MX cos() { return cos(*$self); }
        MX tan() { return tan(*$self); }
        MX arctan() { return atan(*$self); }
        MX arcsin() { return asin(*$self); }
        MX arccos() { return acos(*$self); }
        MX tanh() { return tanh(*$self); }
        MX sinh() { return sinh(*$self); }
        MX cosh() { return cosh(*$self); }
        MX arctanh() { return atanh(*$self); }
        MX arcsinh() { return asinh(*$self); }
        MX arccosh() { return acosh(*$self); }
        MX exp() { return exp(*$self); }
        MX log() { return log(*$self); }
        MX log10() { return log10(*$self); }
        MX floor() { return floor(*$self); }
        MX ceil() { return ceil(*$self); }
        MX erf() { return erf(*$self); }
        MX erfinv() { return erfinv(*$self); } //
        MX sign() { return sign(*$self); }
        MX __pow__(const MX& n) { return pow(*$self, n); }
        MX fmod(const MX& y) { return fmod(*$self, y); }
        MX arctan2(const MX& y) { return atan2(*$self, y); }
        MX fmin(const MX& y) { return fmin(*$self, y); }
        MX fmax(const MX& y) { return fmax(*$self, y); }
        MX simplify() { return simplify(*$self); } //
        bool is_equal(const MX& y, int depth=0) { return is_equal(*$self, y, depth); } //
        bool is_zero() { return is_zero(*$self); } //
        MX copysign(const MX& y) { return copysign(*$self, y); }
        MX constpow(const MX& y) { return constpow(*$self, y); }
        MX if_else(const MX& if_true,
                   const MX& if_false, bool short_circuit=true) {
          return if_else(*$self, if_true, if_false, short_circuit);
        }
    }
};

%inline %{
// Work around trouble with wrapping MX.sym
casadi::MX msym(const std::string &name) { return casadi::MX::sym(name); }
std::vector< casadi::MX > subst(const std::vector< casadi::MX >& ex,
                                const std::vector< casadi::MX >& v,
                                const std::vector< casadi::MX >& vdef) {
    return substitute(ex, v, vdef);
}

// Wrapping Function constructor doesn't appear to work
casadi::Function
mxfunction(const std::string& name,
           const std::vector<casadi::MX>& arg,
           const std::vector<casadi::MX>& res) {
    return casadi::Function(name, arg, res);
}

// Hack to avoid append (inefficient!)
casadi::MX vertcat2(const casadi::MX& a, casadi::MX& b) {
    return vertcat(a, b);
}
%}



%{
    // To avoid having to set up separate compilation of ifcasadi.cpp
    #include "ifcasadi.cpp"
%}
