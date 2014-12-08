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

#include "OptimizationProblem.hpp"
using std::ostream; using casadi::MX;

namespace ModelicaCasADi
{

    OptimizationProblem::~OptimizationProblem() {
        // Delete all the OptimizationProblem's variables, since they are OwnedNodes with the OptimizationProblem as owner.
        for (std::vector< TimedVariable * >::iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            delete *it;
            *it = NULL;
        }
    }

    void OptimizationProblem::initializeProblem(std::string identifier /* = "" */, bool normalizedTime /* = true */ ) {
        Model::initializeModel(identifier);
        this->normalizedTime = normalizedTime;
    }


    std::vector< Ref<TimedVariable> > OptimizationProblem::getTimedVariables() const
    {
        std::vector< Ref<TimedVariable> > result;
        for (std::vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            result.push_back(*it);
        }
        return result;
    }


    void OptimizationProblem::print(ostream& os) const
    {
        //    os << "OptimizationProblem<" << this << ">"; return;
    
        using namespace std;
        os << "Model contained in OptimizationProblem:\n" << endl;
        Model::print(os);
        os << "----------------------- Optimization information ------------------------\n\n";
        os << "Start time = ";
        if (startTime.isEmpty()) {
            os << "not set";
        }
        else {
            startTime.print(os);
        }
    
        os << "\nFinal time = ";
        if (finalTime.isEmpty()) {
            os << "not set";
        }
        else {
            finalTime.print(os);
        }
    
        os << "\n\n";
        for (vector< Ref<Constraint> >::const_iterator it = pathConstraints.begin(); it != pathConstraints.end(); ++it) {
            if (it == pathConstraints.begin()) {
                os << "-- Path constraints --" << endl;
            }
            os << *it << endl;
        }
        for (vector< Ref<Constraint> >::const_iterator it = pointConstraints.begin(); it != pointConstraints.end(); ++it) {
            if (it == pointConstraints.begin()) {
                os << "-- Point constraints --" << endl;
            }
            os << *it << endl;
        }
        for (vector< TimedVariable * >::const_iterator it = timedVariables.begin(); it != timedVariables.end(); ++it) {
            if (it == timedVariables.begin()) {
                os << "\n-- Timed variables --\n";
            }
            os << **it << endl;
        }
    
        os << "\n-- Objective integrand term --\n";
        if (objectiveIntegrand.isEmpty()) {
            os << "not set";
        }
        else {
            objectiveIntegrand.print(os);
        }
    
        os << "\n-- Objective term --\n";
        if (objective.isEmpty()) {
            os << "not set";
        }
        else {
            objective.print(os);
        }
    }


    void OptimizationProblem::eliminateAlgebraics() {
        if(!hasBLT()) {
            throw std::runtime_error("Only Models with BLT can eliminate variables. Please enable the equation_sorting compiler option.\n");        
        }
        std::vector< Ref<Variable> > algebraics = getVariables(REAL_ALGEBRAIC);
        std::vector< Ref<Variable> > eliminable_algebraics;
        for(std::vector< Ref<Variable> >::iterator it = algebraics.begin(); it!=algebraics.end(); ++it){
            if((*it)->isEliminable()){
                eliminable_algebraics.push_back(*it);        
            }
        }
        markVariablesForElimination(eliminable_algebraics);
        eliminateVariables();
    }

    bool compareFunction2(const std::pair<int, const Variable*>& a, const std::pair<int, const Variable*>& b) {
        return a.first < b.first;
    }

    void OptimizationProblem::substituteAllEliminables() {
        if(hasBLT()) {
            
            std::set<const Variable*> eliminateables = equations_->eliminableVariables();
            std::vector< Ref<Variable> > alias_vars = getAliases();
            std::vector< Ref<TimedVariable> > timedVars = getTimedVariables();
            std::list< std::pair<int, const Variable*> > toSubstituteList;
            bool hasAlias=false;
            for(std::set<const Variable*>::iterator it=eliminateables.begin();it!=eliminateables.end();++it) {
                hasAlias=false;
                for(std::vector< Ref<Variable> >::iterator it_alias = alias_vars.begin();
                it_alias!=alias_vars.end() && !hasAlias;++it_alias) {
                    if(*it==(*it_alias)->getModelVariable().getNode()) {
                        hasAlias=true;
                    }
                }
                bool isTimed=false;
                for(std::vector< Ref<TimedVariable> >::iterator tit=timedVars.begin();tit!=timedVars.end() && !isTimed;++tit) {
                    if(*it==(*tit)->getBaseVariable().getNode()) {
                        isTimed=true;
                    }
                }
                if(!isTimed && !hasAlias) {
                    Ref<Variable> var = const_cast<Variable*>(*it);
                    int id_block = equations_->getBlockIDWithSolutionOf(var);
                    if(id_block>=0) {
                        toSubstituteList.push_back(std::pair<int, const Variable*>(id_block,var.getNode()));
                    }
                }
                
            }            
            toSubstituteList.sort(compareFunction2);
            std::map<const Variable*,casadi::MX> tmpMap;
            equations_->getSubstitues(toSubstituteList, tmpMap);
            std::vector<casadi::MX> eliminatedMXs;
            std::vector<casadi::MX> subtitutes;
            for(std::map<const Variable*,casadi::MX>::const_iterator it=tmpMap.begin();
            it!=tmpMap.end();++it) {
                eliminatedMXs.push_back(it->first->getVar());
                subtitutes.push_back(it->second);
            }
    
            //Substitutes in the optimization expressions
            std::vector<casadi::MX> expressions;
            expressions.push_back(startTime);
            expressions.push_back(finalTime);
            expressions.push_back(objectiveIntegrand);
            expressions.push_back(objective);
    
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    expressions.push_back((*path_it)->getLhs());
                    expressions.push_back((*path_it)->getRhs());
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    expressions.push_back((*point_it)->getLhs());
                    expressions.push_back((*point_it)->getRhs());
                }
            }
    
