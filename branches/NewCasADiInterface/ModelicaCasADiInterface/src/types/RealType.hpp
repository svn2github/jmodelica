#ifndef _MODELICACASADI_REAL_TYPE
#define _MODELICACASADI_REAL_TYPE

#include <types/PrimitiveType.hpp>
namespace ModelicaCasADi 
{
class RealType : public PrimitiveType { 
    public:
        /** A RealType has fixed default attributes */
        RealType(); 
        
        /** @return "Real" */
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
inline const std::string RealType::getName() const { return "Real"; }
inline bool RealType::hasAttribute(const AttributeKey key) const { return attributes.find(AttributeKeyInternal(key))!=attributes.end(); }
}; // End namespace
#endif
