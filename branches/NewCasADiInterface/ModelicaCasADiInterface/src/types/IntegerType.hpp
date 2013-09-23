#ifndef _MODELICACASADI_INTEGER_TYPE
#define _MODELICACASADI_INTEGER_TYPE

#include <types/PrimitiveType.hpp>
namespace ModelicaCasADi 
{
class IntegerType : public PrimitiveType { 
    public:
        /** An IntegerType has fixed default attributes */
        IntegerType(); 
        
        /** @return "Integer" */
        const std::string getName() const;
        /** 
         * @param An AttributeKey
         * @return An AttributeValue, returns NULL if not present. 
         */
        const AttributeValue* getAttribute(const AttributeKey key) const;
        /**
         * @param An AttributeKey
         * @return A bool
         */
        bool hasAttribute(const AttributeKey key) const;
        /** Allows the use of the operator << to print this class to a stream, through Printable */
        virtual void print(std::ostream& os) const;
    private:
        attributeMap attributes;
};
inline const std::string IntegerType::getName() const { return "Integer"; }
inline bool IntegerType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
#endif
