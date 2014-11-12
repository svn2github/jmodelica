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

void BLTModel::setBLT(Ref<BLTHandler> nblt){
    blt=nblt;
    std::cout<<"\nEliminateables: ";
    for(std::vector<Variable*>::iterator it=z.begin();it!=z.end();++it){
        if(isBLTEliminateable((*it))){
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

void BLTModel::eliminateVariable(Ref<Variable> var){
    if(var->isEliminatable())
    {
        std::set<const Variable*> eliminateVar; 
        eliminateVar.insert(var.getNode());
        std::map<const Variable*,casadi::MX> storageMap;
        blt->getSubstitues(eliminateVar,storageMap);
        blt->substitute(storageMap);
        blt->removeSolutionOfVariable(var.getNode());
    }
}

void BLTModel::eliminateVariables(std::vector< Ref<Variable> >& vars){
    std::set<const Variable*> toEliminate;
    for(std::vector< Ref<Variable> >::iterator it=vars.begin();it!=vars.end();++it){
        if((*it)->isEliminatable()){
            toEliminate.insert((*it).getNode());
        }
    }
    
    std::map<const Variable*,casadi::MX> storageMap;
    blt->getSubstitues(toEliminate,storageMap);
    blt->substitute(storageMap);
    
    for(std::set<const Variable*>::iterator it=toEliminate.begin();it!=toEliminate.end();++it){
        if((*it)->isEliminatable()){
            blt->removeSolutionOfVariable((*it));
        }
    }
    
}


bool BLTModel::isBLTEliminateable(Ref<Variable> var) const{
    std::set<const Variable*> eliminateables = blt->eliminatableVariables();
    std::set<const Variable*>::const_iterator it = eliminateables.find(var.getNode());
    if(it!=eliminateables.end()){
        return 1;    
    }
    return 0;    
}

const MX BLTModel::getDaeResidual() const {
    MX daeRes;
    std::vector< Ref<Equation> > DAEfromBLT =blt->writeEquationsforModel();
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