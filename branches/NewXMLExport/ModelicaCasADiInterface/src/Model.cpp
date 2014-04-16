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

#include "types/RealType.hpp"
#include "types/IntegerType.hpp"
#include "types/BooleanType.hpp"
#include "DerivativeVariable.hpp"
#include "Model.hpp"

using CasADi::MX; using CasADi::MXFunction; 
using std::vector; using std::ostream;
using std::string; using std::pair;

namespace ModelicaCasADi{

Model::~Model() {
    // Delete all the Model's variables, since they are OwnedNodes with the Model as owner.
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
        delete *it;
        *it = NULL;
    }
}

double Model::get(string varName) {
    Ref<Variable> var = getVariable(varName);
    if (var == NULL) {
        throw std::runtime_error("No variable named " + varName);
    }
    if (var->getVariability() > Variable::PARAMETER) {
        throw std::runtime_error("Tried to get non-parameter " + var->repr());
    }
    calculateValuesForDependentParameters();
    MX *ex = var->getAttribute("evaluatedBindingExpression");
    if (ex == NULL) throw std::runtime_error("Failed to evaluate " + var->repr());
    return evaluateExpression(*ex);
}

vector<double> Model::get(const vector<string> &varNames) {
    vector<double> result;
    for (vector< string >::const_iterator it = varNames.begin(); it != varNames.end(); ++it){
        result.push_back(get(*it));
    }
    return result;
}

void Model::set(string varName, double value) {
    Ref<Variable> var = getVariable(varName);
    if (var == NULL) {
        throw std::runtime_error("No variable named " + varName);
    }
    if (var->getVariability() != Variable::PARAMETER) {
        throw std::runtime_error("Tried to set non-parameter " + var->repr());
    }
    var->setAttribute("bindingExpression", value);
}

void Model::set(const vector<string> &varNames, const vector<double> &values) {
    if (varNames.size() != values.size()) {
        throw std::runtime_error("Must specify the same number of variables and values.");
    }
    vector< string >::const_iterator name  = varNames.begin();
    vector< double >::const_iterator value = values.begin();
    for (; name != varNames.end(); ++name, ++value) {
        set(*name, *value);
    }
}


bool Model::checkIfRealVarIsReferencedAsStateVar(Ref<RealVariable> var) const {
    // Since the variables are not sorted all variables are looped over.
    // Note:  May assign derivative variable to a state variable
    for(vector< Variable * >::const_iterator it = z.begin(); it != z.end(); ++it){
        if((*it)->getType() == Variable::REAL) {
            RealVariable *realTemp = (RealVariable*)*it;
            if(realTemp->isDerivative()) {
                Ref<DerivativeVariable> derTemp = (DerivativeVariable*)realTemp;
                if(var.getNode() == derTemp->getMyDifferentiatedVariable().getNode()){
                    var->setMyDerivativeVariable(derTemp);
                    return true;
                }
            }
        }
    }
    return false;
}


bool Model::isDifferentiated(Ref<RealVariable> var) const {
    // Note: May assign derivative variable to a state variable in checkIfRealVarIsReferencedAsStateVar
    if (var->getMyDerivativeVariable().getNode() != NULL) { 
         return true;
    } else {
        return checkIfRealVarIsReferencedAsStateVar(var);
    }
}

