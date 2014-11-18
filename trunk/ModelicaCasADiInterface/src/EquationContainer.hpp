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

#ifndef _MODELICACASADI_EQUATIONCONTAINER
#define _MODELICACASADI_EQUATIONCONTAINER

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
class EquationContainer: public RefCountedNode {
    public:
        virtual bool hasBLT() const {return 0;};
        virtual std::set<const Variable*> eliminateableVariables() const{            
            return std::set<const Variable*>();
        };
        virtual const casadi::MX getDaeResidual() const {
            std::cout<<"Abstract Container getDaeResidual() must not be called.\n";            
            return casadi::MX();
        }; 
        virtual std::vector< Ref<Equation> > getDaeEquations() const {
            std::cout<<"Abstract Container getDaeEquations() must not be called.\n";            
            return std::vector< Ref<Equation> >();
        };
        /** @param A pointer to an equation */ 
        virtual void addDaeEquation(Ref<Equation> eq) {
            std::cout<<"Abstract Container addDaeEquation(equation) must not be called.\n";            
        };
        
        virtual void substituteAllEliminateables(){
            std::cout<<"Abstract Container substituteAllEliminateables() must not be called.\n";
        };
        virtual void eliminateVariable(Ref<Variable> var){
            std::cout<<"Abstract Container eliminateVariable(variable) must not be called.\n";
        };
        virtual void eliminateVariables(std::vector< Ref<Variable> >& vars){
            std::cout<<"Abstract Container eliminatableVariables(std::vector<variable> vars) must not be called.\n";
        };
        
        virtual void addBlock(Ref<Block> block){
            std::cout<<"Abstract Container addBlock(block) must not be called.\n";
        };
        
        virtual bool isBLTEliminateable(Ref<Variable> var) const{
            return 0;
        }
        
        virtual void transferBLT(const std::vector< Ref<Block> >& nblt){
             std::cout<<"Abstract Container transferBLT(block) must not be called.\n";       
        }
        
        virtual void getSubstitues(const std::set<const Variable*>& eliminateables, std::map<const Variable*,casadi::MX>& storageMap) const{
            std::cout<<"Abstract Container getSubstitues(variables, storageMap) must not be called.\n";  
        }
        
        virtual void printBLT(std::ostream& out, bool with_details=false) const{}
        
        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
        
};

}; // End namespace
#endif
