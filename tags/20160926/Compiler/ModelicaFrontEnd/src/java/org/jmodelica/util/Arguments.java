/*
    Copyright (C) 2014 Modelon AB

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

package org.jmodelica.util;

import java.util.HashSet;
import java.util.Hashtable;
import java.util.Set;

public class Arguments {
    String compilerName;
    private String[] args;
    private Hashtable<String, String> programargs;
    
    public Arguments(String compilerName, String[] args) throws InvalidArgumentException {
        this.compilerName = compilerName;
        this.args = args;
        this.programargs = new Hashtable<String,String>();
        setDefaultArgs();
        extractProgramArguments();
        checkArgs();
    }
    
    private void addOptionToMap(String arg) {
        String[] parts = arg.trim().substring(1).split("=", 2);
        programargs.put(parts[0], (parts.length > 1) ? parts[1] : "");
    }
    
    private boolean argumentIsOption(String arg) {
        return arg.trim().startsWith("-");
    }
    
    public String line() {
        StringBuilder buf = new StringBuilder();
        for (String arg : args) {
            buf.append(arg);
            buf.append(' ');
        }
        return buf.toString();
    }
    
    public boolean containsKey(String arg) {
        return programargs.containsKey(arg);
    }
    
    public String get(String arg) {
        return programargs.get(arg);
    }
    
    public int size() {
        return programargs.size();
    }
    
    private String tooltip() {
        return compilerName + " expects the command line arguments: \n" +
                "[<options>] <file name> <class name> [<target>] [<version>]\n" +
                " where options could be: \n" +
                "  -log=<i or w or e> \n" +
                "  -modelicapath=<path to modelica libraries> \n" +
                "  -optfile=<path to XML options file> -opt=opt1:val1,opt2:val2\n" + 
                "  -target=<fmume, me ,fmucs, cs, jmu, fmux, parse or check>\n" +
                "  -version=<1.0 or 2.0>\n" +
                "  -dumpmemuse[=<resolution>] -findflatinst \n" + 
                "  -platform=<win32 or win64 or linux32 or linux64 or darwin32 or darwin64>" +
                " If no target is given, -jmu is assumed." +
                " If no version is given in case of targets 'me' or 'cs', -1.0 is assumed";
    }
    
    private String argError() throws InvalidArgumentException {
        throw new InvalidArgumentException(tooltip());
    }
    
    private String argError(String pref) throws InvalidArgumentException {
        throw new InvalidArgumentException(pref + tooltip());
    }
    
    private void setDefaultArgs() {
        programargs.put("target", "jmu");
    }
    
    private void extractProgramArguments() {
        int pos = 0;
        while(pos < args.length && argumentIsOption(args[pos])) {
            addOptionToMap(args[pos]);
            pos++;
        }
    }
    
    private void checkArgs() throws InvalidArgumentException {
        if (args.length < 1) {
            argError();
        }
        
        Set<String> m = new HashSet<String>();
        m.add("log");
        m.add("modelicapath");
        m.add("opt");
        m.add("optfile");
        m.add("target");
        m.add("version");
        m.add("dumpmemuse");
        m.add("findflatinst");
        m.add("platform");
        m.add("out");
        m.add("debugSrcIsHome");
        for (String given : programargs.keySet()) {
            if (!m.contains(given)) {
                argError(String.format("Invalid argument '%s'\n", given));
            }
        }
        
        int arg = programargs.size();
        if (args.length < arg+2 && !programargs.get("target").equals("parse")) {
            throw new InvalidArgumentException(compilerName + " expects a file name and a class name as command line arguments.");
        }
        if (programargs.get("target").equals("parse") && args.length != arg+1) {
            throw new InvalidArgumentException(compilerName + " -parse expects a list of filenames.");
        }
    }
    
    public class InvalidArgumentException extends Exception{
        private static final long serialVersionUID = 8291101686361405225L;
        public InvalidArgumentException(String msg) {
            super(msg);
        }
    }
}