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
Parser for the new FMU log file format
"""

import numpy as np

#import pyjmi.log.lexer
#from pyjmi.log.lexer import SYMBOL, IDENTIFIER, COMMENT, STRING, EOF
#from pyjmi.log.tree import Node, Comment

import lexer
from lexer import SYMBOL, IDENTIFIER, COMMENT, STRING, EOF, kindof, textof
from tree import Comment, NamedNode, NodeList

def parse(tokens):
    """Parse the token stream and return a NodeList in the format of tree.py."""
    return nodelist_wrap(aslist(parse_nodes(Peeker(tokens))))    

def parse_string(text):
    """Parse the string text and return a NodeList in the format of tree.py."""
    return parse(lexer.lex(text)+[(EOF, '')])

def parse_jmi_log(filename, modulename = 'Model'):
    """Parse the jmi log in filename and return a NodeList in the format of tree.py."""
    return parse(lexer.lex_lines(lexer.filter_fmi_log_lines(filename, modulename)))


## Symbols ##

DICT_BEGIN     = (SYMBOL, '(')
DICT_END       = (SYMBOL, ')')
LIST_BEGIN     = (SYMBOL, '[')
LIST_END       = (SYMBOL, ']')
TYPE_BEGIN     = (SYMBOL, '{')
TYPE_END       = (SYMBOL, '}')
ATTRIBUTE_MARK = (SYMBOL, ':')
NODE_SEPARATOR = (SYMBOL, ',')

def closes_node(token):
    kind, text = token
    return (kind == SYMBOL and text in ')]}') or (kind == EOF)

def ends_node(token):
    return (token == NODE_SEPARATOR) or closes_node(token)


## Helpers ##

DICT_TYPE = "dict"

def expect(tokens, token):
    actual = tokens.next()
    if actual != token:
        raise Exception("expected " + repr(token) + ", got " + repr(actual))

def asnode(token, node_type=None):
    kind, text = token
    if kind in (IDENTIFIER, STRING):
        try:
            if node_type == 'real':
                return float(text)
            elif node_type == 'int':
                return int(text)
            elif node_type == 'bool':
                return bool(int(text))  # NB: quite permissive, should we only accept 0 and 1?
        except ValueError:
            pass
        return text
    elif kind == COMMENT:
        return Comment(text)
    else:
        raise Exception("asnode: don't know how to make a node from token " + repr(token))

eltype_to_dtype = {'real': float, 'int': int, 'bool': bool, 'vref': str, 'string': str}

def aslist(nodes, list_type=None):
    try:
        nesting = 0
        t = list_type
        while isinstance(t, list) and len(t) == 1:
            nesting += 1
            t = t[0]
        if t in eltype_to_dtype:
            if t == 'bool':
                nodes = np.asarray(nodes, dtype=int)        
            return np.asarray(nodes, dtype=eltype_to_dtype[t])
    except ValueError:
        pass
    return nodes

def nodelist_wrap(l):
    return NodeList(l) if isinstance(l, list) else l

## Nonterminals ##

def parse_nodes(tokens):
    """Parse a node list and return as a NodeList."""
    nodes = []
    while not closes_node(tokens.peek()):
        token = tokens.peek()
        if kindof(token) == COMMENT:
            nodes.append(asnode(tokens.next()))
        else:        
            nodes.append(parse_node(tokens))
            if not closes_node(tokens.peek()):
                expect(tokens, NODE_SEPARATOR)
    return nodes

def parse_node(tokens):
    """Parse and return a node."""
    token = tokens.peek()
    if kindof(token) == IDENTIFIER:
        name_token = token
        tokens.next()
        if ends_node(tokens.peek()):
            return asnode(name_token)  # ident

        node_type = parse_type(tokens)
        token = tokens.peek()
        if token == ATTRIBUTE_MARK:
            tokens.next()
            return NamedNode(textof(name_token), parse_value(tokens, node_type))
        else:
            node = NamedNode(textof(name_token), nodelist_wrap(parse_list(tokens, node_type)))
            token = tokens.peek()
            if kindof(token) == IDENTIFIER: # ident list ident                
                if not token == name_token:
                    raise Exception("parse_named_node: " + textof(name_token) + " node closed as " + textof(token))
                tokens.next()
            return node
    else:
        return parse_unnamed(tokens)
    
def parse_unnamed(tokens):
    """Parse and return an unnamed node."""
    node_type = parse_type(tokens)
    token = tokens.peek()
    if kindof(token) in (IDENTIFIER, STRING):
        return parse_value(tokens, node_type)
    else:
        return parse_list(tokens, node_type)

def parse_type(tokens):
    """Parse and return a type annotation.

    Returns None if the next token is not TYPE_BEGIN."""
    if not tokens.peek() == TYPE_BEGIN:
        return None
    tokens.next()
    node = parse_node(tokens)
    expect(tokens, TYPE_END)
    return node

def parse_value(tokens, node_type):
    """Parse and return a value."""
    token = tokens.next()
    if kindof(token) in (IDENTIFIER, STRING):
        return asnode(token, node_type)
    else:
        raise Exception("parse_value: unexpected token " + token)    

def parse_list(tokens, node_type):
    """Parse and return a list with already parsed type node_type (may be None)."""
    opener = tokens.peek()
    if opener == LIST_BEGIN:
        closer = LIST_END
    elif opener == DICT_BEGIN:
        closer = DICT_END
        if node_type != None:
            raise Exception("parse_list_pretyped: Dict lists may not have type annotations!")
        node_type = DICT_TYPE
    else:
        raise Exception("parse_list_pretyped: Expected list begin, got " + repr(opener))
    tokens.next()
    nodes = parse_nodes(tokens)
    expect(tokens, closer)
    return aslist(nodes, node_type)


## Helper class ##
    
class Peeker:
    """Utility class to allow peeking one step into an iterator.

    Does not handle end of the source iterator -- the parser uses a sentinel EOF token.
    """
    def __init__(self, it):
        self.it = iter(it)
        self.curr = next(self.it)
        
    def peek(self):
        """Preview the next item."""
        return self.curr
    def next(self):
        """Consume and return the next item."""
        curr, self.curr = self.curr, next(self.it)
        return curr
