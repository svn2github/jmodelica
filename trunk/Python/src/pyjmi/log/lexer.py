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
Lexer for the new FMU log file format
"""

import re


# Token kinds
SYMBOL, IDENTIFIER, COMMENT, STRING, EOF = range(5)

# Token patterns
lexer_re = r"""(?x)
(
    [=()}]          # special symbols
    | \s+           # whitespace
    | [^=(){}"\s]+  # identifier
    | \{  [^}]*           (?: \}|\Z )  # comment, possibly ending at the end of input and containing extra {
    | "   (?: [^"]|"" )*  (?: " |\Z )  # string, possibly ending at the end of input and containing a number of ""
)
"""

lexer_pattern = re.compile(lexer_re)
whitespace_pattern = re.compile(r'\s+')
symbol_pattern = re.compile(r'[=()}]')
string_escaped_quote_pattern = re.compile(r'""')
identifier_re = r'[^=(){}"\s]+'


def lex(text):
    """Tokenize the string text.

    Returns a list of tokens on the format

        (kind, text)
      
    with interpretation
        kind (int)    text (string)
        SYMBOL        '=', '(', or ')'
        IDENTIFIER    name of identifier
        COMMENT       comment text without enclosing braces {}
        STRING        string value, without enclosing quotes "",
                      and with "" replaced by literal \"
        EOF           not produced by lex; should have text=''

    Whitespace produces no tokens.
    """
    parts = lexer_pattern.split(text)

    # Check for unclassified parts of text -- lexer_pattern should classify everything
    for unmatched in parts[0::2]:
        if unmatched != '':
            raise Exception('Lexer: failed to tokenize substring ' + repr(unmatched))

    tokens = []
    for part in parts[1::2]:
        if whitespace_pattern.match(part):
            continue
        tokens.append(make_token(part))

    return tokens

def make_token(part):
    assert part != ''  # '' should never match lexer_pattern

    if symbol_pattern.match(part):
        if part == '}':
            raise Error("} not allowed outside of comments")
        return (SYMBOL, part)
    elif part[0] == '{':
        if part[-1] != '}':
            raise Error("Unterminated comment: " + repr(part))
        if "{" in part[1:]:
            raise Error("Nested '{' in comment: "+ repr(part))
        return (COMMENT, part[1:-1])
    elif part[0] == '"':
        if part[-1] != '"':
            raise Error("Unterminated string: " + repr(part))
        return (STRING, string_escaped_quote_pattern.sub('"', part[1:-1]))
    else:
        return (IDENTIFIER, part)


if __name__ == '__main__':
    print lex('x=5 node( {values:} 0.25 0.11 "x*y + 1" {message} "string with "" in it" )node')
