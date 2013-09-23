#include <OptimizationProblem.hpp>
using std::ostream; using CasADi::MX;

namespace ModelicaCasADi{

OptimizationProblem::OptimizationProblem(Model* model, 
                                        std::vector<Constraint> pathConstraints,
                                        MX startTime, MX finalTime,
                                        MX lagrangeTerm  /*= MX(0)*/,
                                        MX mayerTerm  /*= MX(0)*/) : model(model)  {
    this->pathConstraints = pathConstraints;
    this->startTime = startTime;
    this->finalTime = finalTime;
    this->lagrangeTerm = lagrangeTerm;
    this->mayerTerm = mayerTerm;
} 
void OptimizationProblem::print(ostream& os) const { 
    using namespace std;
    os << "Model contained in OptimizationProblem:\n" << endl;
    os << *model;
    os << "-- Optimization information  --\n" << endl;
    os << "Start time = " << startTime << "\nEnd time = " << finalTime << endl;
    for (vector<Constraint>::const_iterator it = pathConstraints.begin(); it != pathConstraints.end(); ++it) {
        if (it == pathConstraints.begin()) {
            os << "-- Constraints --" << endl;
        }
        os << *it << endl;
    }
    os << "-- Lagrange term --\n" << lagrangeTerm << endl;
    os << "-- Mayer term --\n" << mayerTerm << endl;
}

}; // End namespace
