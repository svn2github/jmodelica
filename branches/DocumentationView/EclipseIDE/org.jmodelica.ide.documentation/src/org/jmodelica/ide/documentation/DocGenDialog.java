package org.jmodelica.ide.documentation;

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import javax.swing.BorderFactory;
import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JTextField;
import javax.swing.LayoutStyle;
import javax.swing.SwingWorker;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import java.util.Random;

import org.jmodelica.modelica.compiler.ClassDecl;
import org.jmodelica.modelica.compiler.FullClassDecl;
import org.jmodelica.modelica.compiler.Program;

public class DocGenDialog extends JDialog implements ActionListener, PropertyChangeListener{

	public static final String COMMENT = "comment";
	public static final String INFORMATION = "information";
	public static final String IMPORTS = "imports";
	public static final String EXTENSIONS = "extensions";
	public static final String COMPONENTS = "components";
	public static final String EQUATIONS = "equations";
	public static final String REVISIONS = "revisions";
	private static final long serialVersionUID = 1L;
	private JButton btnCancel;
	private JButton btnOK;
	private JButton btnPath;
	private JCheckBox chkComment;
	private JCheckBox chkInfo;
	private JCheckBox chkImports;
	private JCheckBox chkExtensions;
	private JCheckBox chkComponents;
	private JCheckBox chkEquations;
	private JCheckBox chkRevisions;
	private JLabel lblProgress;
	private JPanel pnlHead;
	private JPanel pnlOptions;
	private JPanel pnlPath;
	private JPanel pnlProgress;
	private JProgressBar progressBar;
	private JTextField txtPath;
	private HashMap<String, Boolean> checkBoxes;
	private String rootPath;
	private FullClassDecl fcd;
	private Program program;
	private String footer;
	private Task task;
	private int progress;

	public DocGenDialog(Frame parent, FullClassDecl fcd, Program program, String footer) {
		super(parent, true);
		this.fcd = fcd;
		this.program = program;
		this.footer = footer;
		Dimension dim = Toolkit.getDefaultToolkit().getScreenSize();
		setLocation(dim.width/3, dim.height/3);
		checkBoxes = new HashMap<String, Boolean>();
		initComponents();
		progressBar.setVisible(false);
		setResizable(false);
		setSize(450,400);
		setVisible(true);
	}

	private void initComponents() {
		try {
			// Set cross-platform Java L&F (also called "Metal")
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} 
		catch (UnsupportedLookAndFeelException e) {
		}
		catch (ClassNotFoundException e) {
		}
		catch (InstantiationException e) {
		}
		catch (IllegalAccessException e) {
		}
		setTitle("Documentation Generation");
		pnlHead = new JPanel();
		pnlOptions = new JPanel();
		chkComment = new JCheckBox();
		chkComment.setSelected(true);
		chkInfo = new JCheckBox();
		chkInfo.setSelected(true);
		chkImports = new JCheckBox();
		chkImports.setSelected(true);
		chkExtensions = new JCheckBox();
		chkExtensions.setSelected(true);
		chkComponents = new JCheckBox();
		chkComponents.setSelected(true);
		chkEquations = new JCheckBox();
		chkRevisions = new JCheckBox();
		chkRevisions.setSelected(true);
		pnlPath = new JPanel();
		txtPath = new JTextField();
		btnPath = new JButton();
		pnlProgress = new JPanel();
		progressBar = new JProgressBar();
		progressBar.setMinimum(0);
		lblProgress = new JLabel();
		btnOK = new JButton();
		btnOK.setEnabled(false);
		btnCancel = new JButton();

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		pnlHead.setBorder(javax.swing.BorderFactory.createTitledBorder("Settings"));
		pnlOptions.setBorder(javax.swing.BorderFactory.createTitledBorder("Options"));
		chkComment.setText("Generate Comment");
		chkInfo.setText("Generate Information");
		chkImports.setText("Generate Imports");
		chkExtensions.setText("Generate Extensions");
		chkComponents.setText("Generate Components");
		chkEquations.setText("Generate Equations");
		chkRevisions.setText("Generate Revisions");
		GroupLayout jPanel2Layout = new GroupLayout(pnlOptions);
		pnlOptions.setLayout(jPanel2Layout);
		jPanel2Layout.setHorizontalGroup(
				jPanel2Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel2Layout.createSequentialGroup()
						.addGap(46, 46, 46)
						.addGroup(jPanel2Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
								.addComponent(chkRevisions)
								.addComponent(chkEquations)
								.addComponent(chkComponents)
								.addComponent(chkExtensions)
								.addComponent(chkImports)
								.addComponent(chkInfo)
								.addComponent(chkComment))
								.addContainerGap(191, Short.MAX_VALUE))
				);
		jPanel2Layout.setVerticalGroup(
				jPanel2Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel2Layout.createSequentialGroup()
						.addComponent(chkComment)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkInfo)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkImports)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkExtensions)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkComponents)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkEquations)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(chkRevisions)
						.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
				);

		pnlPath.setBorder(BorderFactory.createTitledBorder("Target"));
		txtPath.setEnabled(false);
		btnPath.setText("Choose Folder");
		GroupLayout jPanel3Layout = new GroupLayout(pnlPath);
		pnlPath.setLayout(jPanel3Layout);
		jPanel3Layout.setHorizontalGroup(
				jPanel3Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel3Layout.createSequentialGroup()
						.addContainerGap()
						.addComponent(txtPath, GroupLayout.PREFERRED_SIZE, 225, GroupLayout.PREFERRED_SIZE)
						.addPreferredGap(LayoutStyle.ComponentPlacement.UNRELATED)
						.addComponent(btnPath, GroupLayout.DEFAULT_SIZE, 113, Short.MAX_VALUE)
						.addGap(8, 8, 8))
				);
		jPanel3Layout.setVerticalGroup(
				jPanel3Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel3Layout.createSequentialGroup()
						.addGroup(jPanel3Layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
								.addComponent(txtPath, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addComponent(btnPath))
								.addContainerGap(6, Short.MAX_VALUE))
				);
		btnOK.addActionListener(this);
		btnCancel.addActionListener(this);
		btnPath.addActionListener(this);
		GroupLayout jPanel4Layout = new GroupLayout(pnlProgress);
		pnlProgress.setLayout(jPanel4Layout);
		jPanel4Layout.setHorizontalGroup(
				jPanel4Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel4Layout.createSequentialGroup()
						.addContainerGap()
						.addGroup(jPanel4Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
								.addComponent(lblProgress, GroupLayout.DEFAULT_SIZE, 362, Short.MAX_VALUE)
								.addComponent(progressBar, GroupLayout.DEFAULT_SIZE, 362, Short.MAX_VALUE))
								.addContainerGap())
				);
		jPanel4Layout.setVerticalGroup(
				jPanel4Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel4Layout.createSequentialGroup()
						.addComponent(lblProgress, GroupLayout.PREFERRED_SIZE, 22, GroupLayout.PREFERRED_SIZE)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(progressBar, GroupLayout.PREFERRED_SIZE, 26, GroupLayout.PREFERRED_SIZE)
						.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
				);

		GroupLayout jPanel1Layout = new GroupLayout(pnlHead);
		pnlHead.setLayout(jPanel1Layout);
		jPanel1Layout.setHorizontalGroup(
				jPanel1Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel1Layout.createSequentialGroup()
						.addContainerGap()
						.addGroup(jPanel1Layout.createParallelGroup(GroupLayout.Alignment.TRAILING)
								.addComponent(pnlProgress, GroupLayout.Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
								.addGroup(GroupLayout.Alignment.LEADING, jPanel1Layout.createParallelGroup(GroupLayout.Alignment.TRAILING, false)
										.addComponent(pnlPath, GroupLayout.Alignment.LEADING, 0, 382, Short.MAX_VALUE)
										.addComponent(pnlOptions, GroupLayout.Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
										.addContainerGap())
				);
		jPanel1Layout.setVerticalGroup(
				jPanel1Layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(jPanel1Layout.createSequentialGroup()
						.addContainerGap()
						.addComponent(pnlOptions, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(pnlPath, GroupLayout.PREFERRED_SIZE, 59, GroupLayout.PREFERRED_SIZE)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addComponent(pnlProgress, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
				);

		btnOK.setText("OK");

		btnCancel.setText("Cancel");

		GroupLayout layout = new GroupLayout(getContentPane());
		getContentPane().setLayout(layout);
		layout.setHorizontalGroup(
				layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(layout.createSequentialGroup()
						.addContainerGap()
						.addGroup(layout.createParallelGroup(GroupLayout.Alignment.TRAILING)
								.addComponent(pnlHead, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addGroup(layout.createSequentialGroup()
										.addComponent(btnOK)
										.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
										.addComponent(btnCancel)))
										.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
				);
		layout.setVerticalGroup(
				layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addGroup(layout.createSequentialGroup()
						.addContainerGap()
						.addComponent(pnlHead, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
						.addPreferredGap(LayoutStyle.ComponentPlacement.RELATED)
						.addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
								.addComponent(btnOK)
								.addComponent(btnCancel))
								.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
				);

		pack();}
	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == btnPath){
			JFileChooser fc = new JFileChooser();
			fc.setDialogTitle("Documentation generation - Specify directory");
			fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
			if (fc.showOpenDialog(null) != JFileChooser.APPROVE_OPTION){

			}else{
				rootPath = fc.getCurrentDirectory().getAbsolutePath().replace("\\","/") + "/" + fc.getSelectedFile().getName() + "/";
				txtPath.setText(rootPath);
				btnOK.setEnabled(true);
			}
		}else if(e.getSource() == btnOK){
			checkBoxes.put(COMMENT, chkComment.isSelected());
			checkBoxes.put(INFORMATION, chkInfo.isSelected());
			checkBoxes.put(IMPORTS, chkImports.isSelected());
			checkBoxes.put(EXTENSIONS, chkExtensions.isSelected());
			checkBoxes.put(COMPONENTS, chkComponents.isSelected());
			checkBoxes.put(EQUATIONS, chkEquations.isSelected());
			checkBoxes.put(REVISIONS, chkRevisions.isSelected());
			String path = rootPath + fcd.getName().getID();
			String libName = fcd.getName().getID();

			if ((new File(path)).exists()) {
				if (JOptionPane.showConfirmDialog(null, "This folder already exist. Would you like to overwrite existing files?") != JOptionPane.YES_OPTION) return;
			}else{
				boolean success = (new File(path)).mkdirs();
				if (!success) {
					JOptionPane.showMessageDialog(null, "Unable to create a new directory", "Error", JOptionPane.ERROR_MESSAGE, null);
					return;
				}
			}
			ArrayList<ClassDecl> children = new ArrayList<ClassDecl>();
			collectChildren(fcd, children);

			setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
			int nbrChildren = children.size() + 1;
			task = new Task();
			task.addPropertyChangeListener(this);
			task.execute();
			String code = Generator.genDocumentation(fcd, program, path + "\\", footer, "Unknown Class Decl", rootPath, libName, checkBoxes);
			progress += progress + 100/nbrChildren;
			try{
				FileWriter fstream = new FileWriter(path + "\\index.html");
				BufferedWriter out = new BufferedWriter(fstream);
				out.write(code);
				out.close();
			}catch (Exception ex){
				JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
			}
			for (ClassDecl child : children){
				progress += 100/nbrChildren;
				String newPath = rootPath + "/" + Generator.getFullPath(child).replace(".", "/");
				(new File(newPath)).mkdirs();
				try{
					FileWriter fstream = new FileWriter(newPath + "\\index.html");
					BufferedWriter out = new BufferedWriter(fstream);
					out.write(Generator.genDocumentation(child, program, newPath + "/", footer, "Unknown class decl", rootPath, libName, checkBoxes));
					out.close();
				}catch (Exception ex){
					JOptionPane.showMessageDialog(null, "Unable to save to file", "Error", JOptionPane.ERROR_MESSAGE, null);
				}
			}

			StringBuilder generatedDocs = new StringBuilder("Documentation was successfully generated for the following classes:");
			generatedDocs.append("\n" + libName);
			for (ClassDecl cd : children){
				generatedDocs.append("\n" + cd.name());
			}
			JOptionPane.showMessageDialog(null, generatedDocs.toString(), "Generation Complete", JOptionPane.INFORMATION_MESSAGE, null);
			setVisible(false); 
			dispose();
		}else if(e.getSource() == btnCancel){
			setVisible(false); 
			dispose();
		}
	}
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
	class Task extends SwingWorker<Void, Void> {
		public Task() {
			progress = 0;
			progressBar.setMinimum(0);
			progressBar.setMaximum(100);		
		}

		/*
		 * Main task. Executed in background thread.
		 */
		@Override
		public Void doInBackground() {
			Random random = new Random();
			int progress = 0;
			//Initialize progress property.
			setProgress(0);
			//Sleep for at least one second to simulate "startup".
			try {
				Thread.sleep(100 + random.nextInt(200));
			} catch (InterruptedException ignore) {}
			while (progress < 1000) {
				//Sleep for up to one second.
				try {
					Thread.sleep(random.nextInt(50));
				} catch (InterruptedException ignore) {}
				//Make random progress.
				progress += random.nextInt(10);
				setProgress(Math.min(progress, 100));
			}
			return null;
			//            //Initialize progress property.
			//            setProgress(0);
			//            while (progress < 100) {
			//                //Sleep for up to one second.
			//                try {
			//                    Thread.sleep(50);
			//                } catch (InterruptedException ignore) {}
			//                //Make random progress.
			//                //progress += random.nextInt(10);
			//               // System.out.println("progress from doinbackground: " + progress);
			//                setProgress(++progress);
			//            }
			//            setProgress(100);
			//            lblProgress.setText("Generating documentation.. Done");
			//            return null;
		}

		/*
		 * Executed in event dispatch thread
		 */
		public void done() {
			Toolkit.getDefaultToolkit().beep();
		}
	}

	@Override
	public void propertyChange(PropertyChangeEvent evt) {
		if ("progress" == evt.getPropertyName()) {
			int progress = (Integer) evt.getNewValue();
			//System.out.println("progress from propertychange: " + progress);
			progressBar.setIndeterminate(false);
			progressBar.setValue(progress);
		}
	}
}
