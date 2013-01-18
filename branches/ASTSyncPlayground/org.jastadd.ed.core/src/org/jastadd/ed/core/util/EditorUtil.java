package org.jastadd.ed.core.util;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.ui.IEditorDescriptor;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.FileEditorInput;
import org.eclipse.ui.texteditor.ITextEditor;
import org.jastadd.ed.core.Activator;
import org.jastadd.ed.core.model.node.ITextViewNode;

public class EditorUtil {
	
	public static void selectInEditor(ITextViewNode node) {
		int startOffset = node.startSelectionOffset();
		int endOffset = node.endSelectionOffset();
		IFile file = node.enclosingFile();
		openFileWithSelection(file, startOffset, endOffset + 1);
	}
	
	protected static void openFileWithSelection(IFile file, int startOffset, int endOffset) {
		
		IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
		if (window == null)
			return;
		IWorkbenchPage page = window.getActivePage();
		if (page == null)
			return;
		if (file == null)
			return;
		IEditorDescriptor desc = PlatformUI.getWorkbench().
		        getEditorRegistry().getDefaultEditor(file.getName());
		IFileEditorInput fileInput = new FileEditorInput(file); 
		try {
			page.openEditor(fileInput, desc.getId());
		} catch (PartInitException e) {
			String message = "Opening of file failed!\n" + e.getMessage(); 
			IStatus status = new Status(IStatus.ERROR, 
					Activator.PLUGIN_ID, IStatus.ERROR, message, e);
			Activator.getDefault().getLog().log(status);
		}
		IEditorPart editorPart = page.findEditor(fileInput);
		if (editorPart instanceof ITextEditor) {
			ITextEditor textEditor = (ITextEditor) editorPart;
			textEditor.selectAndReveal(startOffset, endOffset-startOffset);
		}
		
		/* External file
		 * File fileToOpen = new File("externalfile.xml");
		if (fileToOpen.exists() && fileToOpen.isFile()) {
    		IFileStore fileStore = EFS.getLocalFileSystem().getStore(fileToOpen.toURI());
    		IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
 			try {
        		IDE.openEditorOnFileStore( page, fileStore );
    		} catch ( PartInitException e ) {
        		//Put your exception handler here if you wish to
    		}
		} else {
    		//Do something if the file does not exist
		}
		 */
	}
	
	/**
	 * Opens the file corresponding to the given compilation unit with a
	 * selection corresponding to the given line, column and length.
	 */
	/*
	protected static void openFile(ICompilationUnit unit, int line, int column,
			int length) {
		try {
			String pathName = unit.pathName();
			String relativeName = unit.relativeName();
			if (pathName == null || relativeName == null) 
				return;
			
			// Try to work as with resource
			if (pathName.equals(relativeName)) {
				IPath path = Path.fromOSString(pathName);
				IFile[] files = ResourcesPlugin.getWorkspace().getRoot().findFilesForLocation(path);
				for (ICompiler compiler : Activator.getRegisteredCompilers()) {
					if (files.length > 0 && compiler.canCompile(files[0])) {
						openEditor(new FileEditorInput(files[0]), line, column, length, FileInfoMap.buildFileInfo(files[0]));
						return;
					}
				}
			}
			
			IProject project = BuildUtil.getProject(unit);
			if (project == null)
				return;
			
			// Try to work as with class file 
			if (relativeName.endsWith(".class")) {
				openJavaSource(project, computeSourceName(unit), line, column, length);
				return;
			}
			
			// Try to work with source file paths 
			IStorage storage = null;
			
			IPath path = Path.fromOSString(pathName);
			File file = path.toFile();
			if (file.exists()) {
				storage = new LocalFileStorage(file);
			} else {
				IPath rootPath = path.removeTrailingSeparator();
				while (!rootPath.isEmpty() && !rootPath.toFile().exists()) {
					rootPath = rootPath.removeLastSegments(1).removeTrailingSeparator();
				}
				if (!rootPath.isEmpty() && rootPath.toFile().exists()) {
					IPath entryPath = path.removeFirstSegments(rootPath.segmentCount());
					try {
						storage = new ZipEntryStorage(new ZipFile(rootPath.toFile()), new ZipEntry(entryPath.toString()));
					} 
					catch(IOException e) {
						//logError(e, "Failed parsing ZIP entry");
					}
				}
			}
			
			if (storage != null)
				openEditor(new JastAddStorageEditorInput(project, storage), line, column, length, FileInfoMap.buildFileInfo(project, storage.getFullPath()));
		}
		catch(CoreException e) {
			//logCoreException(e);
		}
	}
	
	
	private static void openEditor(IEditorInput targetEditorInput,
			int line, int column, int length, FileInfo fileInfo)
			throws CoreException {
		IWorkbenchWindow window = PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow();
		IWorkbenchPage page = window.getActivePage();
		page.openEditor(targetEditorInput, JastAddJEditor.EDITOR_ID, true);
		IDocument targetDoc = FileInfoMap.fileInfoToDocument(fileInfo);
		if (targetDoc == null)
			return;
		int lineOffset = 0;
		try {
			lineOffset = targetDoc.getLineOffset(line - 1) + column - 1;
		} catch (BadLocationException e) {
		}
		IEditorPart targetEditorPart = page.findEditor(targetEditorInput);
		if (targetEditorPart instanceof ITextEditor) {
			ITextEditor textEditor = (ITextEditor) targetEditorPart;
			textEditor.selectAndReveal(lineOffset, length);
		}
	}
	*/
}
