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

#ifndef _MODELICACASADI_FLAT_EQUATION_LIST
#define _MODELICACASADI_FLAT_EQUATION_LIST

#include <iostream>
#include "casadi/casadi.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include "Ref.hpp"
#include "EquationContainer.hpp"
#include <vector>
#include <map>
#include <string>

namespace ModelicaCasADi 
{
class FlatEquationList : public EquationContainer {
    public:
        /**
        * Give the DAE residual of all equations.
        * @return An MX
        */
        const casadi::MX getDaeResidual() const;
        /**
        * Give the list of equations.
        * @return A std::vector of Equation
        */
        std::vector< Ref< Equation> > getDaeEquations() const;
        /** @param A pointer to an equation */ 
        virtual void addDaeEquation(Ref<Equation> eq);
        /**
        * Substitute all variables that have a solution from BLT. 
        * Variables are not eliminated after substitution, it just inline the symbolic solutions.
        */
        void substituteAllEliminables(){
            std::cout<<"A FlatListEquation container cannot substitute variables. Use BLTContainer instead.\n";
        };
        /**
        * Substitute Variable for it's corresponding solution from BLT, and remove the equation from the BLT.
        * @param A pointer to a Variable
        */
        void eliminateVariables(Ref<Variable> var){
            std::cout<<"A FlatListEquation container cannot eliminate variables. Use BLTContainer instead.\n";
        };
        /**
        * Substitute Variable for it's corresponding solution from BLT, and remove the equation from the BLT.
        * @param A pointer to a Variable
        */
        void eliminateVariables(std::vector< Ref<Variable> >& vars){
            std::cout<<"A FlatListEquation container cannot eliminate variables. Use BLTContainer instead.\n";
        };
	/**
        * Add a block to BLT
        * @param A pointer to a Block.
        */
        void addBlock(Ref<Block> block){
            std::cout<<"A FlatListEquation container cannot add blocks. Use BLTContainer instead.\n";
        };
        /**
        * Fills a map with variable -> solution from BLT information
        * @param A std::set of Variable
        * @param A reference to a std::map<Variable,MX>
        */
        void getSubstitues(const std::set<const Variable*>& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const{
            std::cout<<"A FlatListEquation container cannot get subtitutes. Use BLTContainer instead.\n";  
        }
        
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        std::vector< Ref<Equation> > daeEquations;
        
};

inline void FlatEquationList::addDaeEquation(Ref<Equation>eq) { daeEquations.push_back(eq); }
inline std::vector< Ref< Equation> > FlatEquationList::getDaeEquations() const { return daeEquations; }

}; // End namespace
#endif