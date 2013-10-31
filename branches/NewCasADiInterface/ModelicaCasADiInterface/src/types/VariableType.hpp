#ifndef _MODELICACASADI_VARIABLE_TYPE
#define _MODELICACASADI_VARIABLE_TYPE
#include <symbolic/casadi.hpp>
#include <boost/flyweight.hpp>
#include <iostream>
#include <map>
#include <string>
#include <Printable.hpp>

namespace ModelicaCasADi 
{
/** 
 * Abstract class for types, which models the default attributes of
 * Modelica and Optimica variables, or user defined types. 
 * 
 */
class VariableType : public Printable {
    public:
        typedef std::string AttributeKey; 
        typedef CasADi::MX AttributeValue;
    protected:
        typedef boost::flyweights::flyweight<std::string> AttributeKeyInternal; 
        typedef std::map<AttributeKeyInternal,AttributeValue> attributeMap;  
        attributeMap attributes;
    public: 
        /**
         * @param An AttributeKey
         * @return An AttributeValue, returns NULL if not present. 
         */ 
        virtual AttributeValue* getAttribute(const AttributeKey key) = 0; 
        /** @return A string */
        virtual const std::string getName() const = 0; 
        /** @return A bool */
        virtual bool hasAttribute(const AttributeKey key) const = 0;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
};
}; // End namespace
#endif
