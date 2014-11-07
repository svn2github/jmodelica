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