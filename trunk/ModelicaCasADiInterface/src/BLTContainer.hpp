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

#ifndef _MODELICACASADI_BLTCONTAINER
#define _MODELICACASADI_BLTCONTAINER

#include <iostream>
#include "casadi/casadi.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include "Block.hpp"
#include "Ref.hpp"
#include "EquationContainer.hpp"
#include <vector>
#include <map>
#include <string>

namespace ModelicaCasADi 
{
class BLTContainer: public EquationContainer {
    public:
        virtual bool hasBLT() const;
        virtual const casadi::MX getDaeResidual() const; 
        std::vector< Ref< Equation> > getDaeEquations() const;
        /** @param A pointer to an equation */ 
        virtual void addDaeEquation(Ref<Equation> eq);
        
        /**************BlockMethods*************/
        void addBlock(Ref<Block> block);
        int getNumberOfBlocks() const;
        Ref<Block> getBlock(int i) const;
        /***************************************/
        
        /**************AuxiliaryMethods*************/
        void printBLT(std::ostream& out, bool with_details=false) const;
        std::set<const Variable*> eliminateableVariables() const;
        void getSubstitues(const std::set<const Variable*>& eliminateables, std::map<const Variable*,casadi::MX>& storageMap) const;
        
        void substituteAllEliminateables();
        void removeSolutionOfVariable(const Variable* var);
        void substitute(const std::map<const Variable*,casadi::MX>& substituteMap);
        
        void transferBLT(const std::vector< Ref<Block> >& nblt);
        /** @param A CasadiInterface variable pointer */ 
        bool isBLTEliminateable(Ref<Variable> var) const;
        void eliminateVariable(Ref<Variable> var);
        void eliminateVariables(std::vector< Ref<Variable> >& vars);
        /*******************************************/
        
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
        private:       
        std::vector< Ref<Block> > blt;
        
        
};
inline bool BLTContainer::hasBLT() const {return 1;}
inline void BLTContainer::transferBLT(const std::vector< Ref<Block> >& nblt) {blt=nblt;}
inline void BLTContainer::addDaeEquation(Ref<Equation>eq) { 
   Ref<Block> nBlock = new Block();
   nBlock->addEquation(eq,false);
   addBlock(nBlock);
}
inline int BLTContainer::getNumberOfBlocks() const {return blt.size();}
inline void BLTContainer::addBlock(Ref<Block> block){blt.push_back(block);}
inline Ref<Block> BLTContainer::getBlock(int i) const {return blt[i];}
}; // End namespace
#endif