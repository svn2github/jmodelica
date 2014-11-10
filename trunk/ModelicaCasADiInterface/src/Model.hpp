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
class Model: public BaseModel {
    public:
        /** Create a blank, uninitialized Model */
        Model() : BaseModel(){}
        
        /** @param A pointer to an equation */ 
        virtual void addDaeEquation(Ref<Equation> eq);
        
        virtual const casadi::MX getDaeResidual() const; 

        std::vector< Ref< Equation> > getDaeEquations() const;
        
        virtual bool hasBLT(){return 0;}
        
        virtual std::vector<casadi::MX> getBLTEliminateables() const {
                std::vector<casadi::MX> empty;
                return empty;
        };  
        
        /** Allows the use of operator << to print this class, through Printable. */
        virtual void print(std::ostream& os) const;
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        /// Vector containing pointers to DAE equations
        std::vector< Ref<Equation> > daeEquations; 
};

inline void Model::addDaeEquation(Ref<Equation>eq) { daeEquations.push_back(eq); }

inline std::vector< Ref< Equation> > Model::getDaeEquations() const { return daeEquations; }

}; // End namespace
#endif