Model::VariableKind Model::classifyInternalRealVariable(Ref<Variable> var) const {
    switch(var->getVariability()) {
        case(Variable::CONTINUOUS):  { // Variable initialization, need to add { because of scope. 
                Ref<RealVariable> v = (RealVariable*)var.getNode();
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
            errorMessage << "Invalid variable variability when sorting for internal real variable: " << var;
            throw std::runtime_error(errorMessage.str());
            break;
    } 
}
Model::VariableKind Model::classifyInternalIntegerVariable(Ref<Variable> var) const {
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
            errorMessage << "Invalid variable variability when sorting for internal integer variable: " << var;
            throw std::runtime_error(errorMessage.str());
            break;
    }
}
Model::VariableKind Model::classifyInternalBooleanVariable(Ref<Variable> var) const {
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
            errorMessage << "Invalid variable variability when sorting for internal boolean variable: " << var;
            throw std::runtime_error(errorMessage.str());
            break;
    }
}
Model::VariableKind Model::classifyInternalStringVariable(Ref<Variable> var) const {
    switch(var->getVariability()) {
        case(Variable::DISCRETE): return STRING_DISCRETE; break;
        case(Variable::PARAMETER): throw std::runtime_error("Not implemented string parameters"); break;     
        case(Variable::CONSTANT): return STRING_CONSTANT; break;  
    }
}
Model::VariableKind Model::classifyInputVariable(Ref<Variable> var) const {
    switch(var->getType()) {
        case(Variable::REAL):    return REAL_INPUT;    break;
        case(Variable::INTEGER): return INTEGER_INPUT; break;
        case(Variable::BOOLEAN): return BOOLEAN_INPUT; break;
        case(Variable::STRING):  return STRING_INPUT;  break;
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable type when sorting for input variable: " << var;
            throw std::runtime_error(errorMessage.str());
            break;
    } 
}
Model::VariableKind Model::classifyInternalVariable(Ref<Variable> var) const {
    switch(var->getType()) {
        case(Variable::REAL):    return classifyInternalRealVariable(var);    break;
        case(Variable::INTEGER): return classifyInternalIntegerVariable(var); break;
        case(Variable::BOOLEAN): return classifyInternalBooleanVariable(var); break;
        case(Variable::STRING):  return classifyInternalStringVariable(var);  break; 
        default: 
            std::stringstream errorMessage;
            errorMessage << "Invalid variable type when sorting for internal variable: " << var;
            throw std::runtime_error(errorMessage.str());
            break;         
    } 
}


Model::VariableKind Model::classifyVariable(Ref<Variable> var) const {
    switch(var->getCausality()) {
        case Variable::OUTPUT: return OUTPUT; break;
        case Variable::INPUT:  return classifyInputVariable(var); break;
        case Variable::INTERNAL: return classifyInternalVariable(var); break;
    }
    std::stringstream errorMessage;
    errorMessage << "Invalid variable causality when sorting for variable: " << var;
    throw std::runtime_error(errorMessage.str());
}

void Model::addNewVariableType(Ref<VariableType> variableType) {
    if (getVariableType(variableType->getName()).getNode() != NULL && 
        getVariableType(variableType->getName()).getNode() != variableType.getNode() ){
        throw std::runtime_error("A VariableType with the same name as a type in the Model can not be "
                                 "added if those types are not the same object");
    } else {
        typesInModel[variableType->getName()] = variableType;
    }
}

void Model::assignVariableTypeToRealVariable(Ref<Variable> var) {
    if (getVariableType("Real").getNode() != NULL) {
        var->setDeclaredType(getVariableType("Real"));
    } else {
        typesInModel["Real"] = new RealType();
        var->setDeclaredType(getVariableType("Real"));
    }
}
void Model::assignVariableTypeToIntegerVariable(Ref<Variable> var) {
    if (getVariableType("Integer").getNode() != NULL) {
        var->setDeclaredType(getVariableType("Integer"));
    } else {
        typesInModel["Integer"] = new IntegerType();
        var->setDeclaredType(getVariableType("Integer"));
    }    
}
void Model::assignVariableTypeToBooleanVariable(Ref<Variable> var) {
    if (getVariableType("Boolean").getNode() != NULL) {
        var->setDeclaredType(getVariableType("Boolean"));
    } else {
        typesInModel["Boolean"] = new BooleanType();
        var->setDeclaredType(getVariableType("Boolean"));
    }    
}

void Model::assignVariableTypeToVariable(Ref<Variable> var){
    switch(var->getType())  {
        case Variable::REAL : assignVariableTypeToRealVariable(var); break;
        case Variable::INTEGER : assignVariableTypeToIntegerVariable(var); break;
        case Variable::BOOLEAN : assignVariableTypeToBooleanVariable(var); break;
        default: throw std::runtime_error("Variable data type invalid"); break;
    }
}

void Model::handleVariableTypeForAddedVariable(Ref<Variable> var){
    if (var->getDeclaredType().getNode() != NULL) {
        addNewVariableType(var->getDeclaredType());
    } else {
        assignVariableTypeToVariable(var);
    }
}

void Model::addVariable(Ref<Variable> var) {
    assert(var->isOwnedBy(this));
    if (!var->getVar().isSymbolic()) {
        throw std::runtime_error("The supplied variable is not symbolic and can not be variable"); 
    }
    dirty = true; // todo: only if (dependent) parameter, or with dependent attributes?
    handleVariableTypeForAddedVariable(var);
    z.push_back(var.getNode());
	modelVariableMap.insert(std::pair<string, Variable*>(var->getName(), var.getNode()));
}

