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

#ifndef _MODELICACASADI_EQUATIONS
#define _MODELICACASADI_EQUATIONS

#include <iostream>
#include "casadi/casadi.hpp"
#include "RefCountedNode.hpp"
#include "Ref.hpp"
#include "Equation.hpp"
#include "Variable.hpp"
#include "Block.hpp"
#include <vector>
#include <map>
#include <string>

namespace ModelicaCasADi 
{
class Equations: public RefCountedNode {
    public:
        /**
        * Check if equations object has a BLT
        * @return A boolean
        */
        virtual bool hasBLT() const {return 0;};
        /**
        * Give the list of variables that are eliminable according to BLT information.
        * If Equations object does not have a BLT, returns an empty set
        * @return A std::set of Variable
        */
        virtual std::set<const Variable*> eliminableVariables() const{            
            return std::set<const Variable*>();
        };
        /**
        * Give the DAE residual of all equations.
        * @return An MX
        */
        virtual const casadi::MX getDaeResidual() const {
            std::cout<<"Abstract Equations getDaeResidual() must not be called.\n";            
            return casadi::MX();
        }; 
        /**
        * Give the list of equations.
        * @return A std::vector of Equation
        */
        virtual std::vector< Ref<Equation> > getDaeEquations() const {
            std::cout<<"Abstract Equations getDaeEquations() must not be called.\n";            
            return std::vector< Ref<Equation> >();
        };
        /** @param A pointer to an equation */ 
        virtual void addDaeEquation(Ref<Equation> eq) {
            std::cout<<"Abstract Equations addDaeEquation(equation) must not be called.\n";            
        };
        
        /**
        * Substitute all variables that have a solution from BLT. 
        * Variables are not eliminated after substitution, it just inline the symbolic solutions.
        */
        virtual void substituteAllEliminables(){
            std::cout<<"Abstract Equations substituteAllEliminables() must not be called.\n";
        };
        /**
        * Add a block to BLT
        * @param A pointer to a Block.
        */
        virtual void addBlock(Ref<Block> block){
            std::cout<<"Abstract Equations addBlock(block) must not be called.\n";
        };
        
        /**
        * Check if BLT has solution for a variable.
        * @return A boolean
        * @param A pointer to a Variable
        */
        virtual bool isBLTEliminable(Ref<Variable> var) const{
            return 0;
        }
        
        /**
        * Fills a map with variable -> solution from BLT information
        * @param A std::set of Variable
        * @param A reference to a std::map<Variable,MX>
        */
        virtual void getSubstitues(const std::set<const Variable*>& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const{
            std::cout<<"Abstract Container getSubstitues(variables, storageMap) must not be called.\n";  
        }
        virtual void getSubstitues(const Variable* eliminable, std::map<const Variable*,casadi::MX>& storageMap) const{
            std::cout<<"Abstract Container getSubstitues(variables, storageMap) must not be called.\n";  
        }
        //This one consider order
        virtual void getSubstitues(const std::list< std::pair<int, Variable*> >& eliminables, std::map<const Variable*,casadi::MX>& storageMap) const{
            std::cout<<"Abstract Container getSubstitues(variable_list, storageMap) must not be called.\n";  
        }
        /**
        * Print the BLT
        * @param A std::ostream
        * @param A Boolean 
        */
        virtual void printBLT(std::ostream& out, bool with_details=false) const{}
        
        //Experimental
        virtual void propagateExternals(){
            std::cout<<"Abstract Container propagateExternals() must not be called.\n";  
        }
        
        //Return -1 if the variable does not have a solution
        virtual int getBlockIDWithSolutionOf(Ref<Variable> var){
            std::cout<<"Abstract Container getBlockIDWithSolutionOf(Ref<Variable> var) must not be called.\n"; 
        }
        /**
        * Substitute Variable for it's corresponding solution from BLT, and remove the equation from the BLT.
        * @param A map from variable to solution
        */
        virtual void eliminateVariables(const std::map<const Variable*,casadi::MX>& substituteMap){
            std::cout<<"Abstract Container eliminateVariables(substituteMap) must not be called.\n"; 
        }
        

    MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS

};

}; // End namespace
#endif
