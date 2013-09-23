#ifndef _MODELICACASADI_MODEL_FUNCTION
#define _MODELICACASADI_MODEL_FUNCTION
#include <symbolic/casadi.hpp>
#include <map>
#include <Printable.hpp>
namespace ModelicaCasADi 
{
class ModelFunction : public Printable {
    public:
        /** 
         * Create a ModelFunction, which is basically a wrapper around an MXFunction
         * that may be called and printed. 
         * @param An MXFunction 
         */
        ModelFunction(CasADi::MXFunction myFunction); 
        /**
         * Call the MXFunction kept in this class with a vector of MX as arguments.
         * Returns a vector of MX representing the outputs of the function call, if successful.
         * @param A vector of MX
         * @return A vector of MX
         */
        std::vector<CasADi::MX> call(std::vector<CasADi::MX> arg);
        /** Returns the name of the MXFunction */
        std::string getName() const;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
    private:
        CasADi::MXFunction myFunction;
};
inline ModelFunction::ModelFunction(CasADi::MXFunction myFunction) : myFunction(myFunction) {}
}; // End namespace
#endif


