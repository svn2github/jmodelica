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

#ifndef _MODELICACASADI_BLTMODEL 
#define _MODELICACASADI_BLTMODEL
#include <iostream>
#include <map>
#include <string>
#include <vector>

#include "casadi/casadi.hpp"

#include "ModelFunction.hpp"
#include "types/VariableType.hpp"
#include "Variable.hpp"
#include "RealVariable.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include "Ref.hpp"

#include "BaseModel.hpp"
#include "BLTHandler.hpp"

namespace ModelicaCasADi 
{  
class BLTModel: public BaseModel {
    public:
        /** Create a blank, uninitialized Model */
        BLTModel() : BaseModel(){blt=new BLTHandler();}

    ~BLTModel(){}
    /** @param A pointer to an equation */ 
    void addDaeEquation(Ref<Equation> eq);

    const casadi::MX getDaeResidual() const; 

    std::vector< Ref<Equation> > getDaeEquations() const;
    
    //To decide
    //Ref<BLTHandler>& getBLT();
    
    /** @param An MX from a CasadiInterface variable  */ 
    bool isBLTEliminateable(casadi::MX var, int depth=0) const;
    /** @param Name of an MX from a CasadiInterface variable  */
    bool isBLTEliminateable(const std::string& varName) const;
    
    /** Notify the Model if it has a BLT for DAE equations **/
    bool hasBLT(){return 1;}

    /** Allows the use of operator << to print this class, through Printable. */
    virtual void print(std::ostream& os) const;
    MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
    /// Vector containing pointers to DAE equations added beside blt ones
    std::vector< Ref<Equation> > addedDAEEquations;
    Ref<BLTHandler> blt; 
};

inline void BLTModel::addDaeEquation(Ref<Equation>eq) { addedDAEEquations.push_back(eq); }

inline std::vector< Ref< Equation> > BLTModel::getDaeEquations() const {
    std::vector< Ref<Equation> > DAEfromBLT =blt->getAllEquations4Model();
    DAEfromBLT.reserve( DAEfromBLT.size() + addedDAEEquations.size() ); 
    DAEfromBLT.insert( DAEfromBLT.end(), addedDAEEquations.begin(), addedDAEEquations.end() );
    return DAEfromBLT; 
}

//inline Ref<BLTHandler>& BLTModel::getBLT(){return blt;}

}; // End namespace
#endif