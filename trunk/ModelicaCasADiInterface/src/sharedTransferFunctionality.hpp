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

#ifndef SHARED_TRANSFER_FUNCTIONALITY
#define SHARED_TRANSFER_FUNCTIONALITY


#include "iostream"

//JNI
#include "jni.h"

// JCC wrappers
#include "ifcasadi/MX.h"
#include "ifcasadi/MXFunction.h"
#include "ifcasadi/MXVector.h"

// The ModelicaCasADi program
#include "Model.hpp"
#include "BaseModel.hpp"
#include "types/VariableType.hpp"
#include "types/UserType.hpp"
#include "types/PrimitiveType.hpp"
#include "types/RealType.hpp"
#include "types/IntegerType.hpp"
#include "types/BooleanType.hpp"
#include "Equation.hpp"
#include "ModelFunction.hpp"
#include "Variable.hpp"
#include "RealVariable.hpp"
#include "DerivativeVariable.hpp"
#include "BooleanVariable.hpp"
#include "IntegerVariable.hpp"
#include "Ref.hpp"
#include "BLTHandler.hpp"
#include "Block.hpp"

#include "initjcc.h" // for env
#include "JCCEnv.h"


/**
 * Sets up a JVM with a class path to find the JModelica.org compiler
 */
void setUpJVM();
/**
 * Destroys the JVM. 
 */ 
void tearDownJVM();


/************************
 *                      *
 *         BLT          *
 *                      *
 ************************/
#ifndef SWIG

template<typename JBlock, typename JCollection, typename JIterator,
            typename FVar, typename FAbstractEquation, typename FEquation,
            typename FExp, template<typename Ty> class ArrayJ>
