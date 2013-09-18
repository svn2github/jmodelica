package org.jmodelica.util.logging;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.jmodelica.util.Problem;
import org.jmodelica.util.XMLUtil;

/**
 * XMLLogger converts the log into XML and output it to another logger.
 */
public class XMLLogger extends ModelicaLogger {
	
	private final ModelicaLogger logger;
	private State state = State.ACTIVE;
	
	/**
	 * Constructs a XMLLogger with the sub logger <code>logger</code>
	 * @param logger sub logger
	 */
	public XMLLogger(ModelicaLogger logger) {
		super(logger.getLevel());
		this.logger = logger;
		logger.write(Level.ERROR, "<compilation>\n");
	}

	@Override
	protected void write(Level level, String logMessage) {
		if (!getLevel().shouldLog(level))
			return;
		logger.write(level, XMLUtil.escape(logMessage));
	}
	@Override
	protected void write(Level level, Throwable throwable) {
		if (!getLevel().shouldLog(level))
			return;
		StringWriter str = new StringWriter();
		PrintWriter print = new PrintWriter(str);
		throwable.printStackTrace(print);
		String xmlTag = level == Level.ERROR ? "Exception" : "HandledException";
		logger.write(Level.ERROR, String.format(
				"<%s>\n" +
				"    <value name=\"kind\">%s</value>\n" +
				"    <value name=\"message\">%s</value>\n" +
				"    <value name=\"stacktrace\">\n%s</value>\n" +
				"</%1$s>",
				xmlTag,
				XMLUtil.escape(throwable.getClass().getName()),
				XMLUtil.escape(throwable.getMessage() == null ? "" : throwable.getMessage()),
				XMLUtil.escape(str.toString())
		));
	}
	
	@Override
	protected void write(Level level, Problem problem) {
		if (!getLevel().shouldLog(level))
			return;
		logger.write(level, String.format(
				"<%s>\n" +
				"    <value name=\"kind\">%s</value>\n" +
				"    <value name=\"file\">%s</value>\n" +
				"    <value name=\"line\">%d</value>\n" +
				"    <value name=\"column\">%d</value>\n" +
				"    <value name=\"message\">%s</value>\n" +
				"</%1$s>",
				XMLUtil.escape(Problem.capitalize(problem.severity())),
				XMLUtil.escape(problem.kind().toString().toLowerCase()),
				XMLUtil.escape(problem.fileName()),
				problem.beginLine(), problem.beginColumn(),
				XMLUtil.escape(problem.message())
		));
	}
	
	@Override
	public void close() {
		if (state == State.CLOSED)
			return;
		logger.write(Level.ERROR, "</compilation>");
		state = State.CLOSED;
		logger.close();
	}
	
	private static enum State{
		ACTIVE,
		CLOSED,
	}

}
