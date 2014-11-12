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
#include <string>
#include <vector>

#include "casadi/casadi.hpp"

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
    virtual void addDaeEquation(Ref<Equation> eq);

    virtual const casadi::MX getDaeResidual() const; 

    virtual std::vector< Ref<Equation> > getDaeEquations() const;
    
    
    /** Notify the Model if it has a BLT for DAE equations **/
    virtual bool hasBLT(){return 1;}
    
    /** @param A CasadiInterface variable pointer */ 
    bool isBLTEliminateable(Ref<Variable> var) const;
    virtual std::set<const Variable*> getBLTEliminateables() const;
    
    virtual void eliminateAlgebraics();
    virtual void eliminateVariable(Ref<Variable> var);
    virtual void eliminateVariables(std::vector< Ref<Variable> >& vars);
    virtual void substituteAllEliminateableVariables(){blt->substituteAllEliminateables();}
    
    void setBLT(Ref<BLTHandler> nblt);
    
    void printBLT(std::ostream& out, bool with_details=false);
    
    int getNumBLTBlocks(){return blt->getNumberOfBlocks();}

    /** Allows the use of operator << to print this class, through Printable. */
    virtual void print(std::ostream& os) const;
    MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
    /// Vector containing pointers to DAE equations added beside blt ones
    std::vector< Ref<Equation> > addedDAEEquations;
    Ref<BLTHandler> blt; 
};

inline void BLTModel::printBLT(std::ostream& out, bool with_details/*=false*/){blt->printBLT(out,with_details);}

inline void BLTModel::addDaeEquation(Ref<Equation>eq) { addedDAEEquations.push_back(eq); }

inline std::vector< Ref< Equation> > BLTModel::getDaeEquations() const {
    std::vector< Ref<Equation> > DAEfromBLT =blt->writeEquationsforModel();
    DAEfromBLT.reserve( DAEfromBLT.size() + addedDAEEquations.size() ); 
    DAEfromBLT.insert( DAEfromBLT.end(), addedDAEEquations.begin(), addedDAEEquations.end() );
    return DAEfromBLT; 
}

inline std::set<const Variable*> BLTModel::getBLTEliminateables() const{
    return blt->eliminatableVariables();
}

}; // End namespace
#endif