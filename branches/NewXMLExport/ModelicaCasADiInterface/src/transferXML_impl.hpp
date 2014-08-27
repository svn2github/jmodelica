#ifndef TRANSFER_XML_IMPL
#define TRANSFER_XML_IMPL

#include <string>
#include <stdlib.h>
#include <vector>

// casadi include
#include "symbolic/casadi.hpp"

// ModelicaCasadi interface includes
#include "Model.hpp"
#include "Variable.hpp"
#include "Ref.hpp"

// XML parser include
#include "tinyxml2.h"

namespace ModelicaCasADi {
    void parseXML(std::string modelName, const std::vector<std::string> &modelFiles, tinyxml2::XMLDocument &doc);
    
    void transferDeclarations(Ref<Model> m, tinyxml2::XMLElement *decl);
    void transferComponent(Ref<Model> m, tinyxml2::XMLElement *component);
    void transferClassDefinition(Ref<Model> m, tinyxml2::XMLElement *classDef);
    
    void transferEquations(Ref<Model> m, tinyxml2::XMLElement *elem, const char *equType);
    void transferParameterEquations(Ref<Model> m, tinyxml2::XMLElement *elem);
    
    bool isElement(tinyxml2::XMLElement *elem, const char *name);
    bool hasAttribute(tinyxml2::XMLElement *elem, const char *attrName);
    bool hasAttribute(tinyxml2::XMLElement *elem, const char *attrName, const char *attrValue);
    
    template <class Var>
    void addAttributes(Ref<Model> m, tinyxml2::XMLElement *variable, Var var) {
        const char *comment = variable->Attribute("comment");
        if (comment != NULL) {
            var->setAttribute("comment", CasADi::MX(comment));
        }
        std::map<std::string, Variable*> funcVars;
        for (tinyxml2::XMLElement *child = variable->FirstChildElement(); child != NULL; child = child->NextSiblingElement()) {
            if (isElement(child, "bindingExpression")) {
                tinyxml2::XMLElement *expression = child->FirstChildElement();
                var->setAttribute("bindingExpression", expressionToMX(m, expression, funcVars));
            } else if (isElement(child, "modifier")) {
                for (tinyxml2::XMLElement *item = child->FirstChildElement(); item != NULL; item = item->NextSiblingElement()) {
                    tinyxml2::XMLElement *itemExpression = item->FirstChildElement();
                    var->setAttribute(item->Attribute("name"), expressionToMX(m, itemExpression, funcVars));
                }
            }
        }
        m->addVariable(var);
    }
};

#endif