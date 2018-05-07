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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Set;

public class Arguments {
    String compilerName;
    private String[] args;
    private Hashtable<String, String> programargs;
    private List<String> noOption = new ArrayList<String>();
    private String className = "";
    private String libraryPath = "";

    public Arguments(String compilerName, String[] args) throws InvalidArgumentException {
        this.compilerName = compilerName;
        this.args = args;
        this.programargs = new Hashtable<String, String>();
        setDefaultArgs();
        extractProgramArguments();
        checkArgs();
    }

    public String className() {
        return className;
    }

    public String libraryPath() {
        return libraryPath;
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
        return argError("");
    }

    private String argError(String pref) throws InvalidArgumentException {
        throw new InvalidArgumentException(pref + tooltip());
    }

    private void setDefaultArgs() {
        programargs.put("target", "jmu");
    }

    private void extractProgramArguments() throws InvalidArgumentException {
        for (String arg : args) {
            if (argumentIsOption(arg)) {
                addOptionToMap(arg);
            } else {
                noOption.add(arg);
            }
        }
        
        
        if (noOption.isEmpty()) {
            argError();
        }

        if (noOption.size() == 1) {
            if (programargs.get("target").equals("parse")) {
                libraryPath = noOption.get(0);
            } else if (programargs.containsKey("modelicapath")) {
                className = noOption.get(0);
            } else {
                argError();
            }
        } else {
            libraryPath = noOption.get(0);
            className = noOption.get(1);
        }
    }

    private void checkArgs() throws InvalidArgumentException {
        if (noOption.isEmpty()) {
            argError();
        }

        Set<String> options = new HashSet<String>();
        options.add("log");
        options.add("modelicapath");
        options.add("opt");
        options.add("optfile");
        options.add("target");
        options.add("version");
        options.add("dumpmemuse");
        options.add("findflatinst");
        options.add("platform");
        options.add("out");
        options.add("debugSrcIsHome");

        for (String given : programargs.keySet()) {
            if (!options.contains(given)) {
                argError(String.format("Invalid argument '%s'\n", given));
            }
        }

        boolean oneArgument = noOption.size() == 1;
        boolean hasModelicaPath = programargs.get("modelicapath") != null;
        boolean shouldParse = programargs.get("target").equals("parse");

        if (oneArgument) {
            if (!shouldParse && !hasModelicaPath) {
                throw new InvalidArgumentException(compilerName
                        + " expects a file name and a path. If -modelicapath is set, the path can be omitted.");
            }
        } else if (shouldParse) {
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