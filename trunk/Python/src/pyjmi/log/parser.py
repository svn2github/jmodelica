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

#import pyjmi.log.lexer
#from pyjmi.log.lexer import SYMBOL, IDENTIFIER, COMMENT, STRING, EOF
#from pyjmi.log.tree import Node, Comment

import lexer
from lexer import SYMBOL, IDENTIFIER, COMMENT, STRING, EOF
from tree import Node, Comment


def parse(text):
    """Parse the string text and return a list of nodes in the format of tree.py."""
    return parse_nodes(Peeker(lexer.lex(text)+[(EOF, '')]))

## Helpers ##

def expect(tokens, token):
    actual = tokens.next()
    if actual != token:
        raise Exception("expected " + repr(token) + ", got " + repr(actual))

def asnode(token):
    kind, text = token
    if kind in (IDENTIFIER, STRING):
        return text
    elif kind == COMMENT:
        return Comment(text)
    else:
        raise Exception("asnode: don't know how to make a node from token " + repr(token))

## Nonterminals ##
    
def parse_nodes(tokens):
    """Parse and return a list of nodes."""
    nodes = []
    while tokens.peek() != (SYMBOL, ')') and tokens.peek()[0] != EOF:
        nodes.append(parse_node(tokens))
    return nodes

def parse_node(tokens):
    """Parse and return a node."""
    kind, text = token = tokens.peek()
    if kind in (COMMENT, STRING):
        return asnode(tokens.next())
    elif kind == IDENTIFIER:
        identifier = text
        tokens.next()
        
        # Possible continuations:
        #   identifier (  nodes  ) identifier
        #   identifier = value
        #   identifier  # acts as a value otherwise
        
        peek = tokens.peek()
        if peek == (SYMBOL, '('):
            # identifier (  nodes  ) identifier
            tokens.next()
            nodes = parse_nodes(tokens)
            expect(tokens, (SYMBOL, ')'))
            expect(tokens, (IDENTIFIER, identifier))
            return Node(identifier, nodes)
        elif peek == (SYMBOL, '='):
            # identifier = value
            tokens.next()
            return Node(identifier, parse_value(tokens))
        else:
            # identifier  # acts as a value otherwise
            return asnode(token)
    else:
        raise Exception("parse_node: unexpected token: " + repr(tokens.peek()))

def parse_value(tokens):
    """Parse and return a value node."""
    kind, text = token = tokens.next()
    if kind in (IDENTIFIER, STRING):
        return asnode(token)
    else:
        raise Exception("parse_value: unexpected token: " + repr(token))


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