void transferBlock(JBlock* block, ModelicaCasADi::Ref<ModelicaCasADi::Block> ciBlock,bool jacobian_no_casadi = false, bool solve_with_casadi = true)
{
  JCollection block_equations(block->allEquations().this$);
  JCollection block_variables(block->allVariables().this$);
  JCollection unsolved_eq(block->unsolvedEquations().this$);
  JCollection unsolved_vars(block->unsolvedVariables().this$);
  JCollection block_inactive_var(block->inactiveVariables().this$);
  JCollection block_independent_var(block->independentVariables().this$);
  JCollection block_trajectories_var(block->dependsOn().this$);
  
  //Adding equations to block
  JIterator iter1(block_equations.iterator().this$);
  JIterator iter2(unsolved_eq.iterator().this$);
  bool found=false;
  while(iter1.hasNext()){
    found=false;
    FAbstractEquation f1(iter1.next().this$);
    casadi::MX lhs1 = toMX(f1.toMXForLhs()); 
    casadi::MX rhs1 = toMX(f1.toMXForRhs());
    while(iter2.hasNext() && !found){
      FAbstractEquation f2(iter2.next().this$);
      casadi::MX lhs2 = toMX(f2.toMXForLhs()); 
      casadi::MX rhs2 = toMX(f2.toMXForRhs());
      if(lhs1.getRepresentation()==lhs2.getRepresentation() && 
	  rhs1.getRepresentation()==rhs2.getRepresentation()){
	found=true;
      }
    }
    if(!found){
      ciBlock->addEquation(new ModelicaCasADi::Equation(lhs1,rhs1),true);
    }
    else{
      ciBlock->addEquation(new ModelicaCasADi::Equation(lhs1,rhs1),false);
    }
  }
  
  //Adding variables to block
  JIterator iter3(block_variables.iterator().this$);
  JIterator iter4(unsolved_vars.iterator().this$); 
  while(iter3.hasNext()){
    found=false;
    FVar jv1(iter3.next().this$);
    casadi::MX v1 = toMX(jv1.asMXVariable());
    while(iter4.hasNext() && !found){
      FVar jv2(iter4.next().this$);
      casadi::MX v2 = toMX(jv2.asMXVariable());
      if(v1.isEqual(v2)){
	found=true;          
      }
    }
    if(!found){
      ciBlock->addBlockVariable(v1,true);
    }
    else{
      ciBlock->addBlockVariable(v1,false);
    }
  }
  
  JIterator iter5(block_inactive_var.iterator().this$);
  while(iter5.hasNext()){
    found=false;
    FVar jvi(iter5.next().this$);
    casadi::MX vi = toMX(jvi.asMXVariable());
    ciBlock->addInactivVariable(vi);
  }
  
  JIterator iter6(block_independent_var.iterator().this$); 
  while(iter6.hasNext()){
    found=false;
    FVar jvp(iter6.next().this$);
    casadi::MX vp = toMX(jvp.asMXVariable());
    ciBlock->addIndependentVariable(vp);
     
  }
  
  JIterator iter7(block_trajectories_var.iterator().this$); 
  while(iter7.hasNext()){
    found=false;
    FVar jvt(iter7.next().this$);
    casadi::MX vt = toMX(jvt.asMXVariable());
    ciBlock->addTrajectoryVariable(vt);
  }
  if(block->isSimple() && block->isSolvable()){
    JIterator iter8(block_equations.iterator().this$);
    JIterator iter9(block_variables.iterator().this$);
    FVar fvs(iter9.next().this$);
    FEquation feq(iter8.next().this$);
    casadi::MX var = toMX(fvs.asMXVariable());
    casadi::MX sol = toMX(feq.solution(fvs).toMX());
    ciBlock->addSolutionToVariable(var.getName(),sol);        
  }
  
  //Setting Jacobian
  
  if(!jacobian_no_casadi){
    casadi::MX jaco = casadi::MX::sym("Jacobian",ciBlock->getNumEquations(),ciBlock->getNumVariables());
    std::vector<casadi::MX> residuals;
    //append equations
    std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > equations =ciBlock->allEquations();
    for(std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> >::iterator it=equations.begin(); 
	    it != equations.end(); ++it){
	residuals.push_back((*it)->getLhs()-(*it)->getRhs());
    }
    casadi::MXFunction f(ciBlock->allBlockVariables(),residuals);
    f.init();
    for (int i=0;i<ciBlock->getNumVariables();++i){
	for(int j=0;j<ciBlock->getNumEquations();++j){
	  casadi::MX jacotmp=f.jac(i,j);
	  jaco(j,i)=jacotmp;
	}
    }
    ciBlock->setJacobian(jaco);
  }
  else{
    if(block->computeJacobian()){
      ArrayJ< ArrayJ< FExp > > Jjacobian(block->jacobian().this$);
      casadi::MX jaco = casadi::MX::sym("Jacobian",ciBlock->getNumEquations(),ciBlock->getNumVariables());
      if(ciBlock->getNumEquations()!=Jjacobian.length){
	std::cout<<"WARNING: The jacobian coming from the compiler does not have the same number of rows as global equations";
      }
      if(ciBlock->getNumEquations()!=Jjacobian[0].length){
	std::cout<<"WARNING: The jacobian coming from the compiler does not have the same number of cols as global variables";
      }
      for(int i=0;i<ciBlock->getNumEquations();++i)
      {
	for(int j=0;j<ciBlock->getNumVariables();++j)
	{
	  jaco(i,j)= toMX(Jjacobian[i][j].toMX());
	}
      }
      ciBlock->setJacobian(jaco);
    }
    std::cout<<"TODO\n";
  }
  
  ciBlock->setasSimple(block->isSimple());
  ciBlock->setasLinear(block->isLinear());
  ciBlock->setasSolvable(block->isSolvable());
  
  ciBlock->checkLinearityWithJacobian();
  //To ask if we do this
  if(solve_with_casadi){
    ciBlock->solveLinearSystem();
  }    
}

template<typename JBLT, typename JBlock, typename JCollection, typename JIterator,
            typename FVar, typename FAbstractEquation, typename FEquation,
            typename FExp, template<typename Ty> class ArrayJ>
void transferBLT(JBLT* javablt, ModelicaCasADi::Ref<ModelicaCasADi::BLTHandler> ciBLT, bool jacobian_no_casadi = false, bool solve_with_casadi = true){
    
    for(int i=0;i<javablt->size();++i)
    {
       JBlock* block = new JBlock(javablt->get(i).this$);
       ModelicaCasADi::Ref<ModelicaCasADi::Block> ciBloc = new ModelicaCasADi::Block();
       transferBlock<JBlock, 
		    JCollection, 
		    JIterator,
		    FVar,
		    FAbstractEquation,
		    FEquation,
		    FExp,
		    ArrayJ>(block, ciBloc, jacobian_no_casadi, solve_with_casadi);
       ciBLT->addBlock(ciBloc);
       delete block;
    }
}

template<typename JBLT, typename JBlock, typename JCollection, typename JIterator,
            typename FVar, typename FAbstractEquation, typename FEquation,
            typename FExp, template<typename Ty> class ArrayJ>
void transferBLT2Model(JBLT* javablt, ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> m, bool jacobian_no_casadi = false, bool solve_with_casadi = true){
    
    ModelicaCasADi::Ref<ModelicaCasADi::BLTHandler> ciBLT = new ModelicaCasADi::BLTHandler();
    transferBLT<JBLT,
		JBlock, 
		JCollection, 
		JIterator,
		FVar,
		FAbstractEquation,
		FEquation,
		FExp,
		ArrayJ>(javablt, ciBLT, jacobian_no_casadi, solve_with_casadi);
    if(m->hasBLT()){
	m->setBLT(ciBLT);    
    }
}

#endif

/************************
 *                      *
 *      Equations       *
 *                      *
 ************************/

template <class AbstractEquation> 
/**
 * Creates a ModelicaCasADi::Equation from an abstract equation from JModelica.
 * @param An FAbstractEquation
 * @return A pointer to a ModelicaCasADi::Equation
 */
ModelicaCasADi::Ref<ModelicaCasADi::Equation> transferFAbstractEquation(AbstractEquation aeq) {
    return new ModelicaCasADi::Equation(toMX(aeq.toMXForLhs()), toMX(aeq.toMXForRhs()));
}

template <class ArrayList, class AbstractEquation>
/**
 * Creates a vector of pointers to ModelicaCasADi::Equation,
 * from a list of abstract equations from JModelica.
 * @param An ArrayList with FAbstractEquation
 * @return A list with pointers to ModelicaCasADi::Equation
 */
static std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > createModelEquationVectorFromEquationArrayList(ArrayList equationList) {
    std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > allEquations;
    for (int i = 0; i < equationList.size(); ++i) {
        AbstractEquation eq = AbstractEquation(equationList.get(i).this$);
        if (eq.isIgnoredForCasADi()) {
            char *str = env->toString(eq.this$);
            std::cerr << "Warning: Ignored equation:\n" << str << std::endl;
            delete[] str;
            
        } else {
            allEquations.push_back(transferFAbstractEquation<AbstractEquation>(eq));
        }
    }
    return allEquations;
}

template <class ArrayList, class AbstractEquation>
/**
 * Transfer the given list of equations to the DAE equations of the Model.
 * @param A pointer to a Model
 * @param An ArrayList with FAbstractEquation
 */
static void transferDaeEquations(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> m, ArrayList modelEquationsInJM){
    if(!m->hasBLT()){
	std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > modelEqs = createModelEquationVectorFromEquationArrayList<ArrayList, AbstractEquation>(modelEquationsInJM);
	for (std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> >::iterator it = modelEqs.begin(); it != modelEqs.end(); ++it){
	    m->addDaeEquation(*it);
	}
    }
    else{
	std::cout<<"The model has BLT. DAE equations are transfered from the BLT.\n";
    }
}

template <class ArrayList, class AbstractEquation>
/**
 * Transfer the given list of equations to the initial equations of the Model.
 * @param A pointer to a Model
 * @param An ArrayList with FAbstractEquation
 */
static void transferInitialEquations(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, ArrayList initialEqsInJM){
    std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> > initialEqs = createModelEquationVectorFromEquationArrayList<ArrayList, AbstractEquation>(initialEqsInJM);
    for (std::vector< ModelicaCasADi::Ref<ModelicaCasADi::Equation> >::iterator it = initialEqs.begin(); it != initialEqs.end(); ++it){
        m->addInitialEquation(*it);
    }
}





/************************
 *                      *
 *      Functions       *
 *                      *
 ************************/

template <class FlatClass, class List, class FunctionDecl>
/**
 * Transfers the functions in the flat class from JModelica to ModelFunctions in the Model.
 * @param A pointer to a Model
 * @param An FClass
 */
void transferFunctions(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FlatClass &fc) {
    List fl = fc.getFFunctionDeclList();
    for (int i = 0; i < fl.getNumChild(); ++i) {
        m->setModelFunctionByItsName(createModelFunction(FunctionDecl(fl.getChild(i).this$)));
    }
}

// Creates a ModelFunction from FFunctionDecl
template <class FunctionDeclaration>
/**
 * Creates a ModelFunction from a FFunctionDeclaration from JModelica.
 * @param An FFunctionDecl 
 * @return A pointer to a ModelFunction
 */
ModelicaCasADi::Ref<ModelicaCasADi::ModelFunction> createModelFunction(FunctionDeclaration fd){
	return new ModelicaCasADi::ModelFunction(toMXFunction(fd));
}









/**************************
 *                        *
 *  Variable attributes.  *
 *                        *
 **************************/

template <class FVar> 
/**
 * Transfers the MX binding expression to a ModelicaCasADi::Variable from a  
 * JModelica variable, if it has one. 
 * @param A ModelicaCasADi::Variable
 * @param An FVariable
 */
void transferBindingExpressionsOrEquationForVariable(ModelicaCasADi::Ref<ModelicaCasADi::Variable> var, FVar &fv){
	if (fv.findMXBindingExpressionIfPresent().this$ != NULL) {
		var->setAttribute("bindingExpression", toMX(fv.findMXBindingExpressionIfPresent())); 
	}
}

template <class FVar, class Comment> 
/**
 * Transfers the comment attribute to a ModelicaCasADi::Variable from a  
 * JModelica variable, if it has one. 
 * @param A ModelicaCasADi::Variable
 * @param An FVariable
 */
void transferCommentForVariable(ModelicaCasADi::Ref<ModelicaCasADi::Variable> var, FVar &fv) {
    if(fv.hasFStringComment()) {
        Comment comment = Comment(fv.getFStringComment().this$);
        var->setAttribute("comment", casadi::MX::sym(env->toString(comment.getComment().this$)));
    }
}

template <class FVar, class List, class Attribute>
/**
 * Transfers the list of attributes of a JModelica Variable to a
 * ModelicaCasADi::Variable. 
 * @param A ModelicaCasADi::Variable
 * @param An FVariable
 */ 
void transferFAttributeListForVariable(ModelicaCasADi::Ref<ModelicaCasADi::Variable> var, FVar &fv) {
    List attributeList = fv.getFAttributes();
    Attribute attr;
    for (int i = 0; i < attributeList.getNumChild(); ++i) {
        attr = Attribute(attributeList.getChild(i).this$);
        var->setAttribute(env->toString(attr.name().this$), toMX(attr.getValue()));
    }
}

template <class FVar, class List, class Attribute, class Comment> 
/**
 * Transfers attributes to a ModelicaCasADi::Variable from a  
 * JModelica variable. 
 * @param A ModelicaCasADi::Variable
 * @param An FVariable
 */
void transferAttributes(ModelicaCasADi::Ref<ModelicaCasADi::Variable> var, FVar &fv) {
	transferBindingExpressionsOrEquationForVariable<FVar>(var, fv);
    transferCommentForVariable<FVar, Comment>(var, fv);
    transferFAttributeListForVariable<FVar, List, Attribute>(var, fv);
}



template <class FVar> 
/**
 * Determines the causality of variable from JModelica.
 * @param An FVariable
 * @return ModelicaCasADi::Variable::Causality
 */
ModelicaCasADi::Variable::Causality getCausality(const FVar &fVar) {
    return fVar.isInput()  ? ModelicaCasADi::Variable::INPUT : 
          (fVar.isOutput() ? ModelicaCasADi::Variable::OUTPUT : 
                             ModelicaCasADi::Variable::INTERNAL);
}

template <class FVar> 
/**
 * Determines the variability of variable from JModelica.
 * @param An FVariable
 * @return ModelicaCasADi::Variable::Variability
 */
ModelicaCasADi::Variable::Variability getVariability(const FVar &fVar) {
    return fVar.isContinuous() ? ModelicaCasADi::Variable::CONTINUOUS : 
          (fVar.isDiscrete()   ? ModelicaCasADi::Variable::DISCRETE : 
          (fVar.isConstant()   ? ModelicaCasADi::Variable::CONSTANT : 
                                 ModelicaCasADi::Variable::PARAMETER));
}






/***************************
 *                         *
 *   User type transfer.   *
 *                         *
 ***************************/
