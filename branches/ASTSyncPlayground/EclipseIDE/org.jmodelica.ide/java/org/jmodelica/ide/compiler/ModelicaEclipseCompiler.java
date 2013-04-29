/*
    Copyright (C) 2009 Modelon AB

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
package org.jmodelica.ide.compiler;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.util.Arrays;
import java.util.Collection;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.jastadd.ed.core.ICompiler;
import org.jastadd.ed.core.model.node.IGlobalRootNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jmodelica.ide.IDEConstants;
import org.jmodelica.ide.helpers.Util;
import org.jmodelica.ide.sync.GlobalRootNode;
import org.jmodelica.ide.sync.LocalRootNode;
import org.jmodelica.ide.sync.ModelicaASTRegistry;
import org.jmodelica.modelica.compiler.BadDefinition;
import org.jmodelica.modelica.compiler.LibNode;
import org.jmodelica.modelica.compiler.ParserException;
import org.jmodelica.modelica.compiler.SourceRoot;
import org.jmodelica.modelica.compiler.StoredDefinition;
import org.jmodelica.modelica.parser.ModelicaParser;
import org.jmodelica.modelica.parser.ModelicaScanner;
import org.jmodelica.ide.error.CompileErrorReport;

import beaver.Parser;

public class ModelicaEclipseCompiler implements ICompiler {

	private final ModelicaParser parser = new ModelicaParser();
	private final ModelicaScanner scanner = new ModelicaScanner(System.in); // Dummy
																			// stream
	private final CompileErrorReport errorReport = new CompileErrorReport();

	public ModelicaEclipseCompiler() {
		super();
		parser.setReport(errorReport);
	}

	private IGlobalRootNode recursiveCompile(IGlobalRootNode gRoot,
			IContainer parent) {
		GlobalRootNode globalRoot = (GlobalRootNode) gRoot;
		try {
			IResource[] resources = parent.members();
			for (IResource resource : resources) {

				switch (resource.getType()) {
				case IResource.FOLDER:
					File dir = new File(resource.getRawLocation().toOSString());
					if (LibNode.isStructuredLib(dir)) {
						globalRoot.addPackageDirectory(dir);
					} else {
						recursiveCompile(globalRoot, (IFolder) resource);
					}
					break;

				case IResource.FILE:
					IFile file = (IFile) resource;
					if (Util.isModelicaFile(file)) {
						ILocalRootNode lroot = parseFile(file);
						globalRoot.addFile(lroot);
					}
					break;
				}
			}

		} catch (CoreException e) {
			e.printStackTrace();
		}

		return globalRoot;
	}

	private ILocalRootNode compileToAST(IDocument document,
			DirtyRegion dirtyRegion, IRegion region, IFile file) {
		if (file == null)
			return null;
		ILocalRootNode lRoot = parseFile(file);
		ModelicaASTRegistry.getInstance().doUpdate(file, lRoot);
		return lRoot;
	}

	public ILocalRootNode recompile(IDocument doc, IFile file) {
		return compileToAST(doc, null, null, file);
	}

	public ILocalRootNode recompile(String doc, IFile file) {
		return parseDoc(doc, file);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.jastadd.plugin.compiler.ICompiler#canCompile(org.eclipse.core.resources
	 * .IProject)
	 */
	public boolean canCompile(IProject project) {
		try {
			if (project != null && project.isOpen()
					&& project.isNatureEnabled(acceptedNatureID())) {
				return true;
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.jastadd.plugin.compiler.ICompiler#canCompile(org.eclipse.core.resources
	 * .IFile)
	 */
	public boolean canCompile(IFile file) {
		if (file == null)
			return false;
		for (String str : acceptedFileExtensions()) {
			if (file.getFileExtension() != null
					&& file.getFileExtension().equals(str)) {
				return canCompile(file.getProject());
			}
		}
		return false;
	}

	@Override
	public IGlobalRootNode compile(IProject project) {
		GlobalRootNode toReturn = new GlobalRootNode(project);
		return recursiveCompile(toReturn, project);
	}

	@Override
	public ILocalRootNode compile(IFile file, IDocument document) {
		return compileToAST(document, null, null, file);
	}

	@Override
	public ILocalRootNode compile(IFile file) {
		return parseFile(file);
	}

	private String acceptedNatureID() {
		return IDEConstants.NATURE_ID;
	}

	private Collection<String> acceptedFileExtensions() {
		return Arrays.asList(IDEConstants.ALL_FILE_EXTENSIONS);
	}

	/**
	 * Parse content and add to source root.
	 */
	private ILocalRootNode parseFile(IFile file) {
		ILocalRootNode toReturn;
		try {
			toReturn = parseFile(Util.fileReader(file), file, true);
		} catch (IOException e) {
			toReturn = new LocalRootNode(createBadDef(file));
		}
		return toReturn;
	}

	private ILocalRootNode parseFile(Reader reader, IFile file,
			boolean clearSemantic) {

		errorReport.setFile(file, clearSemantic);
		scanner.reset(reader);
		org.jmodelica.modelica.compiler.List<StoredDefinition> list = new org.jmodelica.modelica.compiler.List<StoredDefinition>();
		SourceRoot sRoot = null;
		try {
			sRoot = (SourceRoot) parser.parse(scanner);
			synchronized (sRoot.state()) {
				sRoot.setFormatting(scanner.getFormattingInfo());
			}
			int i = 0;
			for (StoredDefinition def : sRoot.getProgram()
					.getUnstructuredEntitys()) {
				StoredDefinition sd = createAnnotatedDefinition(def, file);
				System.err.println("compiler parsed new storeddef: "+sd.getNodeName()+":"+sd.outlineId());
				list.add(sd);
				i++;
			}
			if (i == 0) // for empty file
				list.add(createBadDef(file));
		} catch (Parser.Exception e) {
			list.add(createBadDef(file));
		} catch (ParserException e) {
			list.add(createBadDef(file));
		} catch (IOException e) {
			list.add(createBadDef(file));
		} finally {
			errorReport.cleanUp();
			if (sRoot != null)
				sRoot.forceRewrites();
			try {
				reader.close();
			} catch (IOException e) {
			}
		}
		if (list.getNumChild() > 1)
			System.err
					.println("PARSING OF FILE RESULTED IN MORE THAN 1 STOREDDEF BUT ONLY ONE WAS KEPT, NEED FIXING");
		LocalRootNode toReturn = new LocalRootNode(list.getChild(0));
		return toReturn;
	}

	private StoredDefinition createBadDef(IFile file) {
		return createAnnotatedDefinition(new BadDefinition(), file);
	}

	private StoredDefinition createAnnotatedDefinition(StoredDefinition def,
			IFile file) {
		def.setFile(file);
		def.setFileName(file.getRawLocation().toOSString());
		def.setLineBreakMap(scanner.getLineBreakMap());
		return def;
	}

	/**
	 * Compile and add AST from string.
	 * 
	 * @param doc
	 *            string to compile
	 * @param file
	 *            eclipse file handle. Used as a key to identify the resulting
	 *            StoredDefinition.
	 * @return this
	 */
	private ILocalRootNode parseDoc(String doc, IFile file) {
		return parseFile(new StringReader(doc), file, true);
	}

	private void parseDocs(String[] docs, IFile file) {
		for (String doc : docs)
			parseDoc(doc, file);
	}
}
