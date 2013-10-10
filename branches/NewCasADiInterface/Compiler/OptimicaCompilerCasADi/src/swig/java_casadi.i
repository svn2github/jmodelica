
%module casadi

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

%include "symbolic/sx/sx.hpp"
%include "symbolic/printable_object.hpp"
%include "symbolic/shared_object.hpp"
%include "symbolic/generic_type.hpp"
%include "symbolic/options_functionality.hpp"
%include "symbolic/matrix/crs_sparsity.hpp"
%include "symbolic/mx/mx.hpp"
%include "symbolic/mx/mx_tools.hpp"
%include "symbolic/fx/fx.hpp"
%include "symbolic/fx/mx_function.hpp"

namespace std {
   %template(MXVector) vector<CasADi::MX>;
};
