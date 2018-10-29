package org.jmodelica.common;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

public class GUIDManager {

    private static final String GUID_TOKEN = "$GUID_TOKEN$";
    private static final String GUID_TOKEN_REGEX = GUID_TOKEN.replace("$", "\\$");

    private final List<File> dependentFiles = new ArrayList<>();
    private final File source;
    private String guid = null;


    public GUIDManager(File source) {
        this.source = source;
    }

    public void addDependentFile(File dependentFile) {
        dependentFiles.add(dependentFile);
    }

    private String getGuid() {
        if (guid == null) {
            try {
                final MessageDigest md5 = MessageDigest.getInstance("MD5");

                try (final BufferedReader reader = new BufferedReader(new FileReader(source))) {
                    boolean foundFirstToken = false;

                    String line = reader.readLine();
                    while (line != null) {
                        if (!foundFirstToken && line.contains(GUID_TOKEN)) {
                            // Replace the first occurrence of the GUID token 
                            foundFirstToken = true;
                            line = line.replaceFirst(GUID_TOKEN_REGEX, "");
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

    public void processDependentFiles() throws IOException {
        for (final File file : dependentFiles) {

            final File tmpFile = new File (file.getAbsolutePath() + ".tmp");
            processFiles(file, tmpFile);

            final Path temporaryFilePath = tmpFile.toPath();
            Files.move(temporaryFilePath, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            Files.deleteIfExists(temporaryFilePath);
        }
    }

    private void processFiles(File source, File destination) throws IOException {
        try (final BufferedReader reader = new BufferedReader(new FileReader(source));
                final BufferedWriter writer = new BufferedWriter(new FileWriter(destination))) {
            boolean foundFirstToken = false;

            String line =  reader.readLine();
            while (line != null) {
                if (!foundFirstToken && line.contains(GUID_TOKEN)) {
                    foundFirstToken = true;
                    line = line.replaceFirst(GUID_TOKEN_REGEX, getGuid());
                }

                writer.write(line);
                writer.write('\n');
                line = reader.readLine();
            }
        }
    }

    public static void main(String[] args) throws IOException {
        final GUIDManager guidManager = new GUIDManager(new File("c:/tmp/model.txt"));

        guidManager.addDependentFile(new File("c:/tmp/test.txt"));
        guidManager.addDependentFile(new File("c:/tmp/test-2.txt"));
        guidManager.processDependentFiles();
    }
}
