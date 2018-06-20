package org.jmodelica.build.options;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class OptionsParser {

    private Map<String, OptionParsed> options = new LinkedHashMap<>();

    static class ParseException extends Exception {
        public ParseException(String string) {
            super(string);
        }

        private static final long serialVersionUID = -8924212971616929776L;
    }

    private static class StringBuilderVarArgs {
        private StringBuilder sb = new StringBuilder();

        public void append(String... strings) {
            for (String s : strings) {
                sb.append(s);
            }
        }

        public String toString() {
            return sb.toString();
        }
    }

    static abstract class OptionParsed {

        protected String filePath;
        protected String kind;
        protected String name;
        protected String defaultValue;

        public OptionParsed(String filePath, String kind, String name, String defaultValue) {
            this.filePath = filePath;
            this.kind = kind;
            this.name = name;
            this.defaultValue = defaultValue;
        }

        public String getFilePath() {
            return filePath;
        }
        
        public String getKind() {
            return kind;
        }
        
        public String getName() {
            return name;
        }

        public final String toJavaString() {
            StringBuilderVarArgs sb = new StringBuilderVarArgs();
            toJavaString(sb);
            return sb.toString();
        }

        public abstract void toJavaString(StringBuilderVarArgs sb);
    }

    class OptionParsedDefault extends OptionParsed {

        public OptionParsedDefault(String filePath, String kind, String name, String defaultValue) {
            super(filePath, kind, name, defaultValue);
        }

        @Override
        public String getName() {
            return getKind() + " " + super.getName();
        }

        @Override
        public void toJavaString(StringBuilderVarArgs sb) {
            OptionParsed original = options.get(name);
            String originalKind = original != null ? original.getKind() : "Boolean";
            sb.append("        options.set", originalKind, "Option(\"");
            sb.append(name, "\", ", defaultValue);
            sb.append(");\n");
        }
    }

    static class OptionParsedFull extends OptionParsed {
        private String type;
        private String cat;

        private String testDefaultValue;
        private String[] args;
        private String comment;
        private String[] possibleValues;

        public OptionParsedFull(String filePath, String cls, String name, String defaultValue, String type,
                String cat) {
            super(filePath, cls, name, defaultValue);
            this.type = type;
            this.cat = cat;
        }

        public void setTestDefaultValue(String testDefaultValue) {
            this.testDefaultValue = testDefaultValue;
        }

        public void setArgs(String[] args) {
            this.args = args;
        }

        public void setComment(String comment) {
            this.comment = comment;
        }

        public void setPossibleValues(String[] possibleValues) {
            this.possibleValues = possibleValues;
        }

        @Override
        public void toJavaString(StringBuilderVarArgs sb) {
            sb.append("        options.add", kind, "Option(\"");
            sb.append(name, "\", ");
            sb.append("OptionType.", type, ", ");
            sb.append("Category.", cat, ", ");
            sb.append(defaultValue);
            if (testDefaultValue != null) {
                sb.append(", ");
                sb.append(testDefaultValue);
            }
            sb.append(", ", comment);
            if (args != null) {
                for (String s : args) {
                    sb.append(", ", s);
                }
            }
            if (possibleValues != null) {
                sb.append(", new String[] {");
                for (String s : possibleValues) {
                    sb.append(s, ", ");
                }
                sb.append("}");
            }
            sb.append(");\n");
        }
    }

    public void generate(FileWriter out, String pack) throws IOException {
        out.write("package " + pack + ";\n" + "import java.util.LinkedHashMap;\n" + "import java.util.Map;\n" + "\n"
                + "import org.jmodelica.common.options.Option;\n"
                + "import org.jmodelica.common.options.OptionRegistry;\n"
                + "import org.jmodelica.common.options.OptionRegistry.Category;\n"
                + "import org.jmodelica.common.options.OptionRegistry.OptionType;\n" + "\n"
                + "public class OptionsAggregated {\n");

        out.write("    public static void addTo(OptionRegistry options) {\n");
        for (OptionParsed opt : options.values()) {
            out.write(opt.toJavaString());
        }
        out.write("    }\n");
        out.write("}\n");
    }

    public String nextLine(BufferedReader reader) throws IOException {
        String line;
        while ((line = reader.readLine()) != null && isEmpty(line)) {

        }
        return line;
    }

    private boolean isEmpty(String line) {
        return line.isEmpty() || line.startsWith("***");
    }

    private String parseKind(String kind) throws ParseException {
        if (kind.equals("STRING")) {
            return "String";
        } else if (kind.equals("BOOLEAN")) {
            return "Boolean";
        } else if (kind.equals("INTEGER")) {
            return "Integer";
        } else {
            throw new ParseException("Unknown kind '" + kind + "'");
        }
    }

    private OptionParsed parseNextOption(File optionsFile, BufferedReader reader) throws IOException, ParseException {
        String line = nextLine(reader);
        if (line == null) {
            return null;
        }
        String[] parts = line.split(" ");
        if (parts.length > 7) {
            throw new ParseException("Too many parts on the line! " + optionsFile.getAbsolutePath());
        }

        String kind = parts[0];
        if (kind.equals("DEFAULT")) {
            String name = parts[1];
            String defaultValue = parts[2];
            return new OptionParsedDefault(optionsFile.getAbsolutePath(), kind, name, defaultValue);
        } else {
            kind = parseKind(kind);
        }
        String name = parts[1];
        String category = parts[2];
        String type = parts[3];
        String defaultValue = parts[4];
        OptionParsedFull res = new OptionParsedFull(optionsFile.getAbsolutePath(), kind, name, defaultValue, category,
                type);
        if (parts.length > 5) {
            res.setTestDefaultValue(parts[5]);
        }
        if (parts.length > 6) {
            res.setArgs(Arrays.copyOfRange(parts, 5, parts.length));
        }

        line = reader.readLine();
        if (!isEmpty(line)) {
            res.setPossibleValues(line.split(" "));
        }

        StringBuilder comment = new StringBuilder();
        line = nextLine(reader);
        do {
            comment.append(line);
        } while ((line = reader.readLine()) != null && !isEmpty(line));

        res.setComment(comment.toString());

        return res;
    }

    public void parseFile(File optionsFile) throws IOException, ParseException {

        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(optionsFile), "UTF8"));

        OptionParsed opt;
        while ((opt = parseNextOption(optionsFile, reader)) != null) {
            OptionParsed old = options.get(opt.getName());
            if (old != null) {
                throw new ParseException(
                        "Found duplicated option declaration for " + opt.getName() + ". Old declaration from "
                                + old.getFilePath() + ". New declaration from " + opt.getFilePath());
            }
            options.put(opt.getName(), opt);
        }
        reader.close();

    }

    public void parseFiles(String modules) throws IOException, ParseException {
        for (String module : modules.split(",")) {
            module = module.trim();
            module = module.substring(1, module.length() - 1);
            File in = new File(module, "module.options");
            if (in.exists()) {
                parseFile(in);
            }
        }
    }

    public static void main(String[] args) throws IOException, ParseException {
        File outDir = new File(args[0]);
        String pack = args[1];
        String modules = args[3];

        OptionsParser op = new OptionsParser();
        File outFile = new File(outDir, "OptionsAggregated.java");
        FileWriter fw = new FileWriter(outFile);
        op.parseFiles(modules);
        op.generate(fw, pack);
        fw.close();
        System.out.println("Generated " + outFile.getAbsolutePath() + "...");
    }

}
