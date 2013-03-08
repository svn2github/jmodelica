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
Pretty printer/unparser for the new FMU log format
"""

import re

import lexer
from tree import Node, Comment

indent_width = 2
nodename_padding = 14

quote_pattern = re.compile('"')
identifier_pattern = re.compile('^' + lexer.identifier_re + '\Z')

def prettyprint(out, named_nodes):
    """Pretty print the top level list named_nodes of Node:s to the output stream out."""
    pprint(out, named_nodes, wrapped=False)

def is_vertical(nodes):
    return any(isinstance(node, (Node, list)) for node in nodes)

def pprint(out, node, indent=0, wrapped=True):
    """Pretty print the log node node to the output stream out.

    node may be a Node, Comment, string, or list.
    """    
    if isinstance(node, Node):
        ## Node ##
        if isinstance(node.value, list):
            # name( named-nodes )name or name[ nodes ]name
            out.write(node.name if is_vertical(node.value) else node.name.ljust(nodename_padding))
            pprint(out, node.value, indent=indent)
            out.write(node.name)
        else:
            # name=value            
            out.write(node.name.ljust(nodename_padding-2) + ' = ')
            pprint(out, node.value, indent=indent)
    elif isinstance(node, list):
        ## list ##
        child_indent = indent + indent_width if wrapped else indent
        named    = any(isinstance(child, Node) for child in node)
        vertical = is_vertical(node)
        delim, post = (('\n' + ' '*child_indent, '\n' + ' '*indent) if vertical else (' ', ' '))        
        if wrapped:
            pre, post = ('(', post + ')') if named else ('[', post + ']')
            out.write(pre)
        for child in node:
            out.write(delim)
            pprint(out, child, indent=child_indent)
        out.write(post)
    elif isinstance(node, Comment):
        ## Comment ##
        out.write('{'+ node.text + '}')
    elif isinstance(node, str):
        ## string ##
        if identifier_pattern.match(node):
            out.write(node)
        else:
            out.write('"' + quote_pattern.sub('""', node) + '"')
    else:
        ## default ##
        out.write(str(node))  # consider: should we be this permissive?
        # raise Exception("Don't know how to pretty print node " + repr(node) + "\ntype = " + repr(type(node)))
