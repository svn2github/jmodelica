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

#ifndef _MODELICACASADI_BLOCK
#define _MODELICACASADI_BLOCK

#include <iostream>
#include "casadi/casadi.hpp"
#include "Variable.hpp"
#include "RealVariable.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include <vector>
#include <map>
#include <utility>
#include <string>
#include <assert.h>



namespace ModelicaCasADi 
{

class Block : public RefCountedNode{
    public:
    //Default constructor
    Block(): simple_flag(false),linear_flag(false),solve_flag(false){ nRowsJac=0; nColsJac=0;};
    ~Block(){
      //Temporal while improve jacobian computation and printing 
      if(nRowsJac!=0 && nColsJac!=0){
        for(int i=0;i<nRowsJac;++i){
          delete [] prettyPrintJacobian[i];      
        }
        delete [] prettyPrintJacobian;
      }
    }
    
#ifndef SWIG
    /** 
     * Set a Block from optimica o modelica compiler
     * @param JBlock optimica or modelica block
     */
    template<typename JBlock, typename JCollection, typename JIterator,
            typename FVar, typename FAbstractEquation, typename FEquation,
            typename FExp, template<typename Ty> class ArrayJ >
    void setBlock(JBlock* block,bool jacobian_no_casadi = true, bool solve_with_casadi = true)
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
          addEquation(new Equation(lhs1,rhs1),true);
        }
        else{
          addEquation(new Equation(lhs1,rhs1),false);
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
          addBlockVariable(v1,true);
        }
        else{
          addBlockVariable(v1,false);
        }
      }
      
      JIterator iter5(block_inactive_var.iterator().this$);
      while(iter5.hasNext()){
        found=false;
        FVar jvi(iter5.next().this$);
        casadi::MX vi = toMX(jvi.asMXVariable());
        addInactivVariable(vi);
      }
      
      JIterator iter6(block_independent_var.iterator().this$); 
      while(iter6.hasNext()){
        found=false;
        FVar jvp(iter6.next().this$);
        casadi::MX vp = toMX(jvp.asMXVariable());
        addIndependentVariable(vp);
         
      }
      
      JIterator iter7(block_trajectories_var.iterator().this$); 
      while(iter7.hasNext()){
        found=false;
        FVar jvt(iter7.next().this$);
        casadi::MX vt = toMX(jvt.asMXVariable());
        addTrajectoryVariable(vt);
      }
      
      if(block->isSimple() && block->isSolvable()){
        JIterator iter8(block_equations.iterator().this$);
        JIterator iter9(block_variables.iterator().this$);
        FVar fvs(iter9.next().this$);
        FEquation feq(iter8.next().this$);
        casadi::MX var = toMX(fvs.asMXVariable());
        casadi::MX sol = toMX(feq.solution(fvs).toMX());
        addSolutionToVariable(var.getName(),sol);        
      }
      
      //Setting Jacobian
      //For printing
      nRowsJac = equations.size();
      nColsJac = variables.size();
      prettyPrintJacobian = new casadi::MX*[nRowsJac];
      for(int i=0;i<nRowsJac;++i){
        prettyPrintJacobian[i]=new casadi::MX[nColsJac];
      }
      
      if(!jacobian_no_casadi){
        jacobian = casadi::MX::sym("Jacobian",equations.size(),variables.size());
        nRowsJac = equations.size();
        nColsJac = variables.size();
        std::vector<casadi::MX> residuals;
        //append equations
        for(std::vector< Ref<Equation> >::iterator it=equations.begin(); 
                it != equations.end(); ++it){
            residuals.push_back((*it)->getLhs()-(*it)->getRhs());
        }
        casadi::MXFunction f(variables,residuals);
        f.init();
        for (int i=0;i<variables.size();++i){
            for(int j=0;j<equations.size();++j){
              casadi::MX jacotmp=f.jac(i,j);
              jacobian(j,i)=jacotmp;
              prettyPrintJacobian[j][i] = jacotmp;
            }
        }
      }
      else{
        if(block->computeJacobian()){
          ArrayJ< ArrayJ< FExp > > Jjacobian(block->jacobian().this$);
          jacobian = casadi::MX::sym("Jacobian",equations.size(),variables.size());
          if(nRowsJac!=Jjacobian.length){
            std::cout<<"WARNING: The jacobian coming from the compiler does not have the same number of rows as global equations";
          }
          if(nRowsJac!=Jjacobian[0].length){
            std::cout<<"WARNING: The jacobian coming from the compiler does not have the same number of cols as global variables";
          }
          for(int i=0;i<nRowsJac;++i)
          {
            for(int j=0;j<nColsJac;++j)
            {
              jacobian(i,j)= toMX(Jjacobian[i][j].toMX());
              prettyPrintJacobian[i][j] = toMX(Jjacobian[i][j].toMX());
            }
          }
        }
      }
      
      simple_flag = block->isSimple();
      solve_flag = block->isSolvable();
      linear_flag = block->isLinear();
      
      checkLinearityWithJacobian();
      //To ask if we do this
      if(solve_with_casadi){
        solveLinearSystem();
      }    
    }
#endif    
    
    bool& isSimple();
    bool& isLinear();
    bool& isSolvable();
    
    const bool& isSimple() const;
    const bool& isLinear() const;
    const bool& isSolvable() const;
    
    bool isInactive(const casadi::MX& var, int depth=0) const;
    bool isInactive(const std::string& varName) const;
    bool isIndependent(const casadi::MX& var, int depth=0) const;
    bool isIndependent(const std::string& varName) const;
    bool isTrajectoryVar(const casadi::MX& var, int depth=0) const;
    bool isTrajectoryVar(const std::string& varName) const;
    
    std::vector< casadi::MX > allBlockVariables() const;
    std::vector< casadi::MX > getSolvedVariables() const;
    std::vector< casadi::MX > getUnsolvedVariables() const;
    std::vector< casadi::MX > getIndependentVariables() const;
    std::vector< casadi::MX > getInactiveVariables() const;
    std::vector< casadi::MX > getTrajectoryVariables() const;
    //returns empty variable if not found
    casadi::MX getVariableByName(const std::string& name) const;
    casadi::MX getInactiveVarByName(const std::string& name) const;
    casadi::MX getIndependentVarByName(const std::string& name) const;
    casadi::MX getTrajectoryVarByName(const std::string& name) const;
    int getVariableIndex(const std::string& name) const;
    casadi::MX getSolutionOfVariable(const std::string& name) const;    
    bool hasSolution(const std::string& name) const;
    
    
    std::vector< Ref<Equation> > allEquations() const;
    std::vector< Ref<Equation> > notSolvedEquations() const;
    
    std::map<std::string, casadi::MX> getSolutionsMap() const;
    
    void addEquation(Ref<Equation> eq, bool solvable);
    void addSolutionToVariable(std::string varName, casadi::MX sol);
    
    void addBlockVariable(casadi::MX var, bool solvable);
    void addIndependentVariable(casadi::MX var);
    void addInactivVariable(casadi::MX var);
    void addTrajectoryVariable(casadi::MX var);
    
    void printBlock(std::ostream& out, bool withData=false) const;
    
    void checkLinearityWithJacobian();
    //solves if it is not solvable and append solutions to variableToSolution
    //Requires the jacobian to be computed in beforehand
    void solveLinearSystem();
    
    void substituteVariablesInExpressions(const std::vector<casadi::MX>& vars, const std::vector<casadi::MX>& subs);
    
    std::vector<casadi::MX> getEliminateableVariables() const;
    
    std::vector< Ref<Equation> > getEquations4Model() const; 
    
        
    MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
    
    // Vector containing pointers to block equations
    std::vector< Ref<Equation> > equations;
    // Vector containing pointers to block unsolved equations
    std::vector< Ref<Equation> > unSolvedEquations;
    // Vector containing pointers to block solved variables
    std::vector< casadi::MX > variables;
    // Vector containing pointers to block unsolved variables
    std::vector< casadi::MX > unSolvedVariables;
    
    //This are not consider as variables in the block but more like parameters
    // Vector containing pointers to block independent variables
    std::vector< casadi::MX > independentVariables; 
    // Vector containing pointers to block \upsion trajectory variables
    std::vector< casadi::MX > trajectoryVariables;
    // Vector containing pointers to block inactive variables (under diagonal)
    std::vector< casadi::MX > inactiveVariables;
    // Map with solution of variables
    std::map<std::string,casadi::MX> variableToSolution;
    // Map with variable names to index
    std::map<std::string,int> variableToIndex;
    
    //The jacobian stuff must be more efficiently implemented
    casadi::MX jacobian;
    int nRowsJac;
    int nColsJac;
    //Temporal
    casadi::MX** prettyPrintJacobian;
    
    //Simple flag
    bool simple_flag;
    bool linear_flag;
    bool solve_flag;

};

inline bool& Block::isSimple(){return simple_flag;}
inline bool& Block::isLinear(){return linear_flag;}
inline bool& Block::isSolvable(){return solve_flag;}

inline const bool& Block::isSimple() const{return simple_flag;}
inline const bool& Block::isLinear() const{return linear_flag;}
inline const bool& Block::isSolvable() const{return solve_flag;}

inline bool Block::isInactive(const casadi::MX& var,int depth/*=0*/) const{
  bool found=false;  
  for (std::vector<casadi::MX>::const_iterator it = inactiveVariables.begin(); 
      it != inactiveVariables.end(); ++it){
        if(it->isEqual(var,depth)){
          return 1;      
        }
  }
  return 0;
}


inline bool Block::isInactive(const std::string& varName) const{
  bool found = false;  
  for (std::vector<casadi::MX>::const_iterator it = inactiveVariables.begin(); 
    it != inactiveVariables.end(); ++it){
    if(it->getName()==varName){
      return 1;    
    }
  }
  return 0;
}

inline bool Block::isIndependent(const casadi::MX& var,int depth/*=0*/) const{
  bool found=false;  
  for (std::vector<casadi::MX>::const_iterator it = independentVariables.begin(); 
      it != independentVariables.end(); ++it){
        if(it->isEqual(var,depth)){
          return 1;      
        }
  }
  return 0;
}


inline bool Block::isIndependent(const std::string& varName) const{  
  for (std::vector<casadi::MX>::const_iterator it = independentVariables.begin(); 
    it != independentVariables.end(); ++it){
    if(it->getName()==varName){
      return 1;    
    }
  }
  return 0;
}

inline bool Block::isTrajectoryVar(const casadi::MX& var,int depth/*=0*/) const{ 
  for (std::vector<casadi::MX>::const_iterator it = trajectoryVariables.begin(); 
      it != trajectoryVariables.end(); ++it){
        if(it->isEqual(var,depth)){
          return 1;      
        }
  }
  return 0;
}


inline bool Block::isTrajectoryVar(const std::string& varName) const{  
  for (std::vector<casadi::MX>::const_iterator it = trajectoryVariables.begin(); 
    it != trajectoryVariables.end(); ++it){
    if(it->getName()==varName){
      return 1;    
    }
  }
  return 0;
}

inline void Block::checkLinearityWithJacobian(){
  if(!jacobian.isEmpty()){
    Block::isLinear() = !casadi::dependsOn(jacobian,variables);
  }
}

inline std::vector< casadi::MX > Block::allBlockVariables() const{
  std::vector< casadi::MX > vars(variables);
  return vars;
}  

inline std::vector< casadi::MX > Block::getUnsolvedVariables() const{
  std::vector< casadi::MX > vars(unSolvedVariables);
  return vars;  
}
  
inline std::vector< casadi::MX > Block::getIndependentVariables() const{
  std::vector< casadi::MX > vars(independentVariables);
  return vars;  
}
  
inline std::vector< casadi::MX > Block::getInactiveVariables() const{
  std::vector< casadi::MX > vars(inactiveVariables);
  return vars;  
}
  
inline std::vector< casadi::MX > Block::getTrajectoryVariables() const{
  std::vector< casadi::MX > vars(trajectoryVariables);
  return vars;  
}
  
inline std::vector< Ref<Equation> > Block::allEquations() const{
  std::vector< Ref<Equation> > eqs(equations);
  return eqs;  
}  

inline std::vector< Ref<Equation> > Block::notSolvedEquations() const{
  std::vector< Ref<Equation> > eqs(unSolvedEquations);
  return eqs;  
} 
  
inline std::map<std::string, casadi::MX> Block::getSolutionsMap() const{
  std::map<std::string, casadi::MX> solutions(variableToSolution);
  return solutions;
}

inline casadi::MX Block::getVariableByName(const std::string& name) const{
  for (std::vector<casadi::MX>::const_iterator it = variables.begin(); it != variables.end(); ++it){
    if(it->getName()==name){
      return (*it);    
    }
  }
  //To change later
  std::cout<<"Warning The variable was not found returning empty\n";
  return casadi::MX();
}


inline casadi::MX Block::getInactiveVarByName(const std::string& name) const{
  for (std::vector<casadi::MX>::const_iterator it = inactiveVariables.begin(); it != inactiveVariables.end(); ++it){
    if(it->getName()==name){
      return (*it);    
    }
  }
  //To change later
  std::cout<<"Warning The variable was not found returning empty\n";
  return casadi::MX();
}

inline casadi::MX Block::getIndependentVarByName(const std::string& name) const{
  for (std::vector<casadi::MX>::const_iterator it = independentVariables.begin(); it != independentVariables.end(); ++it){
    if(it->getName()==name){
      return (*it);    
    }
  }
  //To change later
  std::cout<<"Warning The variable was not found returning empty\n";
  return casadi::MX();
}

inline casadi::MX Block::getTrajectoryVarByName(const std::string& name) const{
  for (std::vector<casadi::MX>::const_iterator it = trajectoryVariables.begin(); it != trajectoryVariables.end(); ++it){
    if(it->getName()==name){
      return (*it);    
    }
  }
  //To change later
  std::cout<<"Warning The variable was not found returning empty\n";
  return casadi::MX();
}

inline int Block::getVariableIndex(const std::string& name) const{
  std::map<std::string,int>::const_iterator it = variableToIndex.find(name);
  if(it!=variableToIndex.end()){
    return it->second;   
  }
  else{
    //To change later
    std::cout<<"The variable was not found returning -1\n";
    return -1;
  }
}

inline casadi::MX Block::getSolutionOfVariable(const std::string& name) const{
  std::map<std::string,casadi::MX>::const_iterator it = variableToSolution.find(name);
  if(it!=variableToSolution.end()){
    return it->second;   
  }
  else{
    //To change later
    std::cout<<"The variable was not found returning -1\n";
    return casadi::MX();
  }
}

inline bool Block::hasSolution(const std::string& name) const{
  std::map<std::string, casadi::MX>::const_iterator it = variableToSolution.find(name);
  return ((it!=variableToSolution.end()) ? 1 : 0);
}

}; // End namespace
#endif
