package org.jmodelica.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Utility class for file management.
 */
public class FileUtil {

    /**
     * Retrieves the contents of a file as a list of string lines.
     * 
     * @param file
     *            The file from which to fetch contents.
     * @return
     *         a list of strings where each string is a line in {@code file}.
     * @throws IOException
     *             if there was any error reading {@code file}.
     */
    public static List<String> fileAsLines(File file) throws IOException {
        return Arrays.asList(new String(Files.readAllBytes(Paths.get(file.getAbsolutePath()))).split("\n"));
    }

    /**
     * Retrieves all the files or directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @param directory
     *            Flag for whether to collect directory names or file names.
     * @return
     *         a list of file names from the specified sources.
     */
    public static List<File> allFiles(boolean directory, File... sources) {
        List<File> files = new ArrayList<File>();
        for (File dir : sources) {

            if (dir.isDirectory()) {
                for (File file : dir.listFiles()) {
                    if (file.isDirectory() == directory) {
                        files.add(file);
                    }
                }
            } else {
                /*
                 * If we retrieve files and a source is a file, include it.
                 */
                if (!directory) {
                    files.add(dir);
                }
            }
        }
        return files;
    }

    /**
     * Retrieves all the files from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of files from the specified sources.
     * @see #allFiles(boolean, File...)
     */
    public static List<File> allFiles(File... sources) {
        return allFiles(false, sources);
    }

    /**
     * Retrieves all the directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of directories from the specified sources.
     * @see #allFiles(boolean, File...)
     */
    public static List<File> allDirectories(File... sources) {
        return allFiles(true, sources);
    }

    /**
     * Retrieves all the names of the files or directories from the specified
     * sources.
     * 
     * @param sources
     *            The file sources.
     * @param directory
     *            Flag for whether to collect directory names or file names.
     * @return
     *         a list of file names from the specified sources.
     */
    public static List<String> allFileNames(boolean directory, File... sources) {
        List<String> names = new ArrayList<String>();
        for (File file : allFiles(directory, sources)) {
            names.add(file.getName());
        }
        return names;
    }

    /**
     * Retrieves all the names of the files from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of file names from the specified sources.
     * @see #allFileNames(boolean, File...)
     */
    public static List<String> allFileNames(File... sources) {
        return allFileNames(false, sources);
    }

    /**
     * Retrieves all the names of the directories from the specified sources.
     * 
     * @param sources
     *            The file sources.
     * @return
     *         a list of directory names from the specified sources.
     * @see #allFileNames(boolean, File...)
     */
    public static List<String> allDirectoryNames(File... sources) {
        return allFileNames(true, sources);
    }

    /**
     * Copies files from a source to a destination recursively.
     * <p>
     * Overwrites files if they already exist.
     * 
     * @param source
     *            The source folder or file.
     * @param destination
     *            The destination folder.
     * @throws IOException
     *             if there was any error copying a file.
     */
    public static void copyRecursive(File source, File destination) throws IOException {
        if (source.isDirectory()) {
            File newDir = new File(destination.getAbsolutePath() + File.separator + source.getName());
            newDir.mkdirs();
            for (File file : source.listFiles()) {
                copyRecursive(file, newDir);
            }
        } else if (source.isFile()) {
            Files.copy(source.toPath(),
                    new File(destination.getAbsolutePath() + File.separator + source.getName()).toPath(),
                    StandardCopyOption.REPLACE_EXISTING);
        }
    }

}
