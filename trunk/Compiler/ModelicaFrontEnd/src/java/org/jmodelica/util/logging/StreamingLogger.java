package org.jmodelica.util.logging;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;

import org.jmodelica.util.Problem;
import org.jmodelica.util.exceptions.ModelicaException;

public class StreamingLogger extends ModelicaLogger {
	
	private final OutputStream stream;
	private State state = State.ACTIVE;
	private final boolean thisCreatedStream;
	
	/**
	 * Constructs a logger with log level <code>level</code> and
	 * writes to the file with the name <code>fileName</code>.
	 * 
	 * @param level log level of this logger
	 * @param fileName Name of file that should be written
	 * @throws FileNotFoundException thrown when invalid file name is supplied
	 */
	public StreamingLogger(Level level, String fileName) throws FileNotFoundException {
		this(level, new File(fileName));
	}
	
	/**
	 * Constructs a logger with log level <code>level</code> and
	 * writes to the file <code>file</code>.
	 * 
	 * @param level log level of this logger
	 * @param file File that should be written
	 * @throws FileNotFoundException thrown when invalid file is supplied
	 */
	public StreamingLogger(Level level, File file) throws FileNotFoundException {
		super(level);
		this.stream = new FileOutputStream(file);
		thisCreatedStream = true;
	}

	/**
	 * Constructs a logger with log level <code>level</code> and 
	 * writes log output to OutputStream <code>stream</code>
	 * 
	 * @param level log level of this logger
	 * @param stream OutputStream that the log is written to
	 */
	public StreamingLogger(Level level, OutputStream stream) {
		super(level);
		this.stream = stream;
		thisCreatedStream = false;
	}

	@Override
	public void close() {
		if (state == State.CLOSED)
			return;
		state = State.CLOSED;
		if (thisCreatedStream) {
			try {
				stream.close();
			} catch (IOException e) {}
		}
	}
	
	@Override
	protected void finalize() throws Throwable {
		close();
		super.finalize();
	}
	
	private static enum State{
		ACTIVE,
		CLOSED,
		EXCEPTION,
	}

	@Override
	protected void write(Level level, String logMessage) {
		if (!getLevel().shouldLog(level))
			return;
		if (state == State.EXCEPTION) {
			return;
		} else if (state == State.CLOSED) {
			System.err.println("Compiler is writing to closed logger!");
			state = State.EXCEPTION;
			return;
		}
		try {
			stream.write(logMessage.getBytes());
			stream.write('\n');
		} catch (IOException e) {
			state = State.EXCEPTION;
			System.err.println("Compiler logger failed to write." + e.getMessage() != null ? " " + e.getMessage() : "");
		}
	}
	
	@Override
	protected void write(Level level, Throwable throwable) {
		if (!getLevel().shouldLog(level))
			return;
		if (throwable instanceof ModelicaException) {
			write(level, throwable.getMessage());
		} else if (throwable instanceof FileNotFoundException) {
			write(level, "Could not find file: " + throwable.getMessage());
		} else if (throwable instanceof OutOfMemoryError) {
			write(level, "Out of memory. Please set the memory limit of the JVM higher.");
		} else {
			StringBuilder sb = new StringBuilder();
			sb.append("Unknown program error, " + throwable.getClass().getName());
			if (throwable.getMessage() != null)
				sb.append(": " + throwable.getMessage());
		}
		if (getLevel().shouldLog(Level.DEBUG)) {
			StringWriter str = new StringWriter();
			PrintWriter print = new PrintWriter(str);
			throwable.printStackTrace(print);
			write(level, str.toString());
		}
	}

	@Override
	protected void write(Level level, Problem problem) {
		if (!getLevel().shouldLog(level))
			return;
		write(level, problem.toString());
	}

}
