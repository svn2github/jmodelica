package org.jmodelica.ide.documentation.sync;

import java.util.ArrayList;

import org.eclipse.swt.widgets.Display;
import org.jastadd.ed.core.model.IASTChangeEvent;
import org.jastadd.ed.core.model.IASTChangeListener;

public class ASTCommunicationHandler implements IASTChangeListener {
	private IASTChangeListener myListener;
	private ArrayList<IASTChangeEvent> events = new ArrayList<IASTChangeEvent>();

	public ASTCommunicationHandler(IASTChangeListener myListener) {
		this.myListener = myListener;
	}

	@Override
	public synchronized void astChanged(IASTChangeEvent e) {
		events.add(e);
		notifyUISafe();
	}

	private synchronized IASTChangeEvent getEvent() {
		if (!events.isEmpty())
			return events.remove(0);
		return null;
	}

	private void notifyUISafe() {
		try {
			// Since we make changes to SWT/UI, we need this kind of
			// thread
			Display.getDefault().syncExec(new Runnable() {
				public void run() {
					try {
						IASTChangeEvent event = getEvent();
						if (event != null)
							myListener.astChanged(event);
					} catch (Exception e) {
						System.err
								.println("Documentation task handler thread generated exception! "
										+ e.getMessage());
						e.printStackTrace();
					}
				}
			});
		} catch (Exception e) {
			System.err.println("Documentation task generated exception!");
			e.printStackTrace();
		}
	}
}