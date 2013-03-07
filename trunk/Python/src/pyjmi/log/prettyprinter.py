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

quote_pattern = re.compile('"')
identifier_pattern = re.compile('^' + lexer.identifier_re + '\Z')


def pprint(out, node, indent=0):
    """Pretty print the log node node to the output stream out.

    node may be a Node, Comment, string, or list.
    """    
    if isinstance(node, Node):
        ## Node ##
        if isinstance(node.value, list):
            # name( nodes )name
            out.write(node.name + '(')
            pprint(out, node.value, indent=indent + indent_width)
            out.write(')' + node.name)
        else:
            # name=value            
            out.write(node.name + '=')
            pprint(out, node.value, indent=indent)
    elif isinstance(node, list):
        ## list ##
        vertically = any(isinstance(child, Node) for child in node)
        delim, post = ('\n' + ' '*indent, '\n' + ' '*(indent-indent_width)) if vertically else (' ', ' ')
        for child in node:
            out.write(delim)
            pprint(out, child, indent=indent)
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
