#!/usr/bin/env python 
# -*- coding: utf-8 -*-

# Copyright (C) 2013 Modelon AB
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
"""
Tree representation for the new FMU log format

Each node is represented as a NamedNode, Comment, string or list
"""

class Comment(object):
    """Log comment node.

    Attributes:
    text -- the comment text without enclosing braces {}
    """
    def __init__(self, text):
        assert isinstance(text, str)
        self.text = text

    def __repr__(self):
        return "{" + self.text + "}"

class NamedNode(object):
    """Named log node.

    Attributes:
    name  -- a string
    value -- a list for long nodes `name( ... )name`
             a value for short nodes `name=value`
    """    
    def __init__(self, name, value):
        assert isinstance(name, str)
        self.name = name
        self.value = value

    def __repr__(self):
        return self.name + "( " + repr(self.value) + " )"

    def children(self, name):
        return [self.value] if self.name == name else find_children(self.value, name)


class NodeList(object):
    """List of log nodes"""
    def __init__(self, nodes = None):
        if nodes is None:
            nodes = []
        self.list = nodes

        self.dict = {}
        for node in nodes:
            self.add_dict_node(node)

    def add_dict_node(self, node):
        if not isinstance(node, NamedNode):
            return
        key = node.name
        if key in self.dict:
            # ambiguous ==> record no value. todo: Is None the best to use for this?
            self.dict[key] = None
        else:
            self.dict[key] = node.value

    # todo: remove?
    def __iter__(self):
        return iter(self.nodes)

 
    def __contains__(self, key):
        return key in self.dict

    def __getitem__(self, key):
        return self.dict[key]

    def __getattr__(self, name):
        return self[name]

    def __setitem__(self, key, value):
         self.dict[key] = value
    
    def children(self, name):
        nodes = []
        for node in self.list:
            nodes.extend(find_children(node, name))
        return nodes    


def find_children(node, name):
    if isinstance(node, (NodeList, NamedNode)):
        return node.children(name)
    else:
        return []
