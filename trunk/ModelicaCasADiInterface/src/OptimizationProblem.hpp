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

#ifndef _MODELICACASADI_OPTIMIZATIONPROBLEM
#define _MODELICACASADI_OPTIMIZATIONPROBLEM
#include <iostream>
#include <vector>

#include "symbolic/casadi.hpp"

#include "Model.hpp"
#include "Constraint.hpp"
#include "SharedNode.hpp"
#include "TimedVariable.hpp"
#include "Ref.hpp"
namespace ModelicaCasADi 
{
class OptimizationProblem : public Model {
    public:
        /**
         * Create an OptimizationProblem from the constraints and objective
         * passed in as arguments.
         * @param A string identifier, default is empty string. 
         */ 
        OptimizationProblem(std::string identifier = "");
        /** @return An MX */
        CasADi::MX getStartTime() const;
        /** @return An MX */
        CasADi::MX getFinalTime() const;
        /**
         * Returns a vector with the path constraints
         * @return A std::vector of Constraint
         */ 
        std::vector< Ref<Constraint> >  getPathConstraints() const;
        /**
         * Returns a vector with the point constraints
         * @return A std::vector of Constraint
         */ 
        std::vector< Ref<Constraint> >  getPointConstraints() const;
        /**
         * Returns a vector with the timed variables
         * @return A std::vector of TimedVariable
         */ 
        std::vector< Ref<TimedVariable> >  getTimedVariables() const;
        /** @return An MX  */
        CasADi::MX getLagrangeTerm() const;
        /** @return An MX  */
        CasADi::MX getMayerTerm() const;
        /** @param An MX  */
        void setStartTime(CasADi::MX startTime);
        /** @param An MX  */
        void setFinalTime(CasADi::MX finalTime);
        /**
         * Set path constraints
         * @param A vector with constraints
         */ 
        void setPathConstraints(const std::vector< Ref<Constraint> > &pathConstraints);
        /**
         * Set point constraints
         * @param A vector with constraints
         */ 
        void setPointConstraints(const std::vector< Ref<Constraint> > &pointConstraints);
        /** @param An MX */
        void setLagrangeTerm(CasADi::MX lagrangeTerm);
        /** @param An MX */
        void setMayerTerm(CasADi::MX mayerTerm);
        /** @param A std::vector of TimedVariable */
        void setTimedVariables(const std::vector< Ref<TimedVariable> > &timedVariables);
        
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;

        MODELICACASADI_SHAREDNODE_CHILD_PUBLIC_DEFS
    private:
        CasADi::MX startTime; /// Start time can be an expression
        CasADi::MX finalTime; /// Final time can be an expression
        CasADi::MX lagrangeTerm;
        CasADi::MX mayerTerm;
        std::vector< Ref<TimedVariable> > timedVariables;
        std::vector< Ref<Constraint> >  pathConstraints;
        std::vector< Ref<Constraint> >  pointConstraints;
};
inline CasADi::MX OptimizationProblem::getStartTime() const { return startTime; }
inline CasADi::MX OptimizationProblem::getFinalTime() const { return finalTime; }
inline CasADi::MX OptimizationProblem::getLagrangeTerm() const { return lagrangeTerm; }
inline CasADi::MX OptimizationProblem::getMayerTerm() const { return mayerTerm; }
inline std::vector< Ref<Constraint> >  OptimizationProblem::getPathConstraints() const { return pathConstraints; }
inline std::vector< Ref<Constraint> >  OptimizationProblem::getPointConstraints() const { return pointConstraints; }
inline std::vector< Ref<TimedVariable> >  OptimizationProblem::getTimedVariables() const { return timedVariables; }

inline void OptimizationProblem::setStartTime(CasADi::MX startTime) { this->startTime = startTime; }
inline void OptimizationProblem::setFinalTime(CasADi::MX finalTime) { this->finalTime = finalTime; }
inline void OptimizationProblem::setPathConstraints(const std::vector< Ref<Constraint> > &pathConstraints) { this->pathConstraints = pathConstraints; }
inline void OptimizationProblem::setPointConstraints(const std::vector< Ref<Constraint> > &pointConstraints) { this->pointConstraints = pointConstraints; }
inline void OptimizationProblem::setLagrangeTerm(CasADi::MX lagrangeTerm) { this->lagrangeTerm = lagrangeTerm; } 
inline void OptimizationProblem::setMayerTerm(CasADi::MX mayerTerm) { this->mayerTerm = mayerTerm; } 
inline void OptimizationProblem::setTimedVariables(const std::vector< Ref<TimedVariable> > &timedVariables) { this->timedVariables = timedVariables; }
}; // End namespace
#endif
