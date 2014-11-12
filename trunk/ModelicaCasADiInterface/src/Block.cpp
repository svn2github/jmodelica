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

#include "Block.hpp"
#include <iomanip>
#include <iostream>


namespace ModelicaCasADi 
{
  
  void Block::addEquation(Ref<Equation> eq, bool solvable){
    bool found=false;
    for(std::vector< Ref<Equation> >::iterator it=equations.begin(); it != equations.end() && !found;++it){
        if((*it)->getLhs().getRepresentation()==eq->getLhs().getRepresentation() && 
            (*it)->getRhs().getRepresentation()==eq->getRhs().getRepresentation()){
          found=true;
        }
    }
    if(!found){
      equations.push_back(eq);    
    }
    else{
      std::cout<<"Warning: the equation ";
      eq->print(std::cout);
      std::cout<<" was already in equations\n";
    }
    if(!solvable)
    {
      found=false;
      for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin(); it != unSolvedEquations.end() && !found;++it){
          if((*it)->getLhs().getRepresentation()==eq->getLhs().getRepresentation() && 
              (*it)->getRhs().getRepresentation()==eq->getRhs().getRepresentation()){
            found=true;
          }
      }
      if(!found){
        unSolvedEquations.push_back(eq);    
      }
      else{
        std::cout<<"Warning: the equation ";
        eq->print(std::cout);
        std::cout<<" was already in unSolvedEquations\n";
      }
    }
  }
  
  void Block::printBlock(std::ostream& out,bool withData/*=false*/) const{
    out<<"----------------------------------------\n";
    out << "Number of variables z = (der(x),w): " << std::right << std::setw(10) << getNumVariables() << "\n";
    out << "Number of unsolved variables: " << std::right<< std::setw(16) << getNumUnsolvedVariables() << "\n";
    out << "Number of equations: " << std::right << std::setw(25) << getNumEquations() << "\n";
    out << "Number of unsolved equations: " << std::right << std::setw(16) << getNumUnsolvedEquations() << "\n";
    out << "Number of external variables: " << std::right << std::setw(16) << getNumExternalVariables() << "\n";
    out << "--------Flags---------\n";
    out << "BlockType: " << std::right << std::setw(20) << (isSimple() ? "SimpleBlock\n" : "EquationBlock\n");
    //if(!isSimple()){
    out << "Linearity: " << std::right << std::setw(18) << (isLinear() ? "LinearBlock\n" : "NonlinearBlock\n");
    //}
    if(isSimple()){
    out << "Solvability: " << std::right << std::setw(15) << (isSolvable() ? "Solvable\n" : "Unsolvable\n");
    }
    if(variableToSolution_.size()>0){
      out<<"Solutions:\n";
      for(std::map<const Variable*,casadi::MX>::const_iterator it=variableToSolution_.begin();
      it!=variableToSolution_.end();++it){
        out<< (it->first)->getVar() << " = " <<it->second<<"\n";
      }
    }
    out << "--------Details-------\n";    
    if(withData){
      if(getNumVariables()>0){
        out<< "Variables:\n";
        for (std::set<const Variable*>::const_iterator it = variables_.begin(); 
              it != variables_.end(); ++it){
          out << (*it)->getVar() << " ";      
        }
        
        out<<"\n";
      }
      if(getNumUnsolvedVariables()>0){
        out<< "\nUnsolved variables:\n";
        for (std::set<const Variable*>::const_iterator it = unSolvedVariables_.begin(); 
              it != unSolvedVariables_.end(); ++it){
          out << (*it)->getVar() << " ";      
        }
        out<<"\n";
      }
      if(getNumEquations()>0){
        out << "\nEquations:\n";
        for(std::vector< Ref<Equation> >::const_iterator it=equations.begin(); 
              it != equations.end(); ++it){
          out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
        }
      }
      if(getNumUnsolvedEquations()>0){
        out << "Unsolved equations:\n";
        for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin(); 
              it != unSolvedEquations.end(); ++it){
          out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
        }
      }
      if(getNumExternalVariables()>0){
        out<< "\nExternal variables:\n";
        for (std::set<const Variable*>::const_iterator it = externalVariables_.begin(); 
              it != externalVariables_.end(); ++it){
          out << (*it)->getVar() << " ";      
        }
        out<<"\n";
      }
    }
    
    //std::cout<<"Jacobian: \n"<<jacobian<<"\n";
    std::cout<<"Jacobian\n"<<jacobian<<"\n";
    out<<"---------------------------------------\n";
    
  }
  
  casadi::MX Block::computeJacobianCasADi(){
    symbolicVariables = casadi::MX::sym("symVars",variables_.size());
    std::vector<casadi::MX> vars;
    std::vector<casadi::MX> varsSubstitue;
    std::vector<casadi::MX> residuals;
    for(std::vector< Ref<Equation> >::iterator it=equations.begin(); 
                it != equations.end(); ++it){
            residuals.push_back((*it)->getLhs()-(*it)->getRhs());
    }
    for (std::map<const Variable*,int>::const_iterator it = variableToIndex_.begin(); 
              it != variableToIndex_.end(); ++it){
          vars.push_back(it->first->getVar());
          varsSubstitue.push_back(symbolicVariables(it->second));
    }
    
    std::vector<casadi::MX> Expressions = casadi::substitute(residuals,
                                         vars,
                                         varsSubstitue);
    casadi::MX symbolicResidual;
    for(std::vector< casadi::MX >::iterator it=Expressions.begin(); 
                it != Expressions.end(); ++it){
            symbolicResidual.append(*it);
    }
    
    casadi::MXFunction f(std::vector<casadi::MX>(1,symbolicVariables),std::vector<casadi::MX>(1,symbolicResidual));
    f.init();
    jacobian=f.jac();
  }
  
  void Block::solveLinearSystem(){
    if(isLinear() && !isSolvable()){
        //get the residuals
        std::vector<casadi::MX> residuals;
        //append equations
        for(std::vector< Ref<Equation> >::iterator it=equations.begin(); 
                it != equations.end(); ++it){
            residuals.push_back((*it)->getLhs()-(*it)->getRhs());
        }
        std::vector<casadi::MX> zeros(getNumVariables(),casadi::MX(0.0));
        std::vector<casadi::MX> b_ = casadi::substitute(residuals,
                                         variablesVector(),
                                         zeros);
        casadi::MX b;        
        for(std::vector<casadi::MX>::iterator it=b_.begin();
          it!=b_.end();++it){
           b.append(*it);       
        }
        //std::cout<<"b "<<b<<"\n";
        casadi::MX xsolution = casadi::solve(jacobian,-b);
        //std::cout<<"x "<<xsolution<<"\n";
        for(std::set<const Variable*>::const_iterator it = variables_.begin(); 
              it != variables_.end(); ++it){
            addSolutionToVariable(*it, xsolution[variableToIndex_[*it]]);
        }
        unSolvedEquations.clear();
        unSolvedVariables_.clear();
        solve_flag = true;
    }
  }
  
  void Block::substitute(const std::map<const Variable*, casadi::MX>& variableToExpression){
    std::vector<casadi::MX> varstoSubstitute;
    std::vector<casadi::MX> expforsubstitutition;
    std::vector<casadi::MX> Expressions;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToExpression.begin();
        it!=variableToExpression.end();++it){
          if(isExternal(it->first) && !it->first->getVar().isEmpty() && !it->second.isEmpty()){
            varstoSubstitute.push_back(it->first->getVar());
            expforsubstitutition.push_back(it->second);
          }
    }
    //Get expresions from variableToSolution map
    std::vector<const Variable*> keys; //Necesary because order is not determined
    for(std::map<const Variable*,casadi::MX>::iterator it=variableToSolution_.begin();
        it!=variableToSolution_.end();++it){
      keys.push_back(it->first);
      Expressions.push_back(it->second);
    }
    
    //Get expresions from equations
    if(!isSolvable()){
      for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin(); 
        it != unSolvedEquations.end();++it){
        Expressions.push_back((*it)->getLhs());
        Expressions.push_back((*it)->getRhs());
      }
    }
    //Make the substitutions
    std::vector<casadi::MX> subExpressions = casadi::substitute(Expressions,varstoSubstitute,expforsubstitutition);
    //retrive substitutions to constainers 
    for(int i=0;i<keys.size();++i){
      variableToSolution_[keys[i]]=subExpressions[i];      
    }
    if(!isSolvable()){
      int j=0;
      for(int i=keys.size();i<subExpressions.size();i+=2){
        unSolvedEquations[j]->setLhs(subExpressions[i]);
        unSolvedEquations[j]->setRhs(subExpressions[i+1]);
        ++j;
      }
    }
    
  }
  
  std::set<const Variable*> Block::eliminateableVariables() const{
    std::set<const Variable*> keys;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToSolution_.begin();
        it!=variableToSolution_.end();++it){
          keys.insert(it->first);
    }
    return keys;
  }
  
  std::vector< Ref<Equation> > Block::getEquationsforModel() const{
    std::vector< Ref<Equation> > modelEqs;
    for(std::map<const Variable*, casadi::MX>::const_iterator it = variableToSolution_.begin();
        it!=variableToSolution_.end();++it){
        modelEqs.push_back(new Equation(it->first->getVar(),it->second));
    }
     
    for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin(); 
        it != unSolvedEquations.end();++it){
          modelEqs.push_back(new Equation((*it)->getLhs(),(*it)->getRhs()));;
    }
    return modelEqs; 
  }
  


}; // End namespace
