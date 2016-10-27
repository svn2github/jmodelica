/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.util.streams;

import java.nio.charset.Charset;

public class CStringCodeStream extends CodeStream {
    private int limit;
    private int n = 0;
    private boolean first = true;
    private String beginString = "(truncated) ";
    private String endString = "...";
    private StringBuilder buffer;

    public static final Charset UTF8 = Charset.forName("UTF-8");


    public CStringCodeStream(CodeStream str) {
        this(str, 509);
    }
    
    public CStringCodeStream(CodeStream str, int lim) {
        super(str);
        this.limit = lim - endString.length() - beginString.length();
        buffer = new StringBuilder();
    }
    
    public void print(String s) {
        if (n < limit) {
            byte[] bytes = s.getBytes(UTF8);
            encode(bytes, Math.min(bytes.length, limit - n));
            n += bytes.length;
        }
    }
    
    public void close() {
        boolean trunc = buffer.length() >= limit;
        if (trunc)
            super.print(beginString);
        super.print(buffer.toString());
        if (trunc)
            super.print(endString);
    }

    private void encode(byte[] str, int n) {
        for (int i = 0; i < n; i++) {
            byte c = str[i];
            if (c == '\n') {
                buffer.append("\\n");
            } else if (c > 31 && c < 127) {
                if (c == '"' || c == '\\')
                    buffer.append('\\');
                buffer.append((char) c);
            } else if (c != 0) {
                int c2 = (c < 0) ? 256 + c : c;
                buffer.append((c2 < 16) ? "\\x0" : "\\x");
                buffer.append(Integer.toHexString(c2));
            }
        }
    }
}