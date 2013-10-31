#include <types/RealType.hpp>
#include <types/IntegerType.hpp>
#include <types/BooleanType.hpp>
#include <DerivativeVariable.hpp>
#include <Model.hpp>

using CasADi::MX; using CasADi::MXFunction; 
using std::vector; using std::ostream;
using std::string; using std::pair;

namespace ModelicaCasADi{

bool Model::checkDiff(RealVariable* var) const {
    // Since the variables are not sorted all variables are looped over.
    for(vector<Variable*>::const_iterator it = z.begin(); it != z.end(); ++it){
        if((*it)->getType() == Variable::REAL) {
            RealVariable* realTemp = (RealVariable*)(*it);
            if(realTemp->isDerivative()) {
                DerivativeVariable* derTemp = (DerivativeVariable*)realTemp;
                if(var == derTemp->getMyDifferentiatedVariable() ){
                    var->setMyDerivativeVariable(derTemp);
                    return true;
                }
            }
        }
    }
    return false;
}


bool Model::isDifferentiated(RealVariable* var) const {
    if (var->getMyDerivativeVariable() != NULL) { 
         return true;
    } else {
        return checkDiff(var);
    }
}

Model::VariableKind Model::classifyInternalRealVariable(Variable* var) const {
    switch(var->getVariability()) {
        case(Variable::CONTINUOUS):  { // Variable initialization, need to add { because of scope. 
                RealVariable* v = (RealVariable*)var;
                return ( v->isDerivative() ? DERIVATIVE : (isDifferentiated(v) ? DIFFERENTIATED : REAL_ALGEBRAIC) );
            } break;
        case(Variable::DISCRETE): return REAL_DISCRETE; break;
        case(Variable::PARAMETER): {
            if(var->hasAttributeSet("bindingExpression")){
                if (!var->getAttribute("bindingExpression")->isConstant()) {
                    return REAL_PARAMETER_DEPENDENT; 
                }
            }
            return REAL_PARAMETER_INDEPENDENT; break;
        }
        case(Variable::CONSTANT): return REAL_CONSTANT; break;
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable variability when sorting for internal real variable: " << (*var);
            throw std::runtime_error(errorMessage.str());
            break;
    } 
}
Model::VariableKind Model::classifyInternalIntegerVariable(Variable* var) const {
    switch(var->getVariability()) {
        case(Variable::DISCRETE): return INTEGER_DISCRETE; break;
        case(Variable::PARAMETER): {
            if(var->hasAttributeSet("bindingExpression")){
                if (!var->getAttribute("bindingExpression")->isConstant()) {
                    return INTEGER_PARAMETER_DEPENDENT; 
                }
            }
            return INTEGER_PARAMETER_INDEPENDENT; break;
        }
        case(Variable::CONSTANT): return INTEGER_CONSTANT; break;  
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable variability when sorting for internal integer variable: " << (*var);
            throw std::runtime_error(errorMessage.str());
            break;
    }
}
Model::VariableKind Model::classifyInternalBooleanVariable(Variable* var) const {
    switch(var->getVariability()) {
        case(Variable::DISCRETE):  return BOOLEAN_DISCRETE; break;
        case(Variable::PARAMETER): {
            if(var->hasAttributeSet("bindingExpression")){
                if (!var->getAttribute("bindingExpression")->isConstant()) {
                    return BOOLEAN_PARAMETER_DEPENDENT; 
                }
            }
            return BOOLEAN_PARAMETER_INDEPENDENT; break;
        }
        case(Variable::CONSTANT): return BOOLEAN_CONSTANT; break;  
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable variability when sorting for internal boolean variable: " << (*var);
            throw std::runtime_error(errorMessage.str());
            break;
    }
}
Model::VariableKind Model::classifyInternalStringVariable(Variable* var) const {
    switch(var->getVariability()) {
        case(Variable::DISCRETE): return STRING_DISCRETE; break;
        case(Variable::PARAMETER): throw std::runtime_error("Not implemented string parameters"); break;     
        case(Variable::CONSTANT): return STRING_CONSTANT; break;  
    }
}
Model::VariableKind Model::classifyInputVariable(Variable* var) const {
    switch(var->getType()) {
        case(Variable::REAL):    return REAL_INPUT;    break;
        case(Variable::INTEGER): return INTEGER_INPUT; break;
        case(Variable::BOOLEAN): return BOOLEAN_INPUT; break;
        case(Variable::STRING):  return STRING_INPUT;  break;
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable type when sorting for input variable: " << (*var);
            throw std::runtime_error(errorMessage.str());
            break;
    } 
}
Model::VariableKind Model::classifyInternalVariable(Variable* var) const {
    switch(var->getType()) {
        case(Variable::REAL):    return classifyInternalRealVariable(var);    break;
        case(Variable::INTEGER): return classifyInternalIntegerVariable(var); break;
        case(Variable::BOOLEAN): return classifyInternalBooleanVariable(var); break;
        case(Variable::STRING):  return classifyInternalStringVariable(var);  break; 
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable type when sorting for internal variable: " << (*var);
            throw std::runtime_error(errorMessage.str());
            break;         
    } 
}


Model::VariableKind Model::classifyVariable(Variable* var) const {
    switch(var->getCausality()) {
        case Variable::OUTPUT: return OUTPUT; break;
        case Variable::INPUT:  return classifyInputVariable(var); break;
        case Variable::INTERNAL: return classifyInternalVariable(var); break;
    }
    std::stringstream errorMessage;
    errorMessage << "Invalid variable causality when sorting for variable: " << (*var);
    throw std::runtime_error(errorMessage.str());
}

void Model::addNewVariableType(VariableType* variableType) {
    if (getVariableTypeByName(variableType->getName()) != NULL && getVariableTypeByName(variableType->getName()) !=variableType ){
        throw std::runtime_error("A VariableType with the same name as a type in the Model can not be "
                                 "added if those types are not the same object");
    } else {
        typesInModel[variableType->getName()] = variableType;
    }
}

void Model::assignVariableTypeToRealVariable(Variable* var) {
    if (getVariableTypeByName("Real") != NULL) {
        var->setDeclaredType(getVariableTypeByName("Real"));
    } else {
        typesInModel["Real"] = new RealType();
        var->setDeclaredType(getVariableTypeByName("Real"));
    }
}
void Model::assignVariableTypeToIntegerVariable(Variable* var) {
    if (getVariableTypeByName("Integer") != NULL) {
        var->setDeclaredType(getVariableTypeByName("Integer"));
    } else {
        typesInModel["Integer"] = new IntegerType();
        var->setDeclaredType(getVariableTypeByName("Integer"));
    }    
}
void Model::assignVariableTypeToBooleanVariable(Variable* var) {
    if (getVariableTypeByName("Boolean") != NULL) {
        var->setDeclaredType(getVariableTypeByName("Boolean"));
    } else {
        typesInModel["Boolean"] = new BooleanType();
        var->setDeclaredType(getVariableTypeByName("Boolean"));
    }    
}

void Model::assignVariableTypeToVariable(Variable* var){
    switch(var->getType())  {
        case Variable::REAL : assignVariableTypeToRealVariable(var); break;
        case Variable::INTEGER : assignVariableTypeToIntegerVariable(var); break;
        case Variable::BOOLEAN : assignVariableTypeToBooleanVariable(var); break;
        default: throw std::runtime_error("Variable data type invalid"); break;
    }
}

void Model::handleVariableTypeForAddedVariable(Variable* var){
    if (var->getDeclaredType() != NULL) {
        addNewVariableType(var->getDeclaredType());
    } else {
        assignVariableTypeToVariable(var);
    }
}



void Model::addVariable(Variable* var) {
    if (!var->getVar().isSymbolic()) {
        throw std::runtime_error("The supplied variable is not symbolic and can not be variable"); 
    }
    handleVariableTypeForAddedVariable(var);
    z.push_back(var);
}

vector<Variable*> Model::getVariableByKind(VariableKind kind) {
	if (kind < 0 || kind >= NUM_OF_VARIABLE_KIND) {
		throw std::runtime_error("Invalid VariableKind");
	}
    // Special case for last variable, due to size of offsets.
    vector<Variable*> varVec;
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if (classifyVariable(*it) == kind) {
            varVec.push_back(*it);
        }
    }
    return varVec;
}

Variable* Model::getVariableByName(std::string name) {
    Variable* returnVar = NULL;
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if ((*it)->getName() == name) {
            returnVar = *it;
            break;
        }
    }
    return returnVar;
}

Variable* Model::getModelVariableByName(std::string name) {
    Variable* returnVar = NULL;
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if ((*it)->getName() == name) {
            if( (*it)->isAlias()) {
                returnVar = (*it)->getAlias();
            } else {
                returnVar = *it;
            }
            break;
        }
    }
    return returnVar;
}

vector<Variable*> Model::getModelVariables() {
    vector<Variable*> modelVars;
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if (!(*it)->isAlias()) {
            modelVars.push_back(*it);
        }
    }
    return modelVars;
}
vector<Variable*> Model::getAliasVariables() {
    vector<Variable*> aliasVars;
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if ((*it)->isAlias()) {
            aliasVars.push_back(*it);
        }
    }
    return aliasVars;
}

double Model::evalMX(MX exp) {
    vector<MX> expVec;
    expVec.push_back(exp);
    try {
        MXFunction f(paramAndConstMXVec, expVec);
        f.init();
        // Would be preferable to pass in a vector with values,
        // but that does not seem possible unless the passsed in
        // MX is vector-valued as well. 
        for (int i = 0; i < paramAndConstValVec.size(); ++i) {
            f.setInput(paramAndConstValVec[i], i); 
        }
        f.evaluate();
        MX out = f.output();
        if (out.isConstant()) {
            return out.getValue();
        } else {
            throw std::runtime_error("The evaluated expression could not be determined");
        }
    } catch (const std::exception& ex) {
        std::stringstream ss;
        ss << "An exception occured while evaluating the expression: " << ex.what() << "\nAre the parameter values calculated?" << std::endl;
        throw std::runtime_error(ss.str());
    }
}

