%module modelicacasadi_wrapper

%include "std_string.i"
%include "std_vector.i"
%include "exception.i"

%import "casadi.i"

/*
%{
#include <exception>
%}

%exception {
    try {
        $action
    } catch (const std::exception& e) { \
    SWIG_exception(SWIG_RuntimeError, e.what()); \
    } catch (const char* e) { \
        SWIG_exception(SWIG_RuntimeError, e); \
    }
}
*/

%include "ModelicaCasADi.i"
