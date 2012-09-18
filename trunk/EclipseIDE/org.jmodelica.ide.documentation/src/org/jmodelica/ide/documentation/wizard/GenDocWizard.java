package org.jmodelica.ide.documentation.wizard;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import javax.swing.JOptionPane;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.dialogs.ProgressMonitorDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.ui.PlatformUI;
import org.jmodelica.ide.documentation.Generator;
import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.SourceRoot;

public class GenDocWizard extends Wizard {
	private String footer;
	private FullClassDecl fcd;
	private GenDocWizardPage pageOne;
	public static final String PAGE_ONE = "PAGE_ONE";
	private ArrayList<ClassDecl> children;
	private String path;
	private String rootPath;
	private String libName;
	private SourceRoot sourceRoot;
	private HashMap<String, Boolean> checkBoxes;
	public static final String COMMENT = "comment";
	public static final String INFORMATION = "information";
	public static final String IMPORTS = "imports";
	public static final String EXTENSIONS = "extensions";
	public static final String COMPONENTS = "components";
	public static final String EQUATIONS = "equations";
	public static final String REVISIONS = "revisions";

	/**
	 * 
	 * @param fcd The full class declaration that is at the root of what is to be generated
	 * @param sourceRoot The source root associated with the full class declaration. Needed to determine restrictions for fcds and for class lookups
	 * @param footer Optional footer at the end of the HTML document
	 */
	public GenDocWizard(FullClassDecl fcd, SourceRoot sourceRoot, String footer){
		super();
		this.setWindowTitle("Documentation Generation");
		this.fcd = fcd;
		this.sourceRoot = sourceRoot;
		this.footer = footer;

	}
	/**
	 * Add an instance of GenDocWizardPageOne to the wizard
	 */
	public void addPages() {
		pageOne = new GenDocWizardPage(PAGE_ONE);
		addPage(pageOne);

	}
	/**
	 * Does the following:
	 * Collect the wizard information (inclusions and path).
	 * Start up a progress monitor.
	 * Generates documentation for the full class declaration
	 * Recursively generates documentation for all the classes in the full class declaration.
	 * Called when the user presses 'finish' in the wizard.
	 */
	public boolean performFinish() {
		rootPath = ((GenDocWizardPage)getPage(GenDocWizard.PAGE_ONE)).getPath();
		checkBoxes = ((GenDocWizardPage)getPage(GenDocWizard.PAGE_ONE)).getCheckBoxes();
		path = rootPath + fcd.getName().getID();
		libName = fcd.getName().getID();
		if (!(new File(path)).exists()) {
			if(!(new File(path)).mkdirs()){
				JOptionPane.showMessageDialog(null, "Unable to create a new directory. Aborting", "Error", JOptionPane.ERROR_MESSAGE, null);
				return true;
			}
		}
		children = new ArrayList<ClassDecl>();
		collectChildren(fcd, children);
		ProgressMonitorDialog dialog = new ProgressMonitorDialog(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell());
		dialog.setCancelable(true);

		try {
			dialog.run(true, true, new IRunnableWithProgress(){ 
				public void run(IProgressMonitor monitor) { 
					monitor.beginTask("Generating documentation...", children.size() + 1); 
					monitor.subTask(libName);
					monitor.worked(1);
					String code = Generator.genDocumentation(fcd, sourceRoot, path + "\\", footer, "Unknown Class Decl", rootPath, libName, checkBoxes);
					try{
						FileWriter fstream = new FileWriter(path + "\\index.html");
						BufferedWriter out = new BufferedWriter(fstream);
						out.write(code);
						out.close();
					}catch (Exception ex){
						JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
					}
					monitor.worked(1);
					for (ClassDecl cd : children){
						if (monitor.isCanceled()){
							monitor.done();
							return;
						}
						monitor.subTask(cd.name());
						String newPath = rootPath + "/" + Generator.getFullPath(cd).replace(".", "/");
						(new File(newPath)).mkdirs();
						try{
							FileWriter fstream = new FileWriter(newPath + "\\index.html");
							BufferedWriter out = new BufferedWriter(fstream);
							out.write(Generator.genDocumentation(cd, sourceRoot, newPath + "/", footer, "Unknown class decl", rootPath, libName, checkBoxes));
							out.close();
						}catch (Exception ex){
							JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
						}
						monitor.worked(1);
					}
					monitor.done(); 
				} 
			});
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		} catch (InterruptedException e) {
		}
		return true;
	}

	/**
	 * Saves all the classes found in the full class declaration fcd into children
	 * @param fcd
	 * @param children
	 */
	private void collectChildren(FullClassDecl fcd, ArrayList<ClassDecl> children) {
		if (fcd.classes() == null || fcd.classes().size() == 0) return;
		for (ClassDecl child : fcd.classes()){
			if (!children.contains(child)){
				children.add(child);
				if (child instanceof FullClassDecl){
					collectChildren((FullClassDecl) child, children);
				}
			}
		}
	}

	/**
	 * Returns whether the wizard can be finished, used to enable/disable the finish button
	 */
	@Override
	public boolean canFinish(){
		return getPage(PAGE_ONE).isPageComplete();
	}
}
