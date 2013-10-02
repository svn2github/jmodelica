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
