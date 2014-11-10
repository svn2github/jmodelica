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
  
  void Block::addSolutionToVariable(std::string varName, casadi::MX sol){
    bool found=false;
    for(std::map<std::string,casadi::MX>::iterator it=variableToSolution.begin();
      it!=variableToSolution.end() && !found;++it){
        if(it->first==varName){
          found=true;        
        }
    }
    if(found){
      std::cout<<"Warning: the variable "<<varName<<" has already a solution: ";
      std::cout<<variableToSolution[varName]<<"\n";
    }
    else{  
      variableToSolution[varName]=sol;
    }
  }
  
  void Block::addBlockVariable(casadi::MX var, bool solvable){
    bool found=false;
    for (std::vector<casadi::MX>::iterator it = variables.begin(); it != variables.end() && !found; ++it){
      if(it->isEqual(var)){found=true;}
    }
    if(!found){
      variables.push_back(var);
      variableToIndex[var.getName()]=variables.size();
    }
    else{
      std::cout<<"Warning: the variable "<< var.getName() <<" was already in Variables\n";
    }
    if(!solvable){
       found=false;
       for (std::vector<casadi::MX>::iterator it = unSolvedVariables.begin(); it != unSolvedVariables.end() && !found; ++it){
          if(it->isEqual(var)){found=true;}
       }
       if(!found){
         unSolvedVariables.push_back(var);
       }
       else{
         std::cout<<"Warning: the variable "<< var.getName() <<" was already in unSolvedVariables\n";
       }
    }
  }
  
  void Block::addIndependentVariable(casadi::MX var){
    bool found=false;
    for (std::vector<casadi::MX>::iterator it = independentVariables.begin(); it != independentVariables.end() && !found; ++it){
      if(it->isEqual(var)){found=true;}
    }
    if(!found){
      independentVariables.push_back(var);
    }
    else
    {
      std::cout<<"Warning: the variable "<< var.getName() <<" was already in independentVariables\n";
    }
  }
  void Block::addInactivVariable(casadi::MX var){
    bool found=false;
    for (std::vector<casadi::MX>::iterator it = inactiveVariables.begin(); it != inactiveVariables.end() && !found; ++it){
      if(it->isEqual(var)){found=true;}
    }
    if(!found){
      inactiveVariables.push_back(var);
    }
    else{
      std::cout<<"Warning: the variable "<< var.getName() <<" was already in inactiveVariables\n";
    }
  }
  void Block::addTrajectoryVariable(casadi::MX var){
    bool found=false;
    for (std::vector<casadi::MX>::iterator it = trajectoryVariables.begin(); it != trajectoryVariables.end() && !found; ++it){
      if(it->isEqual(var)){found=true;}
    }
    if(!found){
      trajectoryVariables.push_back(var);
    }
    else{
      std::cout<<"Warning: the variable "<< var.getName() <<" was already in trajectoryVariables\n";
    }  
  }
  
  void Block::printBlock(std::ostream& out,bool withData/*=false*/) const{
    out<<"----------------------------------------\n";
    out << "Number of variables z = (der(x),w): " << std::right << std::setw(10) << getNumVariables() << "\n";
    out << "Number of unsolved variables: " << std::right<< std::setw(16) << getNumUnsolvedVariables() << "\n";
    out << "Number of equations: " << std::right << std::setw(25) << getNumEquations() << "\n";
    out << "Number of unsolved equations: " << std::right << std::setw(16) << getNumUnsolvedEquations() << "\n";
    out << "Number of inactive variables: " << std::right << std::setw(16) << getNumInactiveVariables() << "\n";
    out << "Number of trajectory variables v = (t,x,u): " << std::right << std::setw(2) << getNumTrajectoryVariables() << "\n";
    out << "Number of independent variables: " << std::right << std::setw(13) << getNumIndependentVariables() << "\n";
    out << "--------Flags---------\n";
    out << "BlockType: " << std::right << std::setw(20) << (isSimple() ? "SimpleBlock\n" : "EquationBlock\n");
    //if(!isSimple()){
    out << "Linearity: " << std::right << std::setw(18) << (isLinear() ? "LinearBlock\n" : "NonlinearBlock\n");
    //}
    if(isSimple()){
    out << "Solvability: " << std::right << std::setw(15) << (isSolvable() ? "Solvable\n" : "Unsolvable\n");
    }
    if(variableToSolution.size()>0){
      out<<"Solutions:\n";
      for(std::map<std::string,casadi::MX>::const_iterator it=variableToSolution.begin();
      it!=variableToSolution.end();++it){
        out<< getVariableByName(it->first) << " = " <<it->second<<"\n";
      }    
    }
    out << "--------Details-------\n";    
    if(withData){
      if(variables.size()>0){
        out<< "Variables:\n";
        for (std::vector<casadi::MX>::const_iterator it = variables.begin(); 
              it != variables.end(); ++it){
          out << (*it) << " ";      
        }
        out<<"\n";
      }
      if(unSolvedVariables.size()>0){
        out<< "\nUnsolved variables:\n";
        for (std::vector<casadi::MX>::const_iterator it = unSolvedVariables.begin(); 
              it != unSolvedVariables.end(); ++it){
          out << (*it) << " ";      
        }
        out<<"\n";
      }
      if(equations.size()>0){
        out << "\nEquations:\n";
        for(std::vector< Ref<Equation> >::const_iterator it=equations.begin(); 
              it != equations.end(); ++it){
          out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
        }
      }
      if(unSolvedEquations.size()>0){
        out << "Unsolved equations:\n";
        for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin(); 
              it != unSolvedEquations.end(); ++it){
          out<<(*it)->getLhs()<<" = "<<(*it)->getRhs()<<"\n";
        }
      }
      if(inactiveVariables.size()>0){
        out<< "\nInactive variables:\n";
        for (std::vector<casadi::MX>::const_iterator it = inactiveVariables.begin(); 
              it != inactiveVariables.end(); ++it){
          out << (*it) << " ";      
        }
        out<<"\n";
      }
      if(trajectoryVariables.size()>0){
        out<< "\nTrajectory variables:\n";
        for (std::vector<casadi::MX>::const_iterator it = trajectoryVariables.begin(); 
              it != trajectoryVariables.end(); ++it){
          out << (*it) << " ";      
        }
        out<<"\n";
      }
      if(independentVariables.size()>0){
        out<< "\nIndependent variables:\n";
        for (std::vector<casadi::MX>::const_iterator it = independentVariables.begin(); 
              it != independentVariables.end(); ++it){
          out << (*it) << " ";      
        }
        out<<"\n";
      }
    }
    
    //std::cout<<"Jacobian: \n"<<jacobian<<"\n";
    std::cout<<"Jacobian\n"<<jacobian<<"\n";
    out<<"---------------------------------------\n";
    
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
        std::vector<casadi::MX> zeros(variables.size(),casadi::MX(0.0));
        std::vector<casadi::MX> b_ = casadi::substitute(residuals,
                                         variables,
                                         zeros);
        casadi::MX b;        
        for(std::vector<casadi::MX>::iterator it=b_.begin();
          it!=b_.end();++it){
           b.append(*it);       
        }
        //std::cout<<"b "<<b<<"\n";
        casadi::MX xsolution = casadi::solve(jacobian,-b);
        //std::cout<<"x "<<xsolution<<"\n";
        int i=0;
        for(std::vector<casadi::MX>::const_iterator it = variables.begin(); 
              it != variables.end(); ++it){
          addSolutionToVariable(it->getName(), xsolution[i]);
          ++i;
        }
        unSolvedEquations.clear();
        unSolvedVariables.clear();
        solve_flag = true;
    }
  }
  
  void Block::substituteVariablesInExpressions(const std::vector<casadi::MX>& vars, const std::vector<casadi::MX>& subs){
    
    assert (vars.size()==subs.size());

    std::vector<casadi::MX> varstoSubstitute;
    std::vector<casadi::MX> substoSubstitute;
    for(int i=0;i<vars.size();++i){
      if(isInactive(vars[i].getName()) || isIndependent(vars[i].getName()) || isTrajectoryVar(vars[i].getName()))
      {
        if(!subs[i].isEmpty() && !vars[i].isEmpty()){
          varstoSubstitute.push_back(vars[i]);
          substoSubstitute.push_back(subs[i]);
        }
      }
    }
    std::vector<casadi::MX> Expressions;
    //Necesary because order is not determined
    std::vector<std::string> keys;
    for(std::map<std::string,casadi::MX>::iterator it=variableToSolution.begin();
        it!=variableToSolution.end();++it){
      keys.push_back(it->first);
      Expressions.push_back(it->second);
    }
    //Not solved equations
    if(!isSolvable()){
      for(std::vector< Ref<Equation> >::iterator it=unSolvedEquations.begin(); 
        it != unSolvedEquations.end();++it){
        Expressions.push_back((*it)->getLhs());
        Expressions.push_back((*it)->getRhs());
      }
    }
    //Make the substitutions
    std::vector<casadi::MX> subExpressions = casadi::substitute(Expressions,varstoSubstitute,substoSubstitute);
    //retrive substitutions to constainers      
    for(int i=0;i<keys.size();++i){
      variableToSolution[keys[i]]=subExpressions[i];      
    }
    if(!isSolvable()){
      int j=0;
      for(int i=keys.size();i<subExpressions.size();i+=2){
        unSolvedEquations[j]->setLhs(subExpressions[i]);
        unSolvedEquations[j]->setRhs(subExpressions[i+1]);
        ++j;
      }
    }
    /*unSolvedEquations.clear();
    for(int i=keys.size();i<subExpressions.size();i+=2){
      unSolvedEquations.push_back(new Equation(subExpressions[i],subExpressions[i+1]));    
    }*/
  }
  
  std::vector<casadi::MX> Block::getEliminateableVariables() const {
    std::vector<casadi::MX> vars;  
    for(std::map<std::string, casadi::MX>::const_iterator it = variableToSolution.begin();
        it!=variableToSolution.end();++it){
          casadi::MX v = getVariableByName(it->first);
          if(!v.isEmpty()){
            vars.push_back(v);
          }
    }
    return vars;
  }
  
  void Block::removeSolutionOfVariable(std::string varName){
    std::map<std::string, casadi::MX>::iterator it = variableToSolution.find(varName);
    if(it!=variableToSolution.end()){
      variableToSolution.erase(it);    
    }
    else{
      std::cout<<"The variable "<<varName<<" does not have a solution thus it cannot be removed.\n";    
    }
  }
  
  std::vector< Ref<Equation> > Block::getEquations4Model() const{
    std::vector< Ref<Equation> > modelEqs;
    for(std::map<std::string, casadi::MX>::const_iterator it = variableToSolution.begin();
        it!=variableToSolution.end();++it){
      casadi::MX v = getVariableByName(it->first);
      if(!v.isEmpty()){
        modelEqs.push_back(new Equation(v,it->second));
      }
    }
     
    for(std::vector< Ref<Equation> >::const_iterator it=unSolvedEquations.begin(); 
        it != unSolvedEquations.end();++it){
          modelEqs.push_back(new Equation((*it)->getLhs(),(*it)->getRhs()));;
    }
    return modelEqs; 
  }
  


}; // End namespace
