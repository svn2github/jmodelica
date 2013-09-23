#ifndef _MODELICACASADI_BOOLEAN_TYPE
#define _MODELICACASADI_BOOLEAN_TYPE

#include <types/PrimitiveType.hpp>
namespace ModelicaCasADi 
{
class BooleanType : public PrimitiveType { 
    public:
        /** A BooleanType has fixed default attributes */
        BooleanType(); 
        
        /** @return "Boolean" */
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
inline const std::string BooleanType::getName() const { return "Boolean"; }
inline bool BooleanType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
#endif
