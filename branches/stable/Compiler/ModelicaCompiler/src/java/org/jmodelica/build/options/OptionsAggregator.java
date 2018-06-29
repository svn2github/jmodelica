package org.jmodelica.build.options;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.Map;

public class OptionsAggregator {

    private Map<String, OptionDeclaration> options = new LinkedHashMap<>();
    private ArrayList<OptionModification> optionsModification = new ArrayList<>();

    static class OptionsAggregationException extends Exception {
        public OptionsAggregationException(String string) {
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

    private static abstract class Option {

        protected String filePath;
        protected String kind;
        protected String name;
        protected String defaultValue;

        public Option(String filePath, String kind, String name, String defaultValue) {
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
    }

    private abstract class OptionModification extends Option {
        public OptionModification(String filePath, String kind, String name, String defaultValue) {
            super(filePath, kind, name, defaultValue);
        }
        
        void modify() throws OptionsAggregationException {
            OptionDeclaration opt = options.get(getName());
            if (opt == null) {
                throw new OptionsAggregationException("Missing option for modification " + getKind() + " " + getName());
            }
            opt.setModified();
            modify(opt);
        }
        abstract void modify(OptionDeclaration opt) throws OptionsAggregationException;
    }
    
    private class OptionModificationSetDefault extends OptionModification {

        public OptionModificationSetDefault(String filePath, String kind, String name, String defaultValue) {
            super(filePath, kind, name, defaultValue);
        }

        @Override
        void modify(OptionDeclaration opt) throws OptionsAggregationException {
            opt.setDefaultValue(defaultValue);
        }

    }

    private class OptionModificationRemove extends OptionModification {

        public OptionModificationRemove(String filePath, String kind, String name) throws OptionsAggregationException {
            super(filePath, kind, name, null);
        }

        @Override
        void modify(OptionDeclaration opt) throws OptionsAggregationException {
            opt.setRemoved();
        }
    }

    private class OptionModificationInvert extends OptionModification {

        public OptionModificationInvert(String filePath, String kind, String name, String defaultValue) throws OptionsAggregationException {
            super(filePath, kind, name, defaultValue);
        }

        @Override
        void modify(OptionDeclaration opt) throws OptionsAggregationException {
            String newDefaultValue = "options.new DefaultInvertBoolean(\"" + defaultValue + "\")";
            opt.setDefaultValue(newDefaultValue);
            opt.setTestDefaultValue(newDefaultValue);
        }
    }

    private static class OptionDeclaration extends Option {
        private String type;
        private String cat;

        private String testDefaultValue;
        private String[] args;
        private String comment;
        private String[] possibleValues;
        private boolean removed = false;
        private boolean modified = false;

        public OptionDeclaration(String filePath, String cls, String name, String defaultValue, String type,
                String cat) {
            super(filePath, cls, name, defaultValue);
            this.testDefaultValue = defaultValue;
            this.type = type;
            this.cat = cat;
        }

        public void setModified() throws OptionsAggregationException {
            if (modified) {
                throw new OptionsAggregationException("Option already modified " + getName());
            }
            modified = true;
        }

        public void setDefaultValue(String defaultValue) {
            this.defaultValue = defaultValue;
        }

        public void setRemoved() {
            removed = true;
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

        public final String toJavaString() {
            StringBuilderVarArgs sb = new StringBuilderVarArgs();
            toJavaString(sb);
            return sb.toString();
        }
        
        public void toJavaString(StringBuilderVarArgs sb) {
            if (removed) {
                return;
            }
            sb.append("        options.add", kind, "Option(\"");
            sb.append(name, "\", ");
            sb.append("OptionType.", type, ", ");
            sb.append("Category.", cat, ", ");
            sb.append(defaultValue, ", ");
            sb.append(testDefaultValue, ", ");
            sb.append(comment);
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

    public void generateHeader(OutputStreamWriter out, String pack) throws IOException {
        out.write("package " + pack + ";\n"
                + "import java.util.LinkedHashMap;\n"
                + "import java.util.Map;\n" + "\n"
                + "import org.jmodelica.common.options.Option;\n"
                + "import org.jmodelica.common.options.OptionRegistry;\n"
                + "import org.jmodelica.common.options.OptionRegistry.Category;\n"
                + "import org.jmodelica.common.options.OptionRegistry.OptionType;\n" + "\n"
                + "public class OptionsAggregated {\n");
    }
    
    public void generateCalls(OutputStreamWriter out) throws IOException {
        for (OptionDeclaration opt : options.values()) {
            out.write(opt.toJavaString());
        }
    }
    
    public void generate(OutputStreamWriter out, String pack) throws IOException {
        generateHeader(out, pack);
        out.write("    public static void addTo(OptionRegistry options) {\n");
        generateCalls(out);
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
        return line == null || line.isEmpty() || line.startsWith("***");
    }

    private String parseKind(String kind) throws OptionsAggregationException {
        return kind.substring(0, 1).toUpperCase() + kind.substring(1).toLowerCase();
    }

    private boolean parseNextOption(String optionsFile, BufferedReader reader) throws IOException, OptionsAggregationException {
        String line = nextLine(reader);
        if (line == null) {
            return false;
        }
        String[] parts = line.split(" ");
        if (parts.length > 7) {
            throw new OptionsAggregationException("Too many parts on the line! " + optionsFile);
        }

        if (parts[0].equals("DEFAULT")) {
            String name = parts[1];
            String defaultValue = parts[2];
            optionsModification.add(new OptionModificationSetDefault(optionsFile, parts[0], name, defaultValue));
            return true;
        } else if (parts[0].equals("REMOVE")) {
            String name = parts[1];
            optionsModification.add(new OptionModificationRemove(optionsFile, parts[0], name));
            return true;
        } else if (parts[0].equals("INVERT")) {
            String name = parts[1];
            String defaultValue = parts[2];
            optionsModification.add(new OptionModificationInvert(optionsFile, parts[0], name, defaultValue));
            return true;
        }
        
        String kind = parseKind(parts[0]);
        String name = parts[1];
        String category = parts[2];
        String type = parts[3];
        String defaultValue = parts[4];
        OptionDeclaration res = new OptionDeclaration(optionsFile, kind, name, defaultValue, category,
                type);
        if (parts.length > 6) {
            res.setArgs(Arrays.copyOfRange(parts, 5, parts.length));
        } else if (parts.length > 5) {
            res.setTestDefaultValue(parts[5]);
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

        Option old = options.get(res.getName());
        if (old != null) {
            throw new OptionsAggregationException(
                    "Found duplicated option declaration for " + res.getName() + ". Old declaration from "
                            + old.getFilePath() + ". New declaration from " + res.getFilePath());
        }
        options.put(res.getName(), res);
        
        return true;
    }

    public void parseFile(String file, BufferedReader reader) throws IOException, OptionsAggregationException {
        while (parseNextOption(file, reader)) {
            
        }
    }
    
    public void parseFile(File optionsFile) throws IOException, OptionsAggregationException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(optionsFile), "UTF8"));
        parseFile(optionsFile.getAbsolutePath(), reader);
        reader.close();
    }

    public void parseFiles(String modules) throws IOException, OptionsAggregationException {
        for (String module : modules.split(",")) {
            module = module.trim();
            module = module.substring(1, module.length() - 1);
            File moduleFile = new File(module);
            if (moduleFile.exists()) {
                for (File in : moduleFile.listFiles()) {
                    if (in.getName().endsWith(".options")) {
                        parseFile(in);
                    }
                }
            }
        }
    }

    public void modify() throws OptionsAggregationException {
        for (OptionModification mod : optionsModification) {
            mod.modify();
        }
    }

    public static void main(String[] args) throws IOException, OptionsAggregationException {
        File outDir = new File(args[0]);
        String pack = args[1];
        String modules = args[3];

        OptionsAggregator op = new OptionsAggregator();
        File outFile = new File(outDir, "OptionsAggregated.java");
        op.parseFiles(modules);
        op.modify();
        OutputStreamWriter out = new OutputStreamWriter(new FileOutputStream(outFile));
        op.generate(out, pack);
        out.close();
        System.out.println("Generated " + outFile.getAbsolutePath() + "...");
    }

}
