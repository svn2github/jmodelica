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
        AttributeValue* getAttribute(const AttributeKey key);
        /**
         * @param An AttributeKey
         * @return A bool
         */
        bool hasAttribute(const AttributeKey key) const;
};
inline const std::string BooleanType::getName() const { return "Boolean"; }
inline bool BooleanType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
#endif
