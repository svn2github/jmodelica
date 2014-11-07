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

#include "BLTHandler.hpp"
#include <iomanip>
#include <iostream>

namespace ModelicaCasADi
{
    void BLTHandler::printBLT(std::ostream& out, bool with_details/*=false*/) const
    {
        int i=0;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
                out << "Block[" <<i<<"]\n";
                (*it)->printBlock(out,with_details);
                ++i;
        }
    }
    
    std::vector<casadi::MX> BLTHandler::getAllEliminatableVariables() const{
        std::vector<casadi::MX> vars;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
            std::vector<casadi::MX> blockVars = (*it)->getEliminateableVariables();
            vars.reserve( vars.size() + blockVars.size() ); 
            vars.insert( vars.end(), blockVars.begin(), blockVars.end() );
        }
        return vars;
    }
    
    std::vector< Ref<Equation> > BLTHandler::getAllEquations4Model() const{
        std::vector< Ref<Equation> > modelEquations;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
            std::vector< Ref<Equation> > blockEqs = (*it)->getEquations4Model();
            modelEquations.reserve( modelEquations.size() + blockEqs.size() ); 
            modelEquations.insert( modelEquations.end(), blockEqs.begin(), blockEqs.end() );
        }
        return modelEquations;
    }
    std::vector<casadi::MX> BLTHandler::getSubstitues(const std::vector<casadi::MX>& eliminateables) const{
        std::vector<casadi::MX> subs;
        for(std::vector<casadi::MX>::const_iterator it_e = eliminateables.begin(); 
              it_e != eliminateables.end(); ++it_e){
            bool found=0;
            for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
                it!=blt.end() && !found;++it){
                if((*it)->hasSolution(it_e->getName())){
                   casadi::MX exp = (*it)->getSolutionOfVariable(it_e->getName());
                   subs.push_back(exp);
                   found=1;
                }
            }
            if(!found){
                //If the variable is empty the substitution in the block will be ignored
                std::cout<<"Warning: The variable "<< *it_e << "is not eliminateable. It will be ignore at the substitution.\n";
                subs.push_back(casadi::MX()); 
            }
        }
        return subs;
    }
    
    
    void BLTHandler::substituteAllEliminateables(){
        //This is not efficient.. it does not use the blt order for the substitutions. TO BE improved
        /*std::vector<casadi::MX> vars = getAllEliminatableVariables();
        std::vector<casadi::MX> subs = getSubstitues(vars);
        for(std::vector< Ref<Block> >::iterator it=blt.begin();
            it!=blt.end();++it){
            (*it)->substituteVariablesInExpressions(vars,subs);
            subs = getSubstitues(vars);
        }*/
        
        std::vector<casadi::MX> inactives;
        std::vector<casadi::MX> blockSubstitutes;
        for(std::vector< Ref<Block> >::iterator fit=blt.begin()+1;
            fit!=blt.end();++fit){
            inactives = (*fit)->getInactiveVariables();
            for(std::vector<casadi::MX>::const_iterator it_e = inactives.begin(); 
              it_e != inactives.end(); ++it_e){
                bool found =0;
                for(std::vector< Ref<Block> >::reverse_iterator rit(fit);rit!=blt.rend() && !found;++rit){
                    if((*rit)->hasSolution(it_e->getName())){
                        casadi::MX exp = (*rit)->getSolutionOfVariable(it_e->getName());
                        blockSubstitutes.push_back(exp);
                        found=1;
                    }
                }
                if(!found){
                    //If the variable is empty the substitution in the block will be ignored
                    //std::cout<<"The variable "<< *it_e << "was not found. It will be ignore at the substitution.\n";
                    blockSubstitutes.push_back(casadi::MX()); 
                }
            }
            (*fit)->substituteVariablesInExpressions(inactives,blockSubstitutes);
            blockSubstitutes.clear();
        }
    }
}; //End namespace