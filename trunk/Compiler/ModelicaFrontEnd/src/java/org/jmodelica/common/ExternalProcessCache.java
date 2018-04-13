package org.jmodelica.common;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;

import org.jmodelica.util.EnvironmentUtils;
import org.jmodelica.util.OptionRegistry;
import org.jmodelica.util.ccompiler.CCompilerDelegator;
import org.jmodelica.util.exceptions.CcodeCompilationException;
import org.jmodelica.util.logging.ModelicaLogger;
import org.jmodelica.util.values.ConstantEvaluationException;

public class ExternalProcessCache<K extends ExternalProcessCache.Variable<V, T>, V extends ExternalProcessCache.Value,
                        T extends ExternalProcessCache.Type<V>, E extends ExternalProcessCache.External<K>> {

    public interface Compiler<K, E extends External<K>> extends ILogContainer {
        public String compileExternal(E ext) throws FileNotFoundException, CcodeCompilationException;

        public CCompilerDelegator getCCompiler();
    }

    public interface External<K> {
        public String getName();

        public boolean shouldCacheProcess();

        public OptionRegistry myOptions();

        public String libraryDirectory();

        public K cachedExternalObject();

        public Iterable<K> externalObjectsToSerialize();

        public Iterable<K> functionArgsToSerialize();

        public Iterable<K> varsToDeserialize();
    }

    public interface Variable<V extends Value, T extends Type<V>> {
        public V ceval();

        public T type();
    }

    public interface Value {
        public String getMarkedExternalObject();

        public void serialize(BufferedWriter out) throws IOException;
    }

    public interface Type<V extends Value> {
        public V deserialize(ProcessCommunicator<V, ? extends Type<V>> processCommunicator) throws IOException;
    }

    /**
     * Maps external functions names to compiled executables.
     */
    private Map<String, ExternalFunction> cachedExternals = new HashMap<String, ExternalFunction>();

    /**
     * Keeps track of all living processes, least recently used first.
     */
    private LinkedHashSet<ExternalFunction> livingCachedExternals = new LinkedHashSet<ExternalFunction>();

    private Compiler<K, E> mc;

    public ExternalProcessCache(Compiler<K, E> mc) {
        this.mc = mc;
    }

    ModelicaLogger log() {
        return mc.log();
    }

    /**
     * If there is no executable corresponding to <code>ext</code>, create one.
     */
    public ExternalFunction getExternalFunction(E ext) {
        ExternalFunction ef = cachedExternals.get(ext.getName());
        if (ef == null) {
            if (mc == null) {
                return failedEval(ext, "Missing ModelicaCompiler", false);
            }
            try {
                String executable = mc.compileExternal(ext);
                if (ext.shouldCacheProcess()) {
                    ef = new MappedExternalFunction(ext, executable);
                } else {
                    ef = new CompiledExternalFunction(ext, executable);
                }
                mc.log().debug("Succesfully compiled external function '" + ext.getName() + "' to executable '"
                        + executable + "' code for evaluation");
            } catch (FileNotFoundException e) {
                ef = failedEval(ext, "c-code generation failed '" + e.getMessage() + "'", true);
                mc.log().debug(ef.getMessage());
            } catch (CcodeCompilationException e) {
                ef = failedEval(ext, "c-code compilation failed '" + e.getMessage() + "'", true);
                mc.log().debug(ef.getMessage());
                e.printStackTrace(new PrintStream(mc.log().debugStream()));
            }
            cachedExternals.put(ext.getName(), ef);
        }
        return ef;
    }

    /**
     * Remove executables compiled by the constant evaluation framework.
     */
    public void removeExternalFunctions() {
        for (ExternalFunction ef : cachedExternals.values()) {
            ef.remove();
        }
        cachedExternals.clear();
    }

    /**
     * Kill cached processes
     */
    public void destroyProcesses(int externalEvaluation) {
        for (ExternalFunction ef : new ArrayList<ExternalFunction>(livingCachedExternals)) {
            ef.destroyProcess(externalEvaluation);
        }
    }

    public void tearDown(int externalEvaluation) {
        destroyProcesses(externalEvaluation);
        removeExternalFunctions();
    }

    public ExternalFunction failedEval(External<?> ext, String msg, boolean log) {
        return new FailedExternalFunction(failedEvalMsg(ext.getName(), msg), log);
    }

    public static String failedEvalMsg(String name, String msg) {
        return "Failed to evaluate external function '" + name + "', " + msg;
    }

    /**
     * Represents an external function that can be evaluated using
     * {@link ExternalFunction.evaluate}.
     */
    public abstract class ExternalFunction {

        public ExternalFunction() {
        }

        public abstract int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException;

        public abstract void destroyProcess(int timeout);

        public abstract void remove();

        public abstract String getMessage();
    }

    private class FailedExternalFunction extends ExternalFunction {
        private String msg;
        private boolean log;

        public FailedExternalFunction(String msg, boolean log) {
            this.msg = msg;
            this.log = log;
        }

        public String getMessage() {
            return msg;
        }

        @Override
        public int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException {
            if (log) {
                log().debug("Evaluating failed external function: " + ext.getName());
            }
            throw new ConstantEvaluationException(null, getMessage());
        }

        @Override
        public void destroyProcess(int timeout) {
            // Do nothing.
        }

        @Override
        public void remove() {
            // Do nothing.
        }
    }

    /**
     * Represents an external function that has been compiled successfully.
     */
    private class CompiledExternalFunction extends ExternalFunction {
        protected String executable;
        protected ProcessBuilder processBuilder;
        private String msg;

        public CompiledExternalFunction(External<K> ext, String executable) {
            this.executable = executable;
            this.processBuilder = createProcessBuilder(ext);
            this.msg = "Succesfully compiled external function '" + ext.getName() + "'";
        }

        public String getMessage() {
            return msg;
        }

        protected ProcessCommunicator<V, T> createProcessCommunicator(External<K> ext) throws IOException {
            return new ProcessCommunicator<V, T>(mc, processBuilder.start());
        }

        @Override
        public int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException {
            log().debug("Evaluating compiled external function: " + ext.getName());
            ProcessCommunicator<V, T> com = null;
            try {
                com = createProcessCommunicator(ext);
                setup(ext, values, timeout, com);
                evaluate(ext, values, timeout, com);
                return teardown(timeout, com);
            } finally {
                if (com != null) {
                    com.destroy();
                }
            }
        }

        public void setup(External<K> ext, Map<K, V> values, int timeout, ProcessCommunicator<V, T> com)
                throws IOException {
            com.startTimer(timeout);
            com.accept("START");
            for (K eo : ext.externalObjectsToSerialize()) {
                com.put(values.containsKey(eo) ? values.get(eo) : eo.ceval(), eo.type());
            }
            com.accept("READY");
            com.cancelTimer();
        }

        public void evaluate(External<K> ext, Map<K, V> values, int timeout, ProcessCommunicator<V, T> com)
                throws IOException {
            com.startTimer(timeout);
            com.check("EVAL");

            for (K arg : ext.functionArgsToSerialize()) {
                com.put(values.containsKey(arg) ? values.get(arg) : arg.ceval(), arg.type());
            }
            com.accept("CALC");
            com.accept("DONE");
            for (K cvd : ext.varsToDeserialize())
                values.put(cvd, com.get(cvd.type()));
            com.accept("READY");
            com.cancelTimer();
        }

        public int teardown(int timeout, ProcessCommunicator<V, T> com) throws IOException {
            com.startTimer(timeout);
            com.check("EXIT");
            com.accept("END");
            int result = com.end();
            com.cancelTimer();
            // log().debug("SUCCESS TEARDOWN");
            return result;
        }

        @Override
        public void destroyProcess(int timeout) {

        }

        @Override
        public void remove() {
            new File(executable).delete();
        }

        private ProcessBuilder createProcessBuilder(External<K> ext) {
            ProcessBuilder pb = new ProcessBuilder(executable);
            Map<String, String> env = pb.environment();
            if (env.keySet().contains("Path")) {
                env.put("PATH", env.get("Path"));
                env.remove("Path");
            }
            pb.redirectErrorStream(true);
            if (ext.libraryDirectory() != null) {
                // Update environment in case of shared library
                String platform = CCompilerDelegator.reduceBits(EnvironmentUtils.getJavaPlatform(),
                        mc.getCCompiler().getTargetPlatforms());
                File f = new File(ext.libraryDirectory(), platform);
                String libLoc = f.isDirectory() ? f.getPath() : ext.libraryDirectory();
                appendPath(env, libLoc, platform);
            }
            return pb;
        }

        /**
         * Append a library location <code>libLoc</code> to the path variable in
         * environment <code>env</code>.
         */
        private void appendPath(Map<String, String> env, String libLoc, String platform) {
            String sep = platform.startsWith("win") ? ";" : ":";
            String var = platform.startsWith("win") ? "PATH" : "LD_LIBRARY_PATH";
            String res = env.get(var);
            if (res == null)
                res = libLoc;
            else
                res = res + sep + libLoc;
            env.put(var, res);
        }
    }

    /**
     * A CompiledExternalFunction which can cache several processes with external
     * object constructor only called once.
     */
    private class MappedExternalFunction extends CompiledExternalFunction {

        private Map<String, ExternalFunction> lives = new HashMap<>();

        private final int externalConstantEvaluationMaxProc;

        public MappedExternalFunction(External<K> ext, String executable) {
            super(ext, executable);
            externalConstantEvaluationMaxProc = ext.myOptions()
                    .getIntegerOption("external_constant_evaluation_max_proc");
        }

        /**
         * Find a LiveExternalFunction based on the external object of this external
         * function. Start a new process if not up already. Failure to set up (call
         * constructor) will cache and return a Failed external function.
         */
        private ExternalFunction getActual(External<K> ext, Map<K, V> values, int timeout) {
            Variable<V, T> cvd = ext.cachedExternalObject();
            String name = cvd == null ? "" : cvd.ceval().getMarkedExternalObject();
            ExternalFunction ef = lives.get(name);
            if (ef == null) {
                LiveExternalFunction lef = new LiveExternalFunction();
                try {
                    lef.ready(ext, values, timeout);
                    ef = lef;
                } catch (IOException e) {
                    lef.destroyProcess(timeout);
                    ef = failedEval(ext, " error starting process '" + e.getMessage() + "'", true);
                } catch (ConstantEvaluationException e) {
                    lef.destroyProcess(timeout);
                    ef = failedEval(ext, " error starting process '" + e.getMessage() + "'", true);
                }
                lives.put(name, ef);
            }
            return ef;
        }

        @Override
        public int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException {
            return getActual(ext, values, timeout).evaluate(ext, values, timeout);
        }

        @Override
        public void destroyProcess(int timeout) {
            for (ExternalFunction ef : lives.values()) {
                ef.destroyProcess(timeout);
            }
            lives.clear();
        }

        /**
         * Represents a (possible) living external function process.
         */
        private class LiveExternalFunction extends ExternalFunction {

            protected ProcessCommunicator<V, T> com;

            public LiveExternalFunction() {
                super();
            }

            public String getMessage() {
                return MappedExternalFunction.this.getMessage();
            }

            @Override
            public int evaluate(External<K> ext, Map<K, V> values, int timeout) throws IOException {
                log().debug("Evaluating live external function: " + ext.getName());
                try {
                    ready(ext, values, timeout);
                    MappedExternalFunction.this.evaluate(ext, values, timeout, com);
                } catch (ProcessCommunicator.AbortConstantEvaluationException e) {

                } catch (ConstantEvaluationException e) {
                    destroyProcess(timeout);
                    throw e;
                } catch (IOException e) {
                    destroyProcess(timeout);
                    throw e;
                }
                return 0;
            }

            /**
             * Make sure process is ready for evaluation call.
             */
            protected void ready(External<K> ext, Map<K, V> values, int timeout) throws IOException {
                if (com == null) {
                    // Start process if not live.
                    com = createProcessCommunicator(ext);
                    // Send external object constructor inputs
                    MappedExternalFunction.this.setup(ext, values, timeout, com);
                    log().debug("Setup live external function: " + ext.getName());
                }

                // Mark as most recently used
                livingCachedExternals.remove(this);
                livingCachedExternals.add(this);

                // If we are over the allowed number of cached processes
                // we kill the least recently used.
                if (livingCachedExternals.size() > externalConstantEvaluationMaxProc) {
                    livingCachedExternals.iterator().next().destroyProcess(timeout);
                }
            }

            @Override
            public void destroyProcess(int timeout) {
                if (com != null) {
                    livingCachedExternals.remove(this);
                    com.destroy();
                    com = null;
                }
            }

            @Override
            public void remove() {
                // Removing this executable is handled by surrounding MappedExternalFunction
                throw new UnsupportedOperationException();
            }
        }
    }
}
