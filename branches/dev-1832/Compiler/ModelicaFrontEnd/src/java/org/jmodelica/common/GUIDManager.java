package org.jmodelica.common;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class GUIDManager {

    private static final String GUID_TOKEN = "$GUID_TOKEN$";
    private static final String GUID_TOKEN_REGEX = GUID_TOKEN.replace("$", "\\$");

    private static final String DATE_TOKEN = "$DATE_TOKEN$";
    private static final String DATE_TOKEN_REGEX = DATE_TOKEN.replace("$", "\\$");
    private final SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

    private final List<Openable> dependentFiles = new ArrayList<>();
    private Openable source;
    private String guid = null;
    private String date = null;

    public String getGuidToken() {
        return GUID_TOKEN;
    }

    public String getDateToken() {
        return DATE_TOKEN;
    }

    public void setSourceFile(File source) {
        this.source = new FileOpenable(source);
    }

    public void setSourceString(String source) {
        this.source = new StringOpenable(source, null);
    }

    public void addDependentFile(File dependentFile) {
        dependentFiles.add(new FileOpenable(dependentFile));
    }

    public void addDependentString(String input, StringBuilder output) {
        dependentFiles.add(new StringOpenable(input, output));
    }

    private String getGuid() {
        if (guid == null) {
            try {
                final MessageDigest md5 = MessageDigest.getInstance("MD5");

                try (final BufferedReader reader = new BufferedReader(source.openInput())) {
                    boolean foundFirstGuid = false;
                    boolean foundFirstDate = false;

                    String line = reader.readLine();
                    while (line != null) {
                        if (!foundFirstGuid && line.contains(GUID_TOKEN)) {
                            // Replace the first occurrence of the GUID token 
                            foundFirstGuid = true;
                            line = line.replaceFirst(GUID_TOKEN_REGEX, "");
                        }
                        if (!foundFirstDate && line.contains(DATE_TOKEN)) {
                            // Replace the first occurrence of the date token 
                            foundFirstDate = true;
                            line = line.replaceFirst(DATE_TOKEN_REGEX, "");
                        }

                        // A naive implementation that is expected to create a digest different from what a command
                        // line tool would create. No lines breaks are included in the digest, and no
                        // character encodings are specified.
                        md5.update(line.getBytes());
                        line = reader.readLine();
                    }
                }

                guid = new BigInteger(1,md5.digest()).toString(16);
            }  catch (IOException | NoSuchAlgorithmException e) {
                throw new RuntimeException(e);
            }
        }

        return guid;
    }

    private String getDate() {
        if (date == null) {
            date = dateformat.format(new Date());
        }
        return date;
    }

    public void processDependentFiles() {
        for (final Openable openable : dependentFiles) {
            try {
                ByteArrayOutputStream os = new ByteArrayOutputStream();
                try (final Writer tmp = new OutputStreamWriter(os)) {
                    processFiles(openable.openInput(), tmp);
                }

                try (BufferedWriter writer = new BufferedWriter(openable.openOutput())) {
                    writer.append(os.toString());
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private void processFiles(Reader source, Writer destination) throws IOException {
        try (final BufferedReader reader = new BufferedReader(source);
                final BufferedWriter writer = new BufferedWriter(destination)) {
            boolean foundFirstGuid = false;
            boolean foundFirstDate = false;

            String line =  reader.readLine();
            while (line != null) {
                if (!foundFirstGuid && line.contains(GUID_TOKEN)) {
                    foundFirstGuid = true;
                    line = line.replaceFirst(GUID_TOKEN_REGEX, getGuid());
                }

                if (!foundFirstDate && line.contains(DATE_TOKEN)) {
                    foundFirstDate = true;
                    line = line.replaceFirst(DATE_TOKEN_REGEX, getDate());
                }

                writer.write(line);
                writer.write('\n');
                line = reader.readLine();
            }
        }
    }

    private interface Openable {
        public Reader openInput();
        public Writer openOutput();
    }
    
    private class FileOpenable implements Openable{
        private File file;
        
        public FileOpenable(File file) {
            this.file = file;
        }
        
        @Override
        public Reader openInput() {
            try {
                return new FileReader(file);
            } catch (FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }
        
        @Override
        public Writer openOutput() {
            try {
                return new FileWriter(file);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }
    
    private class StringOpenable implements Openable {
        
        private String input;
        private StringBuilder output;
        
        public StringOpenable(String input, StringBuilder output) {
            this.input = input;
            this.output = output;
        }
        
        @Override
        public Reader openInput() {
            return new StringReader(input);
        }
        
        @Override
        public Writer openOutput() {
            return new Writer() {
                
                @Override
                public void write(char[] cbuf, int off, int len) throws IOException {
                    output.append(cbuf, off, len);
                }
                
                @Override
                public void flush() throws IOException {
                }
                
                @Override
                public void close() throws IOException {
                }
            };
        }
    }
}
