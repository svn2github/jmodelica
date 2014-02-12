package org.jmodelica.util;

import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

import org.jmodelica.modelica.compiler.ModelicaCompiler;
import org.jmodelica.modelica.compiler.ModelicaCompiler.TargetObject;
import org.jmodelica.util.exceptions.CompilerException;
import org.jmodelica.util.logging.Level;
import org.jmodelica.util.logging.ModelicaLogger;

@SuppressWarnings("serial")
public class DebugCompiler extends JFrame {

	private JTextArea code;
	private JTextField className;
	
	private ModelicaCompiler mc;
    private JComboBox target;
	private File tempDir;
	private boolean deleteAll;
    private JTextArea outText;
    private JComboBox level;

	public DebugCompiler() {
		super("Compile Modelica code snippet");
		Box page = new Box(BoxLayout.Y_AXIS);
		add(page);
		
		page.add(new JLabel("Code:"));
		code = new JTextArea("model Test\n\nend Test;", 20, 70);
		page.add(new JScrollPane(code));
		
		page.add(new JLabel("Output:"));
		outText = new JTextArea("", 20, 70);
		page.add(new JScrollPane(outText));
		
		JPanel bottom = new JPanel(new FlowLayout(FlowLayout.RIGHT));
		page.add(bottom);
        
        bottom.add(new JLabel("Log level:"));
        level = new JComboBox(Level.values());
        level.setSelectedItem(Level.DEBUG);
        bottom.add(level);
		
		bottom.add(new JLabel("Target:"));
		target = new JComboBox(TargetObject.values());
        bottom.add(target);
		
        bottom.add(new JLabel("Class to compile:"));
		className = new JTextField("Test", 20);
		bottom.add(className);
		
		JButton compile = new JButton("Compile");
		bottom.add(compile);
		compile.addActionListener(new CompileListener());
		
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		pack();
		
		mc = new ModelicaCompiler(ModelicaCompiler.createOptions());
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
		    new CompilationThread(className.getText(), code.getText()).start();
		}

	}
	
	public class CompilationThread extends Thread {
	    
        private String name;
        private String code;
        
        public CompilationThread(String name, String code) {
            this.name = name;
            this.code = code;
        }

        public void run() {
            File file = new File(tempDir, name  + ".mo");
            Level lv = (Level) level.getSelectedItem();
            OutputHandler out = new OutputHandler(outText, lv);
            outText.setText("");
            try {
                PrintStream fs = new PrintStream(file);
                fs.println(code);
                fs.close();
                
                mc.setLogger(out);
                TargetObject targ = (TargetObject) target.getSelectedItem();
                mc.compileModel(new String[] { file.getAbsolutePath() }, name, targ);
            } catch (Exception ex) {
                out.writeException(ex);
                return;
            } finally {
                try {
                    if (deleteAll)
                        for (File f : tempDir.listFiles())
                            f.delete();
                    else
                        file.delete();
                } catch (Exception ex) {}
            }
            out.info("*** Compilation sucessful. ***");
        }
	    
	}
	
	public class OutputHandler extends ModelicaLogger {
		
		private JTextArea target;

		public OutputHandler(JTextArea target, Level level) {
			super(level);
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

        protected void writeException(Exception ex) {
            if (ex instanceof CompilerException) {
                write(Level.ERROR, ex);
            } else {
                ByteArrayOutputStream buf = new ByteArrayOutputStream(512);
                ex.printStackTrace(new PrintStream(buf));
                write(Level.ERROR, buf.toString());
            }
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
