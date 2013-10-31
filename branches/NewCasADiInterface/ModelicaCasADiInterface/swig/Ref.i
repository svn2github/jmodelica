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

%define %instantiate_Ref(T)

%typemap(out) ModelicaCasADi::Ref<T> {
    T *node = $1.getNode();
    incRefNode(node);
    $result = SWIG_NewPointerObj(SWIG_as_voidptr(node), $descriptor(T *), SWIG_POINTER_OWN);
}

%typemap(in) ModelicaCasADi::Ref<T> {
    T *node;
    {
        T *$1;
        $typemap(in, T *)
        node = $1;
    }
    $1.setNode(node);
}

// Doesn't seem like I can copy the "typecheck" typemap directly, why?
//%typemap(typecheck) ModelicaCasADi::Ref<T> = T *;
//%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) ModelicaCasADi::Ref<T> = T *;
%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) ModelicaCasADi::Ref<T> {
    $typemap(typecheck, T *);
}

%template(T ## ModelicaCasADi::Ref) ModelicaCasADi::Ref<T>;

%enddef


%include "Ref.hpp"
