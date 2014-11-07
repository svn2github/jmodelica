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

#ifndef _MODELICACASADI_BLTHANDLER
#define _MODELICACASADI_BLTHANDLER

#include <iostream>
#include "casadi/casadi.hpp"
#include "Equation.hpp"
#include "RefCountedNode.hpp"
#include "Ref.hpp"
#include <vector>
#include <map>
#include <string>
#include "Block.hpp"

namespace ModelicaCasADi
{
class BLTHandler : public RefCountedNode{
    public:
    BLTHandler(){}
    ~BLTHandler(){}
    
#ifndef SWIG
    template<typename JBLT, typename JBlock, typename JCollection, typename JIterator,
            typename FVar, typename FAbstractEquation, typename FEquation,
            typename FExp, template<typename Ty> class ArrayJ >
    void setBLT(JBLT javablt, bool jacobian_no_casadi = true, bool solve_with_casadi = true){
        for(int i=0;i<javablt.size();++i)
        {
           //Block
           JBlock* block = new JBlock(javablt.get(i).this$);
           blt.push_back(new ModelicaCasADi::Block());
           blt[i]->setBlock<JBlock,
                            JCollection,
                            JIterator,
                            FVar, 
                            FAbstractEquation, 
                            FEquation,
                            FExp,
                            ArrayJ>(block,jacobian_no_casadi,solve_with_casadi);
           delete block;
        }
    }
#endif
    
    void printBLT(std::ostream& out, bool with_details=false) const;
    int getNumberOfBlocks() const;
    std::vector<casadi::MX> getAllEliminatableVariables() const;
    std::vector< Ref<Equation> > getAllEquations4Model() const;
    std::vector<casadi::MX> getSubstitues(const std::vector<casadi::MX>& eliminateables) const;
    void substituteAllEliminateables();
    
    Ref<Block> getBlock(int i) const;
    MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
    std::vector< Ref<Block> > blt;
};

inline int BLTHandler::getNumberOfBlocks() const {return blt.size();}
inline Ref<Block> BLTHandler::getBlock(int i) const {return blt[i];}
}; // End namespace
#endif