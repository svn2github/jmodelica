package org.jmodelica.util.logging;

import org.jmodelica.util.Problem;

/**
 * TeeLogger splits the incoming log and writes it to several outher logs.
 */
public class TeeLogger extends ModelicaLogger {
	
	private ModelicaLogger[] loggers;
	
	/**
	 * Constructs a TeeLogger, takes a list of sub loggers that the log
	 * will be written to.
	 * @param loggers a list of sub loggers
	 */
	public TeeLogger(ModelicaLogger[] loggers) {
		super(calculateLevel(loggers));
		this.loggers = loggers;
	}

	@Override
	public void close() {
		for (ModelicaLogger logger : loggers)
			logger.close();
	}
	
	private static Level calculateLevel(ModelicaLogger[] loggers) {
		Level level = Level.ERROR;
		for (ModelicaLogger logger : loggers)
			level = level.union(logger.getLevel());
		return level;
	}

	@Override
	protected void write(Level level, String logMessage) {
		for (ModelicaLogger logger : loggers)
			logger.write(level, logMessage);
	}

	@Override
	protected void write(Level level, Throwable throwable) {
		for (ModelicaLogger logger : loggers)
			logger.write(level, throwable);
	}

	@Override
	protected void write(Level level, Problem problem) {
		for (ModelicaLogger logger : loggers)
			logger.write(level, problem);
	}
	
}