vector< Ref<Variable> > Model::getVariables(VariableKind kind) {
	if (kind < 0 || kind >= NUM_OF_VARIABLE_KIND) {
		throw std::runtime_error("Invalid VariableKind");
	}
    // Special case for last variable, due to size of offsets.
    vector< Ref<Variable> > varVec;
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
        if (classifyVariable(*it) == kind) {
            varVec.push_back(*it);
        }
    }
    return varVec;
}

Ref<Variable> Model::getVariable(std::string name) {
    Ref<Variable> returnVar = Ref<Variable>(NULL);
	std::map<std::string, Variable*>::iterator it = modelVariableMap.find(name);
	if (it != modelVariableMap.end()) {
		returnVar = it->second;;
	} else {
		return NULL;
	}
	//returnVar = modelVariableMap.find(name)->second;
	/*for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
		if ((*it)->getName() == name) {
			returnVar = *it;
			break;
		}
	}*/
    return returnVar;
}

Ref<Variable> Model::getModelVariable(std::string name) {
    Ref<Variable> returnVar;
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
        if ((*it)->getName() == name) {
            if( (*it)->isAlias()) {
                returnVar = (*it)->getModelVariable();
            } else {
                returnVar = *it;
            }
            break;
        }
    }
    return returnVar;
}

vector< Ref<Variable> > Model::getAllVariables() {
    vector< Ref<Variable> > vars;
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) vars.push_back(*it);
    return vars;
}
vector< Ref<Variable> > Model::getModelVariables() {
    vector< Ref<Variable> > modelVars;
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
        if (!(*it)->isAlias()) {
            modelVars.push_back(*it);
        }
    }
    return modelVars;
}
vector< Ref<Variable> > Model::getAliases() {
    vector< Ref<Variable> > aliasVars;
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
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
    if (!dirty) return;

    MX bindingExpression;
    double val;
    setUpValAndSymbolVecs();
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
        Ref<Variable> var = (*it);
        if (var->getVariability() == Variable::PARAMETER) {
            if (var->hasAttributeSet("bindingExpression")) {
                bindingExpression = *var->getAttribute("bindingExpression");
                if (!bindingExpression.isConstant()) {
                    val = evalMX(bindingExpression);
                    paramAndConstMXVec.push_back(var->getVar());
                    paramAndConstValVec.push_back(val);
                    var->setAttribute("evaluatedBindingExpression", val);
                }
                else {
                    var->setAttribute("evaluatedBindingExpression", bindingExpression);
                }
            }
        }
    }
    dirty = false;
}


void Model::setUpValAndSymbolVecs() {
    paramAndConstMXVec.clear();
    paramAndConstValVec.clear();
    for (vector< Variable * >::iterator it = z.begin(); it != z.end(); ++it) {
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
    for (vector< Ref<Equation> >::const_iterator it = initialEquations.begin(); it != initialEquations.end(); ++it) {
        intialRes.append((*it)->getResidual());
    }
    return intialRes;
}
const MX Model::getDaeResidual() const {
    MX daeRes;
    for (vector< Ref<Equation> >::const_iterator it = daeEquations.begin(); it != daeEquations.end(); ++it) {
        daeRes.append((*it)->getResidual());
    }
    return daeRes;
}


template <class T> 
void printVector(std::ostream& os, const vector<T> &makeStringOf) {
    typename vector<T>::const_iterator it;
    for ( it = makeStringOf.begin(); it < makeStringOf.end(); ++it) {
         os << **it << "\n";
    }
}

void Model::print(std::ostream& os) const {
//    os << "Model<" << this << ">"; return;

    using std::endl;
    os << "------------------------------- Variables -------------------------------\n" << endl;
    if (!timeVar.isNull()) {
        os << "Time variable: ";
        timeVar.print(os);
        os << endl;
    }
    printVector(os, z);
    os << "\n---------------------------- Variable types  ----------------------------\n" << endl;
    for (Model::typeMap::const_iterator it = typesInModel.begin(); it != typesInModel.end(); ++it) {
            os << it->second << endl;
    }
    os << "\n------------------------------- Functions -------------------------------\n" << endl;
    for (Model::functionMap::const_iterator it = modelFunctionMap.begin(); it != modelFunctionMap.end(); ++it){
            os << it->second << endl;
    }
    os << "\n------------------------------- Equations -------------------------------\n" << endl;
    if (!initialEquations.empty()) {
        os << " -- Initial equations -- \n";
        printVector(os, initialEquations);
    }
    if (!daeEquations.empty()) {
        os << " -- DAE equations -- \n";
        printVector(os, daeEquations);
    }
    os << endl;
}
}; // End namespace
