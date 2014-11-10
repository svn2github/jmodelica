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

#include "BLTModel.hpp"

using casadi::MX; using casadi::MXFunction; 
using std::vector; using std::ostream;
using std::string; using std::pair;

namespace ModelicaCasADi{
    
void BLTModel::setEliminateableVariables(){
    std::cout<<"\nEliminateables: ";
    for(std::vector<Variable*>::iterator it=z.begin();it!=z.end();++it){
        if(isBLTEliminateable((*it)->getVar())){
            (*it)->setAsEliminatable();
            std::cout<<(*it)->getName()<<" ";
        }
    }
    std::cout<<"\n";
}
    
void BLTModel::eliminateAlgebraics(){
    std::vector< Ref<Variable> > algebraics = getVariables(REAL_ALGEBRAIC);
    eliminateVariables(algebraics);
}
    
void BLTModel::eliminateVariable(const std::string& varName){
    Ref<Variable> var = getVariable(varName);
    if(var->isEliminatable())
    {
        std::vector<casadi::MX> toEliminate(1,var->getVar());
        std::vector<casadi::MX> toSubstitute = blt->getSubstitues(toEliminate);
        blt->substitute(toEliminate, toSubstitute);
        blt->removeSolutionOfVariable(var->getName());
    }
}



void BLTModel::eliminateVariables(std::vector<std::string>& varNames){
    Ref<Variable> var;
    std::vector<casadi::MX> toEliminate;
    for(std::vector<std::string>::const_iterator it=varNames.begin();it!=varNames.end();++it){
        var = getVariable(*it);
        if(var->isEliminatable()){
            toEliminate.push_back(var->getVar());
        }
    }
    std::vector<casadi::MX> toSubstitute = blt->getSubstitues(toEliminate);
    blt->substitute(toEliminate, toSubstitute);
    
    for(std::vector<std::string>::iterator it=varNames.begin();it!=varNames.end();++it){
        var = getVariable(*it);
        if(var->isEliminatable()){
            blt->removeSolutionOfVariable(var->getName());
        }
    }
    
}

void BLTModel::eliminateVariable(Ref<Variable> var){
    if(var->isEliminatable())
    {
        std::vector<casadi::MX> toEliminate(1,var->getVar());
        std::vector<casadi::MX> toSubstitute = blt->getSubstitues(toEliminate);
        blt->substitute(toEliminate, toSubstitute);
        blt->removeSolutionOfVariable(var->getName());
    }
}

void BLTModel::eliminateVariables(std::vector< Ref<Variable> >& vars){
    std::vector<casadi::MX> toEliminate;
    for(std::vector< Ref<Variable> >::const_iterator it=vars.begin();it!=vars.end();++it){
        if((*it)->isEliminatable()){
            toEliminate.push_back((*it)->getVar());
        }
    }
    
    std::vector<casadi::MX> toSubstitute = blt->getSubstitues(toEliminate);
    blt->substitute(toEliminate, toSubstitute);
    
    for(std::vector< Ref<Variable> >::iterator it=vars.begin();it!=vars.end();++it){
        if((*it)->isEliminatable()){
            blt->removeSolutionOfVariable((*it)->getName());
        }
    }
    
}

bool BLTModel::isBLTEliminateable(casadi::MX var, int depth/*=0*/) const{
    std::vector<casadi::MX> eliminateables = blt->getAllEliminatableVariables();
    for(std::vector<casadi::MX>::const_iterator it=eliminateables.begin(); 
        it!=eliminateables.end();++it){
        if(it->isEqual(var,depth)){
            return 1;        
        }
    }
    return 0;
}

bool BLTModel::isBLTEliminateable(const std::string& varName) const{
    std::vector<casadi::MX> eliminateables = blt->getAllEliminatableVariables();
    for(std::vector<casadi::MX>::const_iterator it=eliminateables.begin(); 
        it!=eliminateables.end();++it){
        if(it->getName()==varName){
            return 1;        
        }
    }
    return 0;
}

const MX BLTModel::getDaeResidual() const {
    MX daeRes;
    std::vector< Ref<Equation> > DAEfromBLT =blt->getAllEquations4Model();
    for (vector< Ref<Equation> >::const_iterator it = DAEfromBLT.begin(); it != DAEfromBLT.end(); ++it) {
        daeRes.append((*it)->getResidual());
    }
    for (vector< Ref<Equation> >::const_iterator it = addedDAEEquations.begin(); it != addedDAEEquations.end(); ++it) {
        daeRes.append((*it)->getResidual());
    }
    return daeRes;
}

template <class T> 
void printVectorBLT(std::ostream& os, const std::vector<T> &makeStringOf) {
    typename std::vector<T>::const_iterator it;
    for ( it = makeStringOf.begin(); it < makeStringOf.end(); ++it) {
         os << **it << "\n";
    }
}

void BLTModel::print(std::ostream& os) const {
//    os << "Model<" << this << ">"; return;

    using std::endl;
    os << "------------------------------- Variables -------------------------------\n" << endl;
    if (!timeVar.isEmpty()) {
        os << "Time variable: ";
        timeVar.print(os);
        os << endl;
    }
    printVectorBLT(os, z);
    os << "\n---------------------------- Variable types  ----------------------------\n" << endl;
    for (BLTModel::typeMap::const_iterator it = typesInModel.begin(); it != typesInModel.end(); ++it) {
            os << it->second << endl;
    }
    os << "\n------------------------------- Functions -------------------------------\n" << endl;
    for (BLTModel::functionMap::const_iterator it = modelFunctionMap.begin(); it != modelFunctionMap.end(); ++it){
            os << it->second << endl;
    }
    os << "\n------------------------------- Equations -------------------------------\n" << endl;
    if (!initialEquations.empty()) {
        os << " -- Initial equations -- \n";
        printVectorBLT(os, initialEquations);
    }
    if (!getDaeEquations().empty()) {
        os << " -- DAE equations -- \n";
        printVectorBLT(os, getDaeEquations());
    }
    os << endl;
}
}; // End namespace