#ifndef _MODELICACASADI_OPTIMIZATIONPROBLEM
#define _MODELICACASADI_OPTIMIZATIONPROBLEM
#include <Model.hpp>
#include <Constraint.hpp>
#include <vector>
#include <iostream>
#include <Printable.hpp>
namespace ModelicaCasADi 
{
class OptimizationProblem : public Printable {
    public:
        /**
         * Create an OptimizationProblem from the constraints and objective
         * passed in as arguments.
         * @param A pointer to a Model
         * @param An std::vector with Constraint
         * @param An MX for start time
         * @param An MX final time
         * @param An MX for Lagrange term, default MX(0)
         * @param An MX for Mayer term, default MX(0)
         */ 
        OptimizationProblem(Model* model, 
                           std::vector<Constraint> pathConstraints,
                           CasADi::MX startTime, CasADi::MX finalTime,
                           CasADi::MX lagrangeTerm = CasADi::MX(0),
                           CasADi::MX mayerTerm = CasADi::MX(0)) ;
        /**
         * Returns a pointer to the Model that acts as a constraint for this
         * optimization problem
         * @return A pointer to a Model.
         */ 
        Model* getModel() const;
        /** @return An MX */
        CasADi::MX getStartTime() const;
        /** @return An MX */
        CasADi::MX getFinalTime() const;
        /**
         * Returns a vector with the Path constraints
         * @return A std::vector of Constraint
         */ 
        std::vector<Constraint>  getPathConstraints() const;
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
        void setPathConstraint(std::vector<Constraint> pathConstraints);
        /** @param An MX */
        void setLagrangeTerm(CasADi::MX lagrangeTerm);
        /** @param An MX */
        void setMayerTerm(CasADi::MX mayerTerm);
        
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
    private:
        Model* model; /// Aggregation
        CasADi::MX startTime; /// Start time can be an expression
        CasADi::MX finalTime; /// Final time can be an expression
        CasADi::MX lagrangeTerm;
        CasADi::MX mayerTerm;
        std::vector<Constraint> pathConstraints;
};
inline Model* OptimizationProblem::getModel() const { return model; } 
inline CasADi::MX OptimizationProblem::getStartTime() const { return startTime; }
inline CasADi::MX OptimizationProblem::getFinalTime() const { return finalTime; }
inline CasADi::MX OptimizationProblem::getLagrangeTerm() const { return lagrangeTerm; }
inline CasADi::MX OptimizationProblem::getMayerTerm() const { return mayerTerm; }
inline std::vector<Constraint> OptimizationProblem::getPathConstraints() const { return pathConstraints; }

inline void OptimizationProblem::setStartTime(CasADi::MX startTime) { this->startTime = startTime; }
inline void OptimizationProblem::setFinalTime(CasADi::MX finalTime) { this->finalTime = finalTime; }
inline void OptimizationProblem::setPathConstraint(std::vector<Constraint> pathConstraints) { this->pathConstraints = pathConstraints; }
inline void OptimizationProblem::setLagrangeTerm(CasADi::MX lagrangeTerm) { this->lagrangeTerm = lagrangeTerm; } 
inline void OptimizationProblem::setMayerTerm(CasADi::MX mayerTerm) { this->mayerTerm = mayerTerm; } 
}; // End namespace
#endif
