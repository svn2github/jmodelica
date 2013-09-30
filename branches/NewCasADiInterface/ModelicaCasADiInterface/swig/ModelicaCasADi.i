%{
#include "Equation.hpp"
#include "Constraint.hpp"
#include "AttributeExpression.hpp"
#include "ModelFunction.hpp"

#include "types/VariableType.hpp"
#include "types/PrimitiveType.hpp"
#include "types/BooleanType.hpp"
#include "types/IntegerType.hpp"
#include "types/RealType.hpp"
#include "types/UserType.hpp"

#include "Variable.hpp"
#include "RealVariable.hpp"
#include "DerivativeVariable.hpp"
#include "BooleanVariable.hpp"
#include "IntegerVariable.hpp"

#include "Model.hpp"
#include "OptimizationProblem.hpp"

#include "transferModelica.hpp"
#include "transferOptimica.hpp"
%}
%include "doc.i"

%rename(MyVariable) ModelicaCasADi::Variable;

%include "std_string.i"
%include "std_vector.i"

%template(MyVariableVector) std::vector<ModelicaCasADi::Variable*>;

%template(ConstraintVector) std::vector<ModelicaCasADi::Constraint>;

// These must be in dependency order!
// SWIG doesn't follow #includes in the header files

%include "Printable.hpp"

%include "Equation.hpp"
%include "Constraint.hpp"
%include "AttributeExpression.hpp"
%include "ModelFunction.hpp"

%include "types/VariableType.hpp"
%include "types/PrimitiveType.hpp"
%include "types/BooleanType.hpp"
%include "types/IntegerType.hpp"
%include "types/RealType.hpp"
%include "types/UserType.hpp"

%include "Variable.hpp"
%include "RealVariable.hpp"
%include "DerivativeVariable.hpp"
%include "BooleanVariable.hpp"
%include "IntegerVariable.hpp"

%include "Model.hpp"
%include "OptimizationProblem.hpp"

%include "sharedTransferFunctionality.hpp"

%include "transferModelica.hpp"
%include "transferOptimica.hpp"

/*
#ifdef SWIG
    %extend ModelicaCasADi::Printable{
        std::string __repr__() { return $self->repr(); }
    }
#endif
*/
