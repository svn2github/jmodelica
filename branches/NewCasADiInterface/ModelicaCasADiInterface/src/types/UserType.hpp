#ifndef _MODELICACASADI_USER_TYPE
#define _MODELICACASADI_USER_TYPE

#include <types/VariableType.hpp>
#include <types/PrimitiveType.hpp>
namespace ModelicaCasADi 
{
/**
 * A class that models user defined types. A user defined type has a name and
 * attributes. A user defined type also has a primitive type that defines whatever
 * default attributes that the user defined type does not define. 
 */
class UserType : public VariableType {
    public:
        /**
         * Create a user defined type from a name and a primitive VariableType.
         * @param A string
         * @param A pointer to a PrimitiveType
         */
        UserType(std::string name, PrimitiveType* baseType); 
        /** @return A string */
        const std::string getName() const;
        /**
         * @param An AttributeKey
         * @param An AttributeValue
         */
        void setAttribute(AttributeKey key, AttributeValue val); 
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
        const std::string name;
        const PrimitiveType* baseType;
};
inline const std::string UserType::getName() const { return name; }
inline void UserType::setAttribute(AttributeKey key, AttributeValue val) { attributes.insert(std::pair<AttributeKeyInternal, AttributeValue>(AttributeKeyInternal(key), val)); }
}; // End namespace
#endif
