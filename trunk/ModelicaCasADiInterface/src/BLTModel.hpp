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

#ifndef _MODELICACASADI_MODEL 
#define _MODELICACASADI_MODEL
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

namespace ModelicaCasADi 
{  
class BLTModel: public BaseModel {
    public:
        /** Create a blank, uninitialized Model */
        BLTModel() : BaseModel(){}
        
        /** @param A pointer to an equation */ 
        void addDaeEquation(Ref<Equation> eq);
        
        const casadi::MX getDaeResidual() const; 

        std::vector< Ref< Equation> > getDaeEquations() const;
        
        /** Allows the use of operator << to print this class, through Printable. */
        virtual void print(std::ostream& os) const;
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        /// Vector containing pointers to DAE equations added beside blt ones
        std::vector< Ref<Equation> > addedDAEEquations;
};

inline void BLTModel::addDaeEquation(Ref<Equation>eq) { addedDAEEquations.push_back(eq); }

inline std::vector< Ref< Equation> > BLTModel::getDaeEquations() const { return addedDAEEquations; }

}; // End namespace
#endif