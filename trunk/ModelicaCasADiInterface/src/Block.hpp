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
    Block(): simple_flag(false),linear_flag(false),solve_flag(false){}
    
    bool isSimple() const;
    bool isLinear() const;
    bool isSolvable() const;
    
    bool setasSimple(bool flag){simple_flag=flag;}
    bool setasLinear(bool flag){linear_flag=flag;}
    bool setasSolvable(bool flag){solve_flag=flag;}
    
    bool isInactive(const casadi::MX& var, int depth=0) const;
    bool isInactive(const std::string& varName) const;
    bool isIndependent(const casadi::MX& var, int depth=0) const;
    bool isIndependent(const std::string& varName) const;
    bool isTrajectoryVar(const casadi::MX& var, int depth=0) const;
    bool isTrajectoryVar(const std::string& varName) const;
    
    int getNumEquations() const {return equations.size();}
    int getNumVariables()const {return variables.size();}
    int getNumUnsolvedEquations() const {return unSolvedEquations.size();}
    int getNumUnsolvedVariables() const {return unSolvedVariables.size();}
    int getNumInactiveVariables() const {return inactiveVariables.size();}
    int getNumIndependentVariables() const {return independentVariables.size();}
    int getNumTrajectoryVariables() const {return trajectoryVariables.size();}
    
    std::vector< casadi::MX > allBlockVariables() const;
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
    
    
    void setJacobian(const casadi::MX& jac);
    std::vector< Ref<Equation> > allEquations() const;
    std::vector< Ref<Equation> > notSolvedEquations() const;
    
    std::map<std::string, casadi::MX> getSolutionsMap() const;
    
    void addEquation(Ref<Equation> eq, bool solvable);
    void addSolutionToVariable(std::string varName, casadi::MX sol);
    void removeSolutionOfVariable(std::string varName);
    
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
    
    //Simple flag
    bool simple_flag;
    bool linear_flag;
    bool solve_flag;

};

inline void Block::setJacobian(const casadi::MX& jac){jacobian = jac;}
inline bool Block::isSimple() const {return simple_flag;}
inline bool Block::isLinear() const {return linear_flag;}
inline bool Block::isSolvable() const {return solve_flag;}


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
    linear_flag = !casadi::dependsOn(jacobian,variables);
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
