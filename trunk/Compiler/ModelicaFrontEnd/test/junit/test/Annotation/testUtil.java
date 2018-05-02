package test.Annotation;
import static org.junit.Assert.fail;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.junit.Assert;

/**
 * Test utility methods 
 */
public class testUtil {
    /* ============= *
     *  Assertions.  *
     * ============= */

    /**
     * Asserts that the elements of two {@link Iterable}s are identical.
     * 
     * @param <T>
     *            The type of elements in the {@link Iterable}s.
     * @param baseMessage
     *            The base message to use when the assertion fails.
     * @param expected
     *            Iterable of the expected elements.
     * @param actual
     *            Iterable of the actual elements.
     */
    protected final <T extends Comparable<T>> void assertIdenticalSets(String baseMessage, Iterable<T> expected,
            Iterable<T> actual) {

        List<T> actualList = list(actual);

        List<T> missing = new ArrayList<T>();

        for (T element : expected) {
            if (!actualList.remove(element)) {
                missing.add(element);
            }
        }

        List<T> additional = new ArrayList<T>(actualList);
        if (additional.size() == 0 && missing.size() == 0) {
            return;
        }

        String add = additional.size() > 0 ? "\n    Should not be found: " + additional.toString() : "";
        String miss = missing.size() > 0 ? "\n    Should be found:    " + missing.toString() : "";
        Assert.fail(baseMessage + add + miss);
    }

    /**
     * Converts an {@link Iterable} to a {@link List}.
     * 
     * @param <T>
     *            The type of element in the iterable.
     * @param iterable
     *            The iterable which elements to put in the list.
     * @return
     *         a list containing all the elements in {@code iterable}.
     */
    protected <T> List<T> list(Iterable<T> iterable) {
        List<T> list = new ArrayList<T>();
        for (T element : iterable) {
            list.add(element);
        }
        return list;
    }

    /**
     * Asserts that the provided iterable is empty. If not, it gives an error
     * with a nice error message listing the remaining elements.
     * 
     * @param iterable iterable to check
     */
    public static final void assertEmpty(Iterable<?> iterable) {
        assertEmpty(iterable.iterator());
    }

    /**
     * Assert that the provided iterator is empty, If not, it gives an error
     * with a nice error message listing the remaining elements.
     * 
     * @param iterator iterator to check
     */
    public static final void assertEmpty(Iterator<?> iterator) {
        if (iterator.hasNext()) {
            StringBuilder sb = new StringBuilder();
            sb.append("Expecting empty iterator/collection, but got non-empty! List contains: ");
            int count = 0;
            int limit = 5;
            while (iterator.hasNext()) {
                count++;
                if (count > limit) {
                    int remainingCount = 0;
                    while (iterator.hasNext()) {
                        iterator.next();
                        remainingCount++;
                    }
                    sb.append(String.format(" and %d additional elements!", remainingCount));
                } else {
                    Object element = iterator.next();
                    if (count > 1) {
                        if (iterator.hasNext()) {
                            sb.append(", ");
                        } else {
                            sb.append(" and ");
                        }
                    }
                    sb.append("'");
                    sb.append(element);
                    sb.append("'");
                }
            }
            sb.append('.');
            fail(sb.toString());
        }
    }
}