/**
 * Derived types are transferred before variables are transferred. Furthermore, 
 * derived types have base type (e.g. Real), and these should be the same base types
 * as the ones in the Model. Therefore the base types that are given to the 
 * derived types should be set to the Model as well.
 * @param A pointer to a Model.
 * @param A string base type name. 
 */
static ModelicaCasADi::Ref<ModelicaCasADi::PrimitiveType> getBaseTypeForDerivedType(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, std::string baseTypeName) {
    if( m->getVariableType(baseTypeName).getNode() == NULL ) {
		if (baseTypeName == "Real") {
			m->addNewVariableType(new ModelicaCasADi::RealType());
		} else if (baseTypeName == "Integer") {
			m->addNewVariableType(new ModelicaCasADi::IntegerType());
		} else if (baseTypeName == "Boolean") {
			m->addNewVariableType(new ModelicaCasADi::BooleanType());
		}
    }
    return (ModelicaCasADi::PrimitiveType*) m->getVariableType(baseTypeName).getNode();
}

template <class List, class DerivedType, class Attribute, class Type>
/**
 * Transfers a derived type from JModelica to a Model
 * @param A pointer to a Model
 * @param An FDerivedType
 */
void transferDerivedType(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, DerivedType derivedType) {
    List attributeList = derivedType.getFAttributes();
    Attribute  attr;
    std::string typeName = env->toString(derivedType.getName().this$);
    std::string baseTypeName = env->toString((Type(derivedType.getBaseType().this$)).toString().this$);
    ModelicaCasADi::Ref<ModelicaCasADi::UserType> userType = new ModelicaCasADi::UserType(typeName, getBaseTypeForDerivedType(m, baseTypeName));
    for (int i = 0; i < attributeList.getNumChild(); ++i) {
        attr = Attribute(attributeList.getChild(i).this$);
        userType->setAttribute(env->toString(attr.name().this$), toMX(attr.getValue()));
    }
    m->addNewVariableType(userType);
}

// Transfer user defined types (including their base types).
template <class FlatClass, class List, class DerivedType, class Attribute, class Type>
/**
 * Transfer user defined derived types from a flat class
 * from JModelica to a Model.
 * @param A pointer to a Model
 * @param An FClass
 */
void transferUserDefinedTypes(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> m, FlatClass &fc) {
    List derivedTypeList = fc.getFDerivedTypeList();
    DerivedType derivedType;
    for (int i = 0; i < derivedTypeList.getNumChild(); ++i) {
        derivedType = DerivedType(derivedTypeList.getChild(i).this$);
        transferDerivedType<List, DerivedType, Attribute, Type>(m, derivedType);
    }
}







/**************************
 *                        *
 *   Variable transfer.   *
 *                        *
 **************************/
template <class FClass> 
void transferTime(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> m, FClass fc) {
    m->setTimeVariable(toMX(fc.timeMX()));
}
 
template <class FVar>
ModelicaCasADi::Ref<ModelicaCasADi::UserType> getUserType(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar &fv) {
    ModelicaCasADi::Ref<ModelicaCasADi::UserType> userType;
    if (!std::string(env->toString(fv.getDerivedType().this$)).empty()) {
        userType = (ModelicaCasADi::UserType*) m->getVariableType(env->toString(fv.getDerivedType().this$)).getNode();
        if(userType.getNode() == NULL) {
            throw std::runtime_error("Variable's derived type not present in Model when Variable transferred");
        }
    }
    return userType;
}


template <class FVar, class JMDerivativeVariable, class JMRealVariable, class List, class Attribute, class Comment>
void transferDifferentiatedVariableAndItsDerivative(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar &fv) {
    JMDerivativeVariable fDer = JMDerivativeVariable(fv.myDerivativeVariable().this$);
    JMRealVariable fDiff = JMRealVariable(fv.this$);
    ModelicaCasADi::Ref<ModelicaCasADi::RealVariable> realVar = new ModelicaCasADi::RealVariable(m.getNode(), toMX(fDiff.asMXVariable()), getCausality(fDiff),
                                getVariability(fDiff), getUserType<FVar>(m, fDiff));    
    ModelicaCasADi::Ref<ModelicaCasADi::DerivativeVariable> derVar = new ModelicaCasADi::DerivativeVariable(m.getNode(), toMX(fDer.asMXVariable()),
                                     realVar, getUserType<FVar>(m, fDer));
    realVar->setMyDerivativeVariable(derVar);
    transferAttributes<FVar, List, Attribute, Comment>(realVar, fDiff);
    transferAttributes<FVar, List, Attribute, Comment>(derVar, fDer);
    m->addVariable(derVar);
    m->addVariable(realVar);
    handleAliasVariable(m, realVar, fv); 
    handleAliasVariable(m, derVar, fv);
}

