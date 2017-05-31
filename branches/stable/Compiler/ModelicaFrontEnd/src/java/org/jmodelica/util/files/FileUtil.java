package org.jmodelica.util.files;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * Utility class for files.
 */
public class FileUtil {

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
}
