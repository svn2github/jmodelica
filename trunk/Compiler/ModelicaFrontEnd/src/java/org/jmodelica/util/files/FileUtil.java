package org.jmodelica.util.files;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

/**
 * Utility class for files.
 */
public class FileUtil {

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
                if (!directory) {
                    files.add(dir);
                }
            }
        }
        return files;
    }

    /**
     * Returns a collection of all files at the specified path recursively.
     * 
     * @param path
     *            The path from which to collect files. If {@code path} is a
     *            file it is the only element in the returned
     *            {@link Collection}.
     * @return
     *         a collection of all files at the specified path recursively.
     */
    public static Collection<File> getFilesRecursively(File path) {
        List<File> files = new ArrayList<File>();
        if (path.isFile()) {
            files.add(path);
        } else if (path.isDirectory()) {
            for (File file : path.listFiles()) {
                files.addAll(getFilesRecursively(file));
            }
        }
        return files;
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
     * Copies a file from one location to another.
     * 
     * @param source
     *            The file to copy.
     * @param destination
     *            The location of the copied file.
     * @param replaceExisting
     *            A flag specifying whether or not to replace the file if it
     *            already exists at {@code destination}.
     * @throws IOException
     *             if there was any error copying the file.
     */
    public static void copy(File source, File destination, boolean replaceExisting) throws IOException {
        if (!source.exists()) {
            return;
        }

        File newFile = destination;
        if (newFile.isDirectory()) {
            newFile = new File(newFile.getAbsolutePath(), source.getName());
        }

        Files.copy(source.toPath(), newFile.toPath(), replaceExisting ? StandardCopyOption.REPLACE_EXISTING : null);
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

    /**
     * Copies several files to a directory.
     * 
     * @param files
     *            The files to copy.
     * @param destination
     *            The destination of the copied files (if the parameter is a
     *            file, files are copied to the same directory).
     * @param replaceExisting
     *            A flag specifying whether or not to replace the file if it
     *            already exists at {@code destination}.
     * @throws IOException
     *             if there was any error copying the files.
     */
    public static void copyAllTo(Collection<File> files, File destination, boolean replaceExisting) throws IOException {
        File target = (destination.isDirectory() ? destination : destination.getParentFile());
        StandardCopyOption replace = replaceExisting ? StandardCopyOption.REPLACE_EXISTING : null;
        for (File file : files) {
            Files.copy(file.toPath(), new File(target, file.getName()).toPath(), replace);
        }
    }

    /**
     * Deletes a directory, any of its sub-directories, and all files within the
     * directories.
     * 
     * @param directory
     *            The directory to delete.
     */
    public static void recursiveDelete(File directory) {
        for (File file : directory.listFiles()) {
            if (file.isDirectory()) {
                recursiveDelete(file);
            } else {
                file.delete();
            }
        }
        directory.delete();
    }

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

}
