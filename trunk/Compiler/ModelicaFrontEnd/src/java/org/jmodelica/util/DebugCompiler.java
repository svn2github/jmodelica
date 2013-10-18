package org.jmodelica.util;

import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.TargetObject;
import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.ModelicaLogger;

@SuppressWarnings("serial")
public class DebugCompiler extends JFrame {

	private JTextArea code;
	private OutputHandler out;
	private JTextField className;
	
	private ModelicaCompiler mc;
    private TargetObject target;
	private File tempDir;
	private boolean deleteAll;

	public DebugCompiler() {
		super("Compile Modelica code snippet");
		Box page = new Box(BoxLayout.Y_AXIS);
		add(page);
		
		page.add(new JLabel("Code:"));
		code = new JTextArea("model Test\n\nend Test;", 15, 40);
		page.add(new JScrollPane(code));
		
		page.add(new JLabel("Output:"));
		JTextArea outText = new JTextArea("", 15, 40);
		page.add(new JScrollPane(outText));
		out = new OutputHandler(outText);
		
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
        target = new TargetObject("me", "1.0");
		tempDir = getTempDir();
		mc.setTempFileDir(tempDir);
	}
	
	public File getTempDir() {
		try {
			File tempDir = File.createTempFile("org.jmodelica.util.", "");
			tempDir.delete();
			if (tempDir.mkdir()) {
				tempDir.deleteOnExit();
				deleteAll = true;
				return tempDir;
			}
		} catch (IOException e) {
		} catch (SecurityException e) {
		}
		deleteAll = false;
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
				PrintStream fs = new PrintStream(file);
				fs.println(code.getText());
				fs.close();
				
				out.reset();
				mc.setLogger(out);
				mc.compileModel(new String[] { file.getAbsolutePath() }, name, target);
				
				if (deleteAll)
					for (File f : tempDir.listFiles())
						f.delete();
				else
					file.delete();
			} catch (Exception ex) {
				// TODO: Show in output area instead.
				JOptionPane.showMessageDialog(DebugCompiler.this, ex, "Exception thrown", JOptionPane.ERROR_MESSAGE);
				ex.printStackTrace();
				return;
			}
			out.debug("*** Compilation sucessful. ***");
		}

	}
	
	public class OutputHandler extends ModelicaLogger {
		
		private JTextArea target;

		public OutputHandler(JTextArea target) {
			super(Level.DEBUG);
			this.target = target;
		}

		public void reset() {
			target.setText("");
		}

		@Override
		protected void write(Level level, String message) {
			target.append(message + "\n");
		}

		@Override
		protected void write(Level level, Throwable throwable) {
			write(level, throwable.toString());
		}

		@Override
		protected void write(Level level, Problem problem) {
			write(level, problem.toString());
		}

		@Override
		public void close() {
		}

	}

}