double Model::evaluateExpression(MX exp) {
    calculateValuesForDependentParameters();
    return evalMX(exp); 
}

void Model::calculateValuesForDependentParameters() {
    MX bindingExpression;
    double val;
    setUpValAndSymbolVecs();
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        Variable* var = (*it);
        if (var->getVariability() == Variable::PARAMETER) {
            if (var->hasAttributeSet("bindingExpression")) {
                bindingExpression = *var->getAttribute("bindingExpression");
                if (!bindingExpression.isConstant()) {
                    val = evalMX(bindingExpression);
                    paramAndConstMXVec.push_back(var->getVar());
                    paramAndConstValVec.push_back(val);
                    var->setAttribute("evaluatedBindingExpression", val);
                }
            }
        }
    }
}


void Model::setUpValAndSymbolVecs() {
    paramAndConstMXVec.clear();
    paramAndConstValVec.clear();
    for (vector<Variable*>::iterator it = z.begin(); it != z.end(); ++it) {
        if ( ((*it)->getVariability() == Variable::PARAMETER) ||
             ((*it)->getVariability() == Variable::CONSTANT)){
            if ((*it)->hasAttributeSet("bindingExpression")) {
                // If it's a parameter with a non constant binding expression it
                // is a dependent parameter, and its value needs to be calculated. 
                MX bindingExpression = *(*it)->getAttribute("bindingExpression");
                if (bindingExpression.isConstant()) {
                    paramAndConstMXVec.push_back((*it)->getVar());
                    paramAndConstValVec.push_back(bindingExpression.getValue()); 
                }
            } else {
                paramAndConstValVec.push_back((*it)->getAttribute("start")->getValue());
                paramAndConstMXVec.push_back((*it)->getVar());
            }
        }
    }
}

const MX Model::getInitialResidual() const {
    MX intialRes;
    for (vector<Equation*>::const_iterator it = initialEquations.begin(); it!= initialEquations.end(); ++it) {
        intialRes.append((*it)->getResidual());
    }
    return intialRes;
}
const MX Model::getDaeResidual() const {
    MX daeRes;
    for (vector<Equation*>::const_iterator it = daeEquations.begin(); it!= daeEquations.end(); ++it) {
        daeRes.append((*it)->getResidual());
    }
    return daeRes;
}

template <class T> 
string generatePrintStringForVector(const vector<T*> &makeStringOf) {
    std::stringstream result;
    typename vector<T*>::const_iterator it;
    for ( it = makeStringOf.begin(); it < makeStringOf.end(); ++it) {
         result << *(*it) << "\n";
    }
    return result.str();
}

void Model::print(std::ostream& os) const {
    using std::endl;
    os << "------------------------------- Variables -------------------------------\n" << endl;
    if (!timeVar.isNull()) {
        os << "Time variable: ";
        timeVar.print(os);
        os << endl;
    }
    os << generatePrintStringForVector(z);
    os << "\n---------------------------- Variable types  ----------------------------\n" << endl;
    for (Model::typeMap::const_iterator it = typesInModel.begin(); it != typesInModel.end(); ++it) {
            os << *(it->second) << endl;
    }
    os << "\n------------------------------- Functions -------------------------------\n" << endl;
    for (Model::functionMap::const_iterator it = modelFunctionMap.begin(); it != modelFunctionMap.end(); ++it){
            os << *(it->second) << endl;
    }
    os << "\n------------------------------- Equations -------------------------------\n" << endl;
    if (!initialEquations.empty()) {
        os << " -- Initial equations -- \n" << generatePrintStringForVector(initialEquations);
    }
    if (!daeEquations.empty()) {
        os << " -- DAE equations -- \n" << generatePrintStringForVector(daeEquations);
    }
    os << endl;
}
}; // End namespace