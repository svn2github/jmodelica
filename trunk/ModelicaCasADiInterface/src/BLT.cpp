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

#include "BLT.hpp"

namespace ModelicaCasADi
{
    void BLT::printBLT(std::ostream& out, bool with_details/*=false*/) const
    {
        int i=0;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
                out << "Block[" <<i<<"]\n";
                (*it)->printBlock(out,with_details);
                ++i;
        }
    }
    
    std::set<const Variable*> BLT::eliminableVariables() const{
        std::set<const Variable*> vars;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
            std::set<const Variable*> blockVars = (*it)->eliminableVariables();
            vars.insert(blockVars.begin(), blockVars.end());
        }
        return vars;
    }
    
    void BLT::getSubstitues(const std::set<const Variable*>& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const{
        
        for(std::set<const Variable*>::const_iterator it_e = eliminables.begin(); 
              it_e != eliminables.end(); ++it_e){
            bool found=0;
            casadi::MX tmp_subs;
            for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
                it!=blt.end() && !found;++it){
                if((*it)->hasSolution(*it_e)){
                   casadi::MX exp = (*it)->getSolutionOfVariable(*it_e);
                   tmp_subs=exp;
                   found=1;
                }
            }
            
            //substitute previous variables in eliminables
            if(storageMap.size()>0){
                if(found){
                    std::vector<casadi::MX> inner_subs;
                    std::vector<casadi::MX> inner_elim;
                    for(std::map<const Variable*,casadi::MX>::const_iterator it_prev=storageMap.begin(); it_prev!=storageMap.end();++it_prev){
                        int ndeps =tmp_subs.getNdeps();
                        for(int j=0;j<ndeps;++j){
                            if(tmp_subs.getDep(j).isEqual(it_prev->first->getVar(),0) && !it_prev->second.isEmpty()){
                                 inner_subs.push_back(it_prev->second);
                                 inner_elim.push_back(it_prev->first->getVar()); 
                            }
                        }
                    }
                    std::vector<casadi::MX> subExp = casadi::substitute(std::vector<casadi::MX>(1,tmp_subs),inner_elim,inner_subs);
                    storageMap.insert(std::pair<const Variable*,casadi::MX>(*it_e,subExp.front()));
                    inner_subs.clear();
                    inner_elim.clear();
                }
            }
            else{
               if(found){storageMap.insert(std::pair<const Variable*,casadi::MX>(*it_e,tmp_subs));} 
            }
            if(!found){
                //If the variable is empty the substitution in the block will be ignored
                std::cout<<"Warning: The variable "<< (*it_e)->getName() << "is not eliminable. It will be ignore at the substitution.\n";
                storageMap.insert(std::pair<const Variable*,casadi::MX>(*it_e,casadi::MX()));
            }
        }
    }
    
    void BLT::getSubstitues(const Variable* eliminable, std::map<const Variable*,casadi::MX>& storageMap) const{
        bool found=0;
        casadi::MX tmp_subs;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end() && !found;++it){
            if((*it)->hasSolution(eliminable)){
               casadi::MX exp = (*it)->getSolutionOfVariable(eliminable);
               tmp_subs=exp;
               found=1;
            }
        }
        
        //substitute previous variables in eliminables
        if(storageMap.size()>0){
            if(found){
                std::vector<casadi::MX> inner_subs;
                std::vector<casadi::MX> inner_elim;
                for(std::map<const Variable*,casadi::MX>::const_iterator it_prev=storageMap.begin(); it_prev!=storageMap.end();++it_prev){
                    int ndeps =tmp_subs.getNdeps();
                    for(int j=0;j<ndeps;++j){
                        if(tmp_subs.getDep(j).isEqual(it_prev->first->getVar(),0) && !it_prev->second.isEmpty()){
                             inner_subs.push_back(it_prev->second);
                             inner_elim.push_back(it_prev->first->getVar()); 
                        }
                    }
                }
                std::vector<casadi::MX> subExp = casadi::substitute(std::vector<casadi::MX>(1,tmp_subs),inner_elim,inner_subs);
                storageMap.insert(std::pair<const Variable*,casadi::MX>(eliminable,subExp.front()));
                inner_subs.clear();
                inner_elim.clear();
            }
        }
        else{
           if(found){storageMap.insert(std::pair<const Variable*,casadi::MX>(eliminable,tmp_subs));} 
        }
        if(!found){
            //If the variable is empty the substitution in the block will be ignored
            std::cout<<"Warning: The variable "<< eliminable->getName() << "is not eliminable. It will be ignore at the substitution.\n";
            storageMap.insert(std::pair<const Variable*,casadi::MX>(eliminable,casadi::MX()));
        }
    }
    
    
    void BLT::getSubstitues(const std::list< std::pair<int, Variable*> >& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const{
        
        for(std::list< std::pair<int, Variable*> >::const_reverse_iterator it_var=eliminables.rbegin();
            it_var!=eliminables.rend();++it_var){
            casadi::MX solution = blt[it_var->first]->getSolutionOfVariable(it_var->second); 
            for(std::list< std::pair<int, Variable*> >::const_reverse_iterator it_var2(it_var);
                it_var2!=eliminables.rend();++it_var2){
                casadi::MX tmp = solution;
                
                solution = casadi::substitute(tmp,
                                              it_var2->second->getVar(),
                                              blt[it_var2->first]->getSolutionOfVariable(it_var2->second));        
            }
            storageMap[it_var->second]=solution;
        }
    }
    
    std::vector< Ref<Equation> > BLT::getDaeEquations() const{
        std::vector< Ref<Equation> > modelEquations;
        for(std::vector< Ref<Block> >::const_iterator it=blt.begin();
            it!=blt.end();++it){
            std::vector< Ref<Equation> > blockEqs = (*it)->getEquationsforModel();
            modelEquations.reserve( modelEquations.size() + blockEqs.size() ); 
            modelEquations.insert( modelEquations.end(), blockEqs.begin(), blockEqs.end() );
        }
        return modelEquations;
    }
    
    const casadi::MX BLT::getDaeResidual() const{
        casadi::MX residual;
        std::vector< Ref<Equation> > modelEquations = getDaeEquations();
        for(std::vector< Ref<Equation> >::const_iterator it=modelEquations.begin();it!=modelEquations.end();++it){
            residual.append((*it)->getResidual());
        }
        return residual;
    }
    
    void BLT::substituteAllEliminables(){
        std::set<const Variable*> externalVars;
        std::map<const Variable*,casadi::MX> substitutionMap;
        for(std::vector< Ref<Block> >::iterator fit=blt.begin()+1;
            fit!=blt.end();++fit){
            externalVars = (*fit)->externalVariables();
            for(std::set<const Variable*>::const_iterator it_e = externalVars.begin(); 
              it_e != externalVars.end(); ++it_e){
                bool found =0;
                for(std::vector< Ref<Block> >::reverse_iterator rit(fit);rit!=blt.rend() && !found;++rit){
                    if((*rit)->hasSolution((*it_e))){
                        casadi::MX exp = (*rit)->getSolutionOfVariable((*it_e));
                        substitutionMap.insert(std::pair<const Variable*,casadi::MX>((*it_e),exp));
                        found=1;
                    }
                }
                if(!found){
                    //If the variable is empty the substitution in the block will be ignored
                    substitutionMap.insert(std::pair<const Variable*,casadi::MX>((*it_e),casadi::MX()));
                }
            }
            (*fit)->substitute(substitutionMap);
            substitutionMap.clear();
        }
    }
    
    void BLT::removeSolutionOfVariable(const Variable* var){
        bool found=0;
        for(std::vector< Ref<Block> >::iterator it=blt.begin();
            it!=blt.end() && !found ;++it){
            if((*it)->removeSolutionOfVariable(var)){              
               found=1;         
            }
        }
        if(!found){std::cout<<"The variable "<<var->getName()<<" does not have a solution in BLT.\n";}
    }
    
    void BLT::substitute(const std::map<const Variable*,casadi::MX>& substituteMap){
        for(std::vector< Ref<Block> >::iterator it=blt.begin();
            it!=blt.end();++it){
            (*it)->substitute(substituteMap);
        } 
    }
    
    bool BLT::isBLTEliminable(Ref<Variable> var) const{
        std::set<const Variable*> eliminateables = eliminableVariables();
        std::set<const Variable*>::const_iterator it = eliminateables.find(var.getNode());
        if(it!=eliminateables.end()){
            return 1;    
        }
        return 0;    
    }
    
    void BLT::eliminateVariables(const std::map<const Variable*,casadi::MX>& substituteMap){
        substitute(substituteMap);    
        for(std::map<const Variable*,casadi::MX>::const_iterator it=substituteMap.begin();it!=substituteMap.end();++it){
            removeSolutionOfVariable(it->first);
        }
    }
    
    //Experimental
    void BLT::propagateExternals(){
        std::vector< Ref<Block> >::iterator previous;
        for(std::vector< Ref<Block> >::iterator it=blt.begin()+1;
            it!=blt.end();++it){
            previous=it-1;
            bool exit=false;
            std::set<const Variable*> current_externals = (*it)->externalVariables();
            for(std::set<const Variable*>::iterator it_e=current_externals.begin();
                it_e!=current_externals.end() && !exit;++it_e){
                if((*previous)->isBlockVariable(*it_e)){
                    exit=true;                
                }
            }
            if(exit){
                std::set<const Variable*> previous_externals = (*previous)->externalVariables();
                for(std::set<const Variable*>::iterator it_e=previous_externals.begin();
                it_e!=previous_externals.end() && !exit;++it_e){
                    (*previous)->addExternalVariable(*it_e);                
                }
            }
        }
    }
    
    int BLT::getBlockIDWithSolutionOf(Ref<Variable> var){
        int counter=0;
        for(std::vector< Ref<Block> >::iterator fit=blt.begin();
            fit!=blt.end();++fit){
            if((*fit)->hasSolution(var.getNode())){
                return counter;                
            }
            ++counter;
        }
        return -1;
    }
}; //End namespace