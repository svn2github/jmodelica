package org.jmodelica.util;

import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

import org.jmodelica.modelica.compiler.ModelicaCompiler;

public class DebugCompiler extends JFrame {

	private JTextArea code;
	private JTextField className;
	private ModelicaCompiler mc;
	private File tempDir;

	public DebugCompiler() {
		super("Compile Modelica code snippet");
		Box page = new Box(BoxLayout.Y_AXIS);
		add(page);
		
		code = new JTextArea("model Test\n\nend Test;", 15, 40);
		page.add(new JScrollPane(code));
		
		JPanel bottom = new JPanel(new FlowLayout(FlowLayout.RIGHT));
		page.add(bottom);
		
		className = new JTextField("Test", 20);
		bottom.add(className);
		
		JButton compile = new JButton("Compile");
		bottom.add(compile);
		compile.addActionListener(new CompileListener());
		
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		pack();
		
		mc = new ModelicaCompiler(new OptionRegistry());
		tempDir = getTempDir();
		mc.setTempFileDir(tempDir);
		tempDir.deleteOnExit();
	}
	
	public File getTempDir() {
		try {
			File tempDir = File.createTempFile("org.jmodelica.util.", "");
			tempDir.delete();
			if (tempDir.mkdir()) {
				tempDir.deleteOnExit();
				return tempDir;
			}
		} catch (IOException e) {
		} catch (SecurityException e) {
		}
		return new File(System.getProperty("java.io.tmpdir"));
	}
	
	public static void main(String[] args) {
		new DebugCompiler().setVisible(true);
	}

	public class CompileListener implements ActionListener {

		public void actionPerformed(ActionEvent e) {
			String name = className.getText();
			File file = new File(tempDir, name  + ".mo");
			try {
				PrintStream out = new PrintStream(file);
				out.println(code.getText());
				out.close();
				
				mc.compileModel(new String[] { file.getAbsolutePath() }, name);
				
				for (File f : tempDir.listFiles())
					f.delete();
			} catch (Exception ex) {
				JOptionPane.showMessageDialog(DebugCompiler.this, ex, "Exception thrown", JOptionPane.ERROR_MESSAGE);
				ex.printStackTrace();
				return;
			}
			JOptionPane.showMessageDialog(DebugCompiler.this, "Model compiled sucessfully", "Model compiled", JOptionPane.PLAIN_MESSAGE);
		}

	}

}