template <class FVar, class JMDerivativeVariable, class JMRealVariable, class List, class Attribute, class Comment>
void transferRealVariable(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar &fv){
    if (fv.isDerivativeVariable()) {
        return; // Derivative variables are transferred together with their differentiated variables. 
    }
    if (fv.isDifferentiatedVariable()) {
        transferDifferentiatedVariableAndItsDerivative<FVar, JMDerivativeVariable, JMRealVariable, List, Attribute, Comment>(m, fv);
        return; 
    } 
    ModelicaCasADi::Ref<ModelicaCasADi::RealVariable> realVar = new ModelicaCasADi::RealVariable(m.getNode(), toMX(fv.asMXVariable()), 
                                getCausality(fv), getVariability(fv), getUserType<FVar>(m, fv));
    transferAttributes<FVar, List, Attribute, Comment>(realVar, fv);
    handleAliasVariable(m, realVar, fv);
    m->addVariable(realVar);
}


template <class FVar, class List, class Attribute, class Comment>
void transferIntegerVariable(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar &fv){
    ModelicaCasADi::Ref<ModelicaCasADi::IntegerVariable> intVar = new ModelicaCasADi::IntegerVariable(m.getNode(), toMX(fv.asMXVariable()), 
                                getCausality(fv), getVariability(fv), getUserType<FVar>(m, fv));
    transferAttributes<FVar, List, Attribute, Comment>(intVar, fv);
    handleAliasVariable(m, intVar, fv);
    m->addVariable(intVar);
}


template <class FVar, class List, class Attribute, class Comment>
void transferBooleanVariable(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar &fv){
    ModelicaCasADi::Ref<ModelicaCasADi::BooleanVariable> boolVar = new ModelicaCasADi::BooleanVariable(m.getNode(), toMX(fv.asMXVariable()), 
                                getCausality(fv), getVariability(fv), getUserType<FVar>(m, fv));
    transferAttributes<FVar, List, Attribute, Comment>(boolVar, fv);
    handleAliasVariable(m, boolVar, fv);
    m->addVariable(boolVar);
}

template <class FVar>
void handleAliasVariable(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel> m, ModelicaCasADi::Ref<ModelicaCasADi::Variable> var, FVar &fv) {
    if (!fv.isAlias()) {
        return;
    }
    var->setAlias(m->getVariable(env->toString(fv.alias().name().this$)));
    var->setNegated(fv.isNegated());
}  

template <class FVar, class JMDerivativeVariable, class JMRealVariable, class List, class Attribute, class Comment>
void transferFVariable(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, FVar fv) {
    if (fv.isReal()) {
        transferRealVariable<FVar, JMDerivativeVariable, JMRealVariable, List, Attribute, Comment>(m, fv);
    } else if (fv.isInteger()) {
        transferIntegerVariable<FVar, List, Attribute, Comment>(m, fv);
    } else if (fv.isBoolean()) {
        transferBooleanVariable<FVar, List, Attribute, Comment>(m, fv);
    }
}

template <class ArrayList, class FVar, class JMDerivativeVariable, class JMRealVariable, class List, class Attribute, class Comment>
static void transferVariables(ModelicaCasADi::Ref<ModelicaCasADi::BaseModel>  m, ArrayList vars){
    for (int i = 0; i < vars.size(); i++) {
        FVar var = FVar(vars.get(i).this$);
        if (var.type().isEnum()) {
            char *str = env->toString(var.this$);
            std::cerr << "Warning: Ignored enumeration typed variable:\n" << str << std::endl;
            delete[] str;
        } else {
            transferFVariable<FVar, JMDerivativeVariable, JMRealVariable, List, Attribute, Comment>(m, var);
        }
    }
}


#endif