            std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes);
    
            int counter=0;
            startTime = subtitutedExpressions[counter++];
            finalTime = subtitutedExpressions[counter++];
            objectiveIntegrand = subtitutedExpressions[counter++];
            objective = subtitutedExpressions[counter++];
    
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    (*path_it)->setLhs(subtitutedExpressions[counter++]);
                    (*path_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    (*point_it)->setLhs(subtitutedExpressions[counter++]);
                    (*point_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
    
            //Substitutes in DAE
            equations_->substitute(tmpMap);
        }
        else {
            std::cout<<"The Model does not have symbolic manipulation capabilities. Try with BLT\n.";
        }
    }


    void OptimizationProblem::markVariablesForElimination(const std::vector< Ref<Variable> >& vars) {
        if(hasBLT()) {
            std::vector< Ref<Variable> > alias_vars = getAliases();
            std::vector< Ref<TimedVariable> > timedVars = getTimedVariables();
            bool hasAlias=false;
            for(std::vector< Ref<Variable> >::const_iterator it=vars.begin();it!=vars.end();++it) {
                if((*it)->isEliminable()) {
                    hasAlias=false;
                    for(std::vector< Ref<Variable> >::iterator it_alias = alias_vars.begin();
                    it_alias!=alias_vars.end() && !hasAlias;++it_alias) {
                        if((*it)==(*it_alias)->getModelVariable()) {
                            hasAlias=true;
                        }
                    }
                    bool isTimed=false;
                    for(std::vector< Ref<TimedVariable> >::iterator tit=timedVars.begin();tit!=timedVars.end() && !isTimed;++tit) {
                        if(*it==(*tit)->getBaseVariable()) {
                            isTimed=true;
                        }
                    }
                    if(!isTimed && !hasAlias) {
                        int id_block = equations_->getBlockIDWithSolutionOf(*it);
                        if(id_block>=0) {
                            listToEliminate.push_back(std::pair<int, const Variable*>(id_block,(*it).getNode()));
                        }
                    }
                }
                else {
                    std::cout<<"Variable <<< "<<(*it)->getName()<<" >>> is not Eliminable.\n";
                }
            }
        }
        else {
            std::cout<<"Only Models with BLT can eliminate variables.\n";
        }
    }


    void OptimizationProblem::markVariablesForElimination(Ref<Variable> var) {
        if(hasBLT()) {
            if(var->isEliminable()) {
                //This should be an attribute of the class perhaps
                std::vector< Ref<Variable> > alias_vars = getAliases();
                std::vector< Ref<TimedVariable> > timedVars = getTimedVariables();
                bool hasAlias=false;
                for(std::vector< Ref<Variable> >::iterator it_alias = alias_vars.begin();
                it_alias!=alias_vars.end() && !hasAlias;++it_alias) {
                    if(var==(*it_alias)->getModelVariable()) {
                        hasAlias=true;
                    }
                }
                bool isTimed=false;
                for(std::vector< Ref<TimedVariable> >::iterator tit=timedVars.begin();tit!=timedVars.end() && !isTimed;++tit) {
                    if(var==(*tit)->getBaseVariable()) {
                        isTimed=true;
                    }
                }
                if(!isTimed && !hasAlias) {
                    int id_block = equations_->getBlockIDWithSolutionOf(var);
                    if(id_block>=0) {
                        listToEliminate.push_back(std::pair<int, const Variable*>(id_block,var.getNode()));
                    }
                }
            }
            else {
                std::cout<<"Variable <<< "<<var->getName()<<" >>> is not Eliminable.\n";
            }
        }
        else {
            std::cout<<"Only Models with BLT can eliminate variables.\n";
        }
    }


    void OptimizationProblem::eliminateVariables() {
        if(!hasBLT()) {
            throw std::runtime_error("Only Models with BLT can eliminate variables. Please enable the equation_sorting compiler option.\n");        
        }
        static unsigned int call_count = 0;
        if(call_count<1){
            //Sort the list first
            listToEliminate.sort(compareFunction2);
        
            equations_->getSubstitues(listToEliminate,eliminatedVariableToSolution);
            equations_->eliminateVariables(eliminatedVariableToSolution);
        
            //Mark variables as Eliminated
            std::vector< Variable* >::iterator fit;
            for(std::list< std::pair<int, const Variable*> >::iterator it_var=listToEliminate.begin();
            it_var!=listToEliminate.end();++it_var) {
                //it_var->second->setAsEliminated();
                //Removes variables from variables vector. Makes sure duplicates in the list are not twice eliminated
                if(!it_var->second->wasEliminated()){
                    eliminated_z.push_back(const_cast<Variable*>(it_var->second));
                    fit = std::find(z.begin(), z.end(),it_var->second);
                    (*fit)->setAsEliminated();
                    z.erase(fit);
                }
            }
        
            std::vector<casadi::MX> eliminatedMXs;
            std::vector<casadi::MX> subtitutes;
            for(std::map<const Variable*,casadi::MX>::const_iterator it=eliminatedVariableToSolution.begin();
            it!=eliminatedVariableToSolution.end();++it) {
                if(!it->second.isEmpty()) {
                    eliminatedMXs.push_back(it->first->getVar());
                    subtitutes.push_back(it->second);
                }
            }
            std::vector<casadi::MX> expressions;
            expressions.push_back(startTime);
            expressions.push_back(finalTime);
            expressions.push_back(objectiveIntegrand);
            expressions.push_back(objective);
        
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    expressions.push_back((*path_it)->getLhs());
                    expressions.push_back((*path_it)->getRhs());
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::const_iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    expressions.push_back((*point_it)->getLhs());
                    expressions.push_back((*point_it)->getRhs());
                }
            }
        
            std::vector<casadi::MX> subtitutedExpressions = casadi::substitute(expressions,eliminatedMXs,subtitutes);
        
            int counter=0;
            startTime = subtitutedExpressions[counter++];
            finalTime = subtitutedExpressions[counter++];
            objectiveIntegrand = subtitutedExpressions[counter++];
            objective = subtitutedExpressions[counter++];
        
            if(pathConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator path_it = pathConstraints.begin();
                path_it!=pathConstraints.end();++path_it) {
                    (*path_it)->setLhs(subtitutedExpressions[counter++]);
                    (*path_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
            if(pointConstraints.size()>0) {
                for(std::vector< Ref<Constraint> >::iterator point_it = pointConstraints.begin();
                point_it!=pointConstraints.end();++point_it) {
                    (*point_it)->setLhs(subtitutedExpressions[counter++]);
                    (*point_it)->setRhs(subtitutedExpressions[counter++]);
                }
            }
        }
        else{
            std::cout<<"WARNING: Variables have been already eliminated once. Further eliminations are ignored.\n";
        }
        call_count++;
    }

}; // End namespace
