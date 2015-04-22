/*
    Copyright (C) 2010 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package org.jmodelica.util;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * OptionRegistry contains all options for the compiler. Options
 * can be created and retrieved based on type: String, Integer etc.
 * OptionRegistry also provides methods for handling paths
 * to Modelica libraries.
 * 
 * This class should only be instantiated through ModelicaCompiler.createOptions(). 
 * This is to ensure that hooks for adding options work properly, by putting 
 * all contributors in ModelicaCompiler and ensuring that it is loaded before 
 * any OptionRegistry instances are created.
 */
abstract public class OptionRegistry {

    /**
     * Extend this class and add an instance to the contributor list with 
     * {@link OptionRegistry#addContributor(OptionContributor)} to contribute 
     * to set of options. The preferred way to do this is adding a static 
     * field in ModelicaCompiler that gets its value from a call to addContributor().
     */
    abstract public static class OptionContributor {
        /**
         * Add additional options to the registry.
         */
        public void addOptions(OptionRegistry opt) {}

        /**
         * Change options that are in the registry.
         */
        public void modifyOptions(OptionRegistry opt) {}

        /**
         * Returns an object that uniquely identifies this contributor, to protect 
         * against the same contributor being added several times. One example is when 
         * Modelica and Optimica versions of compiler are loaded in the same JVM.
         * 
         * Recommended is a string literal in the jrag file.
         */
        public abstract Object identity();
    }

    private static java.util.List<OptionContributor> CONTRIBUTORS = new ArrayList<OptionContributor>();

    private static java.util.Map<Object,OptionContributor> CONTRIBUTOR_IDENTITES = new HashMap<Object,OptionContributor>();

    /**
     * Adds a new options contributor.
     * 
     * @param oc  the contributor
     * @return    the contributor, for convenience
     */
    public static OptionContributor addContributor(OptionContributor oc) {
        Object id = oc.identity();
        OptionContributor old = CONTRIBUTOR_IDENTITES.get(id);
        if (old == null) {
            CONTRIBUTOR_IDENTITES.put(id, oc);
            CONTRIBUTORS.add(oc);
            return oc;
        } else {
            return old;
        }
    }

    public interface Inlining {
        public static final String NONE    = "none";
        public static final String TRIVIAL = "trivial";
        public static final String ALL     = "all";
    }
    public interface Homotopy {
        public static final String SIMPLIFIED = "simplified";
        public static final String ACTUAL     = "actual";
        public static final String HOMOTOPY   = "homotopy";
    }
    public interface RuntimeLogLevel {
        public static final int NONE = 0;
        public static final int FATAL = 1;
        public static final int ERROR = 2;
        public static final int WARNING = 3; /* default */
        public static final int INFO = 4;
        public static final int VERBOSE = 5;
        public static final int DEBUG = 6;
        public static final int MOREDEBUG = 7;
        public static final int MAXDEBUG = 8;
    }
    public interface LocalIteration {
        public static final String OFF        = "off";
        public static final String ANNOTATION = "annotation";
        public static final String ALL        = "all";
    }
    public interface NonlinearSolver {
        public static final String KINSOL  = "kinsol";
        public static final String MINPACK = "minpack";
    }
    public interface FMIVersion {
        public static final String FMI10  = "1.0";
        public static final String FMI20  = "2.0";
        public static final String FMI20a = "2.0alpha";
    }

    public enum OptionType { compiler, runtime }
    public static final OptionType compiler = OptionType.compiler;
    public static final OptionType runtime  = OptionType.runtime;

    private enum Default {
        // Compiler options
        GENERATE_ONLY_INITIAL_SYSTEM 
            ("generate_only_initial_system", 
             compiler, 
             false, 
             "If this option is set to true (default is false), only the initial equation system will be generated."),
        DIVIDE_BY_VARS_IN_TEARING 
            ("divide_by_vars_in_tearing", 
             compiler, 
             false, 
             "If this option is set to true (default is false), a less restrictive strategy is used for solving equations " +
             "in the tearing algorithm. Specifically, division by parameters and variables is permitted, by default no " +
             "such divisions are made during tearing."),
        LOCAL_ITERATION_IN_TEARING 
            ("local_iteration_in_tearing", 
             compiler, 
             LocalIteration.OFF, 
             "This option controls whether equations can be solved local in tearing. Possible options are: " +
             "'off', local iterations are not used (default). " +
             "'annotation', only equations that are annotated are candidates. " +
             "'all', all equations are candidates.",
             LocalIteration.OFF, LocalIteration.ANNOTATION, LocalIteration.ALL),
        AUTOMATIC_TEARING
            ("automatic_tearing", 
             compiler, 
             true, 
             "If this option is set to true (default is true), automatic tearing of equation systems is performed."),
        CONV_FREE_DEP_PAR_TO_ALGS
            ("convert_free_dependent_parameters_to_algebraics", 
             compiler, 
             true, 
             "If this option is set to true (default is true), free dependent parameters are" +
             "converted to algebraic variables."),
        GEN_DAE
            ("generate_dae", 
             compiler, 
             false, 
             "If this option is set to true (default is false), code for solving DAEs are generated."),
        GEN_DAE_JAC
            ("generate_dae_jacobian", 
             compiler, 
             false, 
             "If this option is set to true (default is false), code for computing DAE Jacobians are generated."),
        GEN_ODE_JAC
            ("generate_ode_jacobian", 
             compiler, 
             false,
             "If this option is set to true (default is false), code for computing ODE Jacobians are generated."),
        GEN_BLOCK_JAC
            ("generate_block_jacobian", 
             compiler, 
             false,
             "If this option is set to true (default is false), code for computing block Jacobians is generated. "+
             "If blocks are needed to compute ODE jacobians they will be generated anyway"),
        GEN_ODE
            ("generate_ode", 
             compiler, 
             true, 
             "If this option is set to true (default is true), code for solving ODEs are generated. "),
        GEN_MOF_FILES
            ("generate_mof_files", 
             compiler, 
             false,
             "If this option is set to true (default is false), flat model before and after" +
             " transformations will be generated."),
        EXTRA_LIB
            ("extra_lib_dirs", 
             compiler, 
             "", 
             "The value of this option is appended to the value of the MODELICAPATH environment " +
             "variable for determining in what directories to search for libraries."),
        START_FIX
            ("state_start_values_fixed", 
             compiler, 
             false, 
             "This option enables the user to specify if initial equations should be " + 
             "generated automatically for differentiated variables even though the fixed " +
             "attribute is equal to fixed. Setting this option to true is, however, often " +
             "practical in optimization problems."),
        ELIM_ALIAS
            ("eliminate_alias_variables", 
             compiler, 
             true, 
             "If this option is set to true (default), then alias variables are " +
             "eliminated from the model."),
        VPROP
             ("variability_propagation", 
              compiler, 
              true,
              "If this option is set to true (default), then variabilities are " +
              "propagated through the model."),
        EXT_CEVAL
            ("external_constant_evaluation", 
             compiler, 
             5000,
             "Time limit (ms) when evaluating constant calls to external functions during compilation. "
             + "0 indicates no evaluation. -1 indicates no time limit. Default is 5000."),
        HALT_WARN
            ("halt_on_warning", 
             compiler, 
             false, 
             "If this option is set to false (default) one or more compiler " +
             "warnings will not stop compilation of the model."),
        XML_EQU
            ("generate_xml_equations", 
             compiler, 
             false, 
             "If this option is true, then model equations are generated in XML format. " + 
             "Default is false."),
        INDEX_RED
            ("index_reduction", 
             compiler, 
             true, 
             // NB: this description used in a Python test 
             "If this option is true (default is true), index reduction is performed."),
        EQU_SORT
            ("equation_sorting", 
             compiler, 
             true, 
             "If this option is true (default is true), equations are sorted using the BLT algorithm."),
        XML_FMI_ME
            ("generate_fmi_me_xml", 
             compiler, 
             true, 
             "If this option is true (default is true) the model description part of the XML variables file " + 
             "will be FMI for model exchange compliant. To generate an XML which will " + 
             "validate with FMI schema the option generate_xml_equations must also be false."),
        XML_FMI_CS 
            ("generate_fmi_cs_xml", 
             compiler, 
             false, 
             "If this option is true (default is false) the model description part of the XML variables file " + 
             "will be FMI for co simulation compliant. To generate an XML which will " + 
             "validate with FMI schema the option generate_xml_equations must also be false."),
        FMI_VER 
            ("fmi_version", 
             compiler, 
             FMIVersion.FMI10, 
             "Version of the FM1 specification to generate FMU for.", 
             FMIVersion.FMI10, FMIVersion.FMI20, FMIVersion.FMI20a /* Temporary alpha version for FMI 2.0. TODO: remove */),
        VAR_SCALE 
            ("enable_variable_scaling", 
             compiler, 
             false, 
             "If this option is true (default is false), then the \"nominal\" attribute will " + 
             "be used to scale variables in the model."),
        MIN_T_TRANS 
            ("normalize_minimum_time_problems", 
             compiler, 
             true, 
             "When this option is set to true (default is true) then minimum time " +
             "optimal control problems encoded in Optimica are converted to fixed " + 
             "interval problems by scaling of the derivative variables."),
        STRUCTURAL_DIAGNOSIS 
            ("enable_structural_diagnosis", 
             compiler, 
             true, 
             "Enable this option to invoke the structural error diagnosis based on the matching algorithm."),
        ADD_INIT_EQ 
            ("automatic_add_initial_equations", 
             compiler, 
             true, 
             "When this option is set to true (default is true), then additional initial " +
             "equations are added to the model based on a the result of a matching algorithm. " +
             "Initial equations are added for states that are not matched to an equation."), 
        COMPL_WARN 
            ("compliance_as_warning", 
             compiler, 
             false, 
             "When this option is set to true (default is false), then compliance errors are treated " + 
             "as warnings instead. This can lead to the compiler or solver crashing. Use with caution!"),
        COMPONENT_NAMES_IN_ERRORS 
            ("component_names_in_errors", 
             compiler, 
             false, 
             "When this option is set to true (default is false), the compiler will include the name of " +
             "the component where the error was found, if applicable."),
        GEN_HTML_DIAG 
            ("generate_html_diagnostics", 
             compiler, 
             false, 
             "When this option is set to true (default is false) model diagnostics is generated in HTML format. " +
             "This includes the flattened model, connection sets, alias sets and BLT form."), 
        DIAGNOSTICS_LIMIT 
        ("diagnostics_limit", 
             compiler, 
             500, 
             "This option specifies the maximum size of the equation system before the compiler will start to reduce " +
             "model diagnostics. This option only affect diagnostic output which grows in non-linear fashion.",
             0, Integer.MAX_VALUE), 
        EXPORT_FUNCS 
            ("export_functions", 
             compiler, 
             false, 
             "Export used Modelica functions to generated C code in a manner that is compatible with the " +
             "external C interface in the Modelica Language Specification (default is false)"),
        EXPORT_FUNCS_VBA 
            ("export_functions_vba", 
             compiler, 
             false, 
             "Create VBA-compatible wrappers for exported functions (default is false). Requires export_functions"), 
        STATE_INIT_EQ 
            ("state_initial_equations", 
             compiler, 
             false, 
             "Neglect initial equations in the model and add initial equations, and parameters, for the states." +
             "Default is false."),
        INLINE_FUNCS 
            ("inline_functions", 
             compiler, 
             Inlining.TRIVIAL, 
             "Perform function inlining on model after flattening (allowed values are none, trivial or all, default is trivial)", 
             Inlining.NONE, Inlining.TRIVIAL, Inlining.ALL),
        HOMOTOPY 
            ("homotopy_type", 
             compiler, 
             Homotopy.ACTUAL, 
             "Decides how homotopy expressions are interpreted during compilation. Default value is 'actual'. " + 
             "Can be set to either 'simplified' or 'actual' which will compile the model using the simplified or " + 
             "actual expressions.", 
             Homotopy.HOMOTOPY, Homotopy.ACTUAL, Homotopy.SIMPLIFIED),
        DEBUG_CSV_STEP_INFO 
            ("debug_csv_step_info", 
             compiler, 
             false,
             "Debug option, outputs a csv file containing profiling recorded during compilation. Default is false."),
        DEBUG_INVOKE_GC 
            ("debug_invoke_gc", 
             compiler, 
             false,
             "Debug option, if the option is set to true (default false), GC will be invoked between the different " +
             "steps during model compilation. This makes it possible to output accurate memory measurements."),
        DEBUG_DUP_GEN 
            ("debug_duplicate_generated", 
             compiler, 
             false,
             "Debug option, duplicates generated files to stdout. Default is false."),
         DEBUG_TRANSFORM_STEPS
             ("debug_transformation_steps",
              compiler,
              "none",
              "Options for debugging the different transformation steps. If enabled, diagnostics files are written" +
              " after each transformation step. Allowed values are 'none' (default), 'diag' (only model diagnostics)," +
              " 'full' (write diagnostics and flat tree).",
              "none", "diag", "full"),
        RUNTIME_PARAM
            ("generate_runtime_option_parameters",
             compiler,
             true,
             "Generate parameters for runtime options. For internal use, should always be true for normal compilation."),
        WRITE_ITER_VARS
            ("write_iteration_variables_to_file",
             compiler,
             false,
             "If the option is set to true (default is false), two text files containing one iteration variable" +
             "name per row is written to disk. The files contains the iteration variables for the DAE and the" +
             "DAE initialization system respectively. The files are outputed to the resource directory"),
        ALG_FUNCS
             ("algorithms_as_functions",
              compiler,
              false,
              "Convert algorithm sections to function calls"),
        WRITE_TEARING_PAIRS
            ("write_tearing_pairs_to_file",
             compiler,
             false,
             "If the option is set to true (default is false), two text files containing tearing pairs" +
             " is written to disk. The files contains the tearing pairs for the DAE and the" +
             "DAE initialization system respectively. The files are outputed to the working directory"),
        CHECK_INACTIVE
            ("check_inactive_contitionals",
             compiler,
             false,
             "Check for errors in inactive conditional components when compiling. When checking a class, " +
             "this is always done. Default is false."),
        IGNORE_WITHIN
            ("ignore_within",
             compiler,
             false,
             "Ignore within clauses, both when reading input files and when error-checking. Default is false."),
        NLE_SOLVER
            ("nonlinear_solver",
            compiler,
            NonlinearSolver.KINSOL,
            "Decides which nonlinear equation solver that will be used. Default is kinsol.",
            NonlinearSolver.KINSOL, NonlinearSolver.MINPACK),
        GENERATE_EVENT_SWITCHES
            ("generate_event_switches",
            compiler,
            true,
            "Controls whether event generating expressions should generate switches in the c-code. " +
            "Setting this option to false can give unexpected results. Default is true."),
        RELATIONAL_TIME_EVENTS
            ("relational_time_events",
            compiler,
            true,
            "Controls whether relational operators should be able to generate time events. Default is true."),
       BLOCK_FUNCTION_EXTRACTION
            ("enable_block_function_extraction",
            compiler,
            false,
            "Looks for function calls in blocks. If a function call in a block doesn't depend on"
            + "the block in question, it is extracted."),
        FUNCTION_INCIDENCE_CALC
            ("function_incidence_computation",
            compiler,
            "none",
            "Controls how matching algorithm computes incidences for function call equations."
            + " Possible values: 'none', 'all'. With 'none' all outputs are assumed to depend"
            + " on all inputs. With 'all' the compiler analyses the function to determine dependencies."),
        MAX_N_PROC
            ("max_n_proc",
            compiler,
            4,
            "The maximum number of processes used during c-code compilation"),
        DYNAMIC_STATES
            ("dynamic_states",
            compiler,
            true,
            "Experimental! Controls whether dynamic states should be calculated and generated."),
        LOCAL_PRE_HANDLING
            ("local_pre_handling",
            compiler,
            false,
            "Experimental! Controls whether pre writebacks should be done after each block."),

        // Runtime options
        /*
         * Note: Two JUnit tests are affected by changes to runtime options:
         * ModelicaCompiler : TransformCanonicalTests.mo : TestRuntimeOptions1
         * ModelicaCBackEnd : CCodeGenTests.mo : TestRuntimeOptions1
         */
        RUNTIME_LOG_LEVEL
            ("log_level",
              runtime, 
              RuntimeLogLevel.WARNING,
              "Log level for the runtime: 0 - none, 1 - fatal error, 2 - error, 3 - warning, 4 - info, 5 -verbose, 6 - debug.",
                RuntimeLogLevel.NONE, RuntimeLogLevel.MAXDEBUG),
        ENFORCE_BOUNDS
            ("enforce_bounds",
            runtime,
            true,
            "Enforce min-max bounds on variables in the equation blocks."),
        USE_JACOBIAN_EQUILIBRATION
            ("use_jacobian_equilibration",
             runtime,
             false,
             "If jacobian equilibration should be utilized in equation block solvers to improve linear solver accuracy."),
        USE_NEWTON_FOR_BRENT
            ("use_newton_for_brent",
             runtime,
             true,
             "If a few Newton steps are to be performed to get a better initial guess for Brent."),
        ITERATION_VARIABLE_SCALING
            ("iteration_variable_scaling",
            runtime,
            1,
            "Iteration variables scaling mode in equation block solvers:"+
            "0 - no scaling, 1 - scaling based on nominals only (default), 2 - utilize heuristict to guess nominal based on min,max,start, etc.",
            0,2),
        RESIDUAL_EQUATION_SCALING
            ("residual_equation_scaling",
             runtime,
             1,
             "Equations scaling mode in equation block solvers:0-no scaling,1-automatic scaling,2-manual scaling, 3-hybrid",
			 0,3),
        NLE_SOLVER_MIN_RESIDUAL_SCALING_FACTOR
            ("nle_solver_min_residual_scaling_factor",
                runtime,
                1e-10,
             "Minimal scaling factor used by automatic and hybrid residual scaling algorithm.",
             1e-32, 1),
        NLE_SOLVER_MAX_RESIDUAL_SCALING_FACTOR
            ("nle_solver_max_residual_scaling_factor",
                runtime,
                1e10,
             "Maximal scaling factor used by automatic and hybrid residual scaling algorithm.",
             1, 1e32),
        RESCALE_EACH_STEP
            ("rescale_each_step",
               runtime,
               false,
               "Scaling should be updated at every step (only active if use_automatic_scaling is on)."),
        RESCALE_AFTER_SINGULAR_JAC
            ("rescale_after_singular_jac",
                runtime,
                true,
                 "If scaling should be updated after singular jac was detected (only active if use_automatic_scaling is set)."),
        USE_BRENT_IN_1D
            ("use_Brent_in_1d",
                runtime,
                true,
                "Use Brent search to improve accuracy in solution of 1D non-linear equations."),
        BLOCK_SOLVER_EXPERIMENTAL_MODE
            ("block_solver_experimental_mode",
                runtime,
                0,
                "Activate experimental features of equation block solvers",
                0,255),
        NLE_SOLVER_DEFAULT_TOL
            ("nle_solver_default_tol",
                runtime,
                1e-10,
             "Default tolerance for the equation block solver.",
             1e-14, 1e-2),
        NLE_SOLVER_CHECK_JAC_COND
            ("nle_solver_check_jac_cond",
            runtime, 
            false,
            "NLE solver should check Jacobian condition number and log it."),
        NLE_SOLVER_MIN_TOL
            ("nle_solver_min_tol",
                runtime,
                1e-12,
                "Minimum tolerance for the equation block solver. Note that, for instance, default Kinsol tolerance is machine precision pwr 1/3, i.e., 1e-6."+
                    "Tighter tolerance is default in JModelica.", 1e-14, 1e-6),
        NLE_SOLVER_TOL_FACTOR
            ("nle_solver_tol_factor",
                runtime,
                0.0001,
                "Tolerance safety factor for the non-linear equation block solver. Used when external solver specifies relative tolerance.",
                1e-6,1.0),
        NLE_SOLVER_MAX_ITER
            ("nle_solver_max_iter",
            runtime,
            100,
            "Maximum number of iterations for the equation block solver before failure",
            2,500),
        NLE_SOLVER_STEP_LIMIT_FACTOR
            ("nle_solver_step_limit_factor",
            runtime,
            10,
            "Factor limiting the step-size taken by the nonlinear solver",
            0,1e10),
        NLE_SOLVER_REGULARIZATION_TOLERANCE
            ("nle_solver_regularization_tolerance",
            runtime,
            -1,
            "Tolerance for deciding when regularization should kick in (i.e. when condition number > reg tol)",
            -1,1e20),
        EVENTS_DEFAULT_TOL
            ("events_default_tol",
              runtime,
             1e-10,
             "Default tolerance for the event iterations.",
              1e-14, 1e-2),
        EVENTS_TOL_FACTOR
            ("events_tol_factor",
                runtime,
              0.0001,
              "Tolerance safety factor for the event iterations. Used when external solver specifies relative tolerance.",
              1e-6,1.0),
        BLOCK_JACOBIAN_CHECK
            ("block_jacobian_check",
             runtime,
             false,
             "Compares the analytic block jacobians with the finite difference block jacobians during block evaluation. An error is given if the relative error is to big."),
        BLOCK_JACOBIAN_CHECK_TOL
            ("block_jacobian_check_tol",
             runtime,
             1e-6,
             "Specifies the relative tolerance for block jacobian check.",
             1e-12,1.0),
        CS_SOLVER
            ("cs_solver",
             runtime,
             0,
             "Specifies the internal solver used in co-simulation. 0 == CVode, 1 == Euler",
             0,1),
        CS_REL_TOL
            ("cs_rel_tol",
              runtime,
             1e-6,
             "Default tolerance for the adaptive solvers in the CS case.",
              1e-14, 1.0),
        CS_STEP_SIZE
            ("cs_step_size",
              runtime,
             1e-3,
             "Default step-size for the non-adaptive solvers in the CS case."),
        RUNTIME_LOG_TO_FILE
            ("runtime_log_to_file",
            runtime,
            false,
            "Enable to write log messages from the runtime directly to a file, besides passing it to the FMU loader (e.g. FMIL). " +
            "The log file name is generated based on the FMU name."),
        ;

        public String key;
        public OptionType type;
        public String desc;
        public Object val;
        public Object[] lim;

        private Default(String k, OptionType t, Object v, String d, Object... l) {
            key = k;
            type = t;
            desc = d;
            val = v;
            lim = (l != null && l.length > 0) ? l : null;
        }

        private Default(String k, OptionType t, Object v, String d) {
            this(k, t, v, d, (Object[]) null);
        }

        private Default(String k, OptionType t, boolean v, String d) {
            this(k, t, new Boolean(v), d);
        }

        private Default(String k, OptionType t, double v, String d, double min, double max) {
            this(k, t, new Double(v), d, new Object[] {min, max});
        }

        private Default(String k, OptionType t, int v, String d, int min, int max) {
            this(k, t, new Integer(v), d, new Object[] {min, max});
        }

        public String toString() {
            return key;
        }
    }

    /**
     * Contributor for base options.
     */
    private static final OptionContributor BASE_CONTRIBUTOR = addContributor(new OptionContributor() {
        public void addOptions(OptionRegistry opt) {
            for (Default o : Default.values())
                opt.defaultOption(o);
        }

        public Object identity() {
            return "org.jmodelica.util.OptionRegistry.BASE_CONTRIBUTOR";
        }
    });

    private HashMap<String,Option> optionsMap;

    public OptionRegistry() {
        optionsMap = new HashMap<String,Option>();
        for (OptionContributor oc : CONTRIBUTORS)
            oc.addOptions(this);
        for (OptionContributor oc : CONTRIBUTORS)
            oc.modifyOptions(this);
    }

    /**
     * Create a copy of this OptionRegistry.
     */
    public OptionRegistry copy() {
        OptionRegistry res = new OptionRegistry() {};
        res.copyAllOptions(this);
        return res;
    }

    private static final String INDENT = "    ";

    /**
     * \brief Replace tabs with INDENT.
     */
    protected static String indent(String str) {
        return str.replace("\t", INDENT);
    }

    /**
     * \brief Export all options as XML.
     * 
     * @param out  the stream to write to
     */
    public void exportXML(PrintStream out) {
        out.print(indent("<OptionsRegistry>\n\t<Options>\n"));
        for (Option o : optionsMap.values())
            o.exportXML(out);
        out.print(indent("\t</Options>\n</OptionsRegistry>\n"));
    }

    /**
     * \brief Export all options as an XML file.
     * 
     * @param name  the name of the file to write to
     * @throws FileNotFoundException  if the file cannot be opened
     */
    public void exportXML(String name) throws FileNotFoundException {
        FileOutputStream out = new FileOutputStream(name);
        exportXML(new PrintStream(out));
        try {
            out.close();
        } catch (IOException e) {
        }
    }

    protected void defaultOption(Default o) {
        if (o.val instanceof Integer) {
            if (o.lim != null)
                createIntegerOption(o.key, o.type, o.desc, iv(o.val), iv(o.lim[0]), iv(o.lim[1]));
            else
                createIntegerOption(o.key, o.type, o.desc, iv(o.val));
        } else if (o.val instanceof String) {
            String[] lim = (o.lim == null) ? null : Arrays.copyOf(o.lim, o.lim.length, String[].class);
            createStringOption(o.key, o.type, o.desc, (String) o.val, lim);
        } else if (o.val instanceof Double) {
            if (o.lim != null)
                createRealOption(o.key, o.type, o.desc, dv(o.val), dv(o.lim[0]), dv(o.lim[1]));
            else
                createRealOption(o.key, o.type, o.desc, dv(o.val));
        } else if (o.val instanceof Boolean) {
            createBooleanOption(o.key, o.type, o.desc, bv(o.val));
        }
    }

    private String unknownOptionMessage(String key) {
        String[] parts = key.split("_");
        for (int i = 0; i < parts.length; i++)
            parts[i] = parts[i].replaceAll("(ion|ing|s|e)$", "");
        String best = null;
        int bestScore = 0;
        for (String name : optionsMap.keySet()) {
            int score = -name.split("_").length;
            for (String part : parts)
                if (name.contains(part))
                    score += 1000 + part.length() * 10;
            if (score > bestScore) {
                best = name;
                bestScore = score;
            }
        }
        return (best == null) ? 
                String.format("Unknown option \"%s\"", key) : 
                String.format("Unknown option \"%s\", did you mean \"%s\"?", key, best);
    }

    private static int iv(Object o) {
        return ((Integer) o).intValue();
    }

    private static double dv(Object o) {
        return ((Double) o).doubleValue();
    }

    private static boolean bv(Object o) {
        return ((Boolean) o).booleanValue();
    }

    public void setOption(String key, String value) {
        Option o = optionsMap.get(key);
        if (o == null)
            throw new UnknownOptionException(unknownOptionMessage(key));
        o.setValue(value);
    }

    protected void createIntegerOption(String key, String description, int defaultValue) {
        createIntegerOption(key, compiler, description, defaultValue);
    }

    protected void createIntegerOption(String key, OptionType type, String description, int defaultValue) {
        optionsMap.put(key, new IntegerOption(key, type, description, defaultValue));
    }

    protected void createIntegerOption(String key, String description, int defaultValue, int min, int max) {
        createIntegerOption(key, compiler, description, defaultValue, min, max);
    }

    protected void createIntegerOption(String key, OptionType type, String description, int defaultValue, int min, int max) {
        optionsMap.put(key, new IntegerOption(key, type, description, defaultValue, min, max));
    }

    public void addIntegerOption(String key, int value, String description, int min, int max) {
        if (findIntegerOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createIntegerOption(key, compiler, description, value, min, max);
    }

    public void addIntegerOption(String key, int value, String description) {
        setIntegerOption(key, value, description, true);
    }

    public void addIntegerOption(String key, int value) {
        setIntegerOption(key, value, "", true);
    }

    public void setIntegerOption(String key, int value) {
        setIntegerOption(key, value, "", false);
    }

    protected void setIntegerOption(String key, int value, String description, boolean add) {
        IntegerOption opt = findIntegerOption(key, add);
        if (opt == null)
            createIntegerOption(key, description, value);
        else
            opt.setValue(value);
    }

    public void setIntegerOptionDefault(String key, int value) {
        findIntegerOption(key, false).setDefault(value);
    }

    public void expandIntegerOptionMax(String key, int val) {
        findIntegerOption(key, false).expandMax(val);
    }

    public void expandIntegerOptionMin(String key, int val) {
        findIntegerOption(key, false).expandMin(val);
    }

    public int getIntegerOption(String key) {
        return findIntegerOption(key, false).getValue();
    }

    public boolean isIntegerOption(String key) {
        return optionsMap.get(key) instanceof IntegerOption;
    }

    protected IntegerOption findIntegerOption(String key, boolean allowMissing) {
        Option o = optionsMap.get(key);
        if (o instanceof IntegerOption)
            return (IntegerOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of integer type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    protected void createStringOption(String key, String description, String defaultValue, String[] vals) {
        createStringOption(key, compiler, description, defaultValue, vals);
    }

    protected void createStringOption(String key, OptionType type, String description, String defaultValue, String[] vals) {
        optionsMap.put(key, new StringOption(key, type, description, defaultValue, vals));
    }

    public void addStringOption(String key, String value, String description) {
        setStringOption(key, value, description, true);
    }

    public void addStringOption(String key, String value, String description, String[] allowed) {
        if (findStringOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createStringOption(key, compiler, description, value, allowed);
    }

    public void addStringOption(String key, String value) {
        setStringOption(key, value, "", true);
    }

    public void setStringOption(String key, String value) {
        setStringOption(key, value, "", false);
    }

    protected void setStringOption(String key, String value, String description, boolean add) {
        StringOption opt = findStringOption(key, add);
        if (opt == null)
            createStringOption(key, description, value, null);
        else
            opt.setValue(value);
    }

    public void setStringOptionDefault(String key, String value) {
        findStringOption(key, false).setDefault(value);
    }

    public void addStringOptionAllowed(String key, String val) {
        findStringOption(key, false).addAllowed(val);
    }

    public String getStringOption(String key) {
        return findStringOption(key, false).getValue();
    }

    public boolean isStringOption(String key) {
        return optionsMap.get(key) instanceof StringOption;
    }

    protected StringOption findStringOption(String key, boolean allowMissing) {
        Option o = optionsMap.get(key);
        if (o instanceof StringOption)
            return (StringOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of string type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    protected void createRealOption(String key, String description, double defaultValue) {
        createRealOption(key, compiler, description, defaultValue);
    }

    protected void createRealOption(String key, OptionType type, String description, double defaultValue) {
        optionsMap.put(key, new RealOption(key, type, description, defaultValue));
    }

    protected void createRealOption(String key, String description, double defaultValue, double min, double max) {
        createRealOption(key, compiler, description, defaultValue, min, max);
    }

    protected void createRealOption(String key, OptionType type, String description, double defaultValue, double min, double max) {
        optionsMap.put(key, new RealOption(key, type, description, defaultValue, min, max));
    }

    public void addRealOption(String key, double value, String description) {
        setRealOption(key, value, description, true);
    }

    public void addRealOption(String key, double value, String description, double min, double max) {
        if (findRealOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createRealOption(key, compiler, description, value, min, max);
    }

    public void addRealOption(String key, double value) {
        setRealOption(key, value, "", true);
    }

    public void setRealOption(String key, double value) {
        setRealOption(key, value, "", false);
    }

    protected void setRealOption(String key, double value, String description, boolean add) {
        RealOption opt = findRealOption(key, add);
        if (opt == null)
            createRealOption(key, description, value);
        else
            opt.setValue(value);
    }

    public void setRealOptionDefault(String key, double value) {
        findRealOption(key, false).setDefault(value);
    }

    public void expandRealOptionMax(String key, double val) {
        findRealOption(key, false).expandMax(val);
    }

    public void expandRealOptionMin(String key, double val) {
        findRealOption(key, false).expandMin(val);
    }

    public double getRealOption(String key) {
        return findRealOption(key, false).getValue();
    }

    public boolean isRealOption(String key) {
        return optionsMap.get(key) instanceof RealOption;
    }

    protected RealOption findRealOption(String key, boolean allowMissing) {
        Option o = optionsMap.get(key);
        if (o instanceof RealOption)
            return (RealOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of real type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    protected void createBooleanOption(String key, String description, boolean defaultValue) {
        createBooleanOption(key, compiler, description, defaultValue);
    }

    protected void createBooleanOption(String key, OptionType type, String description, boolean defaultValue) {
        optionsMap.put(key, new BooleanOption(key, type, description, defaultValue));
    }

    public void addBooleanOption(String key, boolean value, String description) {
        setBooleanOption(key, value, description, true);
    }

    public void addBooleanOption(String key, boolean value) {
        setBooleanOption(key, value, "", true);
    }

    public void setBooleanOption(String key, boolean value) {
        setBooleanOption(key, value, "", false);
    }

    protected void setBooleanOption(String key, boolean value, String description, boolean add) {
        BooleanOption opt = findBooleanOption(key, add);
        if (opt == null)
            createBooleanOption(key, description, value);
        else
            opt.setValue(value);
    }

    public void setBooleanOptionDefault(String key, boolean value) {
        findBooleanOption(key, false).setDefault(value);
    }

    public boolean getBooleanOption(String key) {
        return findBooleanOption(key, false).getValue();
    }

    public boolean isBooleanOption(String key) {
        return optionsMap.get(key) instanceof BooleanOption;
    }

    protected BooleanOption findBooleanOption(String key, boolean allowMissing) {
        Option o = optionsMap.get(key);
        if (o instanceof BooleanOption)
            return (BooleanOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of boolean type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    public String getDescription(String key){
        Option o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getDescription();
    }

    public Set<Map.Entry<String, Option>> getAllOptions() {
        return optionsMap.entrySet();
    }

    public Collection<String> getOptionKeys() {
        return getFilteredOptionName(NULL_OPTION_FILTER);
    }

    public Collection<String> getCompilerOptionKeys() {
        return getTypeOptionKeys(compiler);
    }

    public Collection<String> getRuntimeOptionKeys() {
        return getTypeOptionKeys(runtime);
    }

    public Collection<String> getTypeOptionKeys(OptionType type) {
        return getFilteredOptionName(new TypeOptionFilter(type));
    }

    public Collection<String> getFilteredOptionName(OptionFilter filter) {
        List<String> res = new ArrayList<String>();
        for (Option o : optionsMap.values())
            if (filter.filter(o))
                res.add(o.key);
        Collections.sort(res);
        return res;
    }

    public void copyAllOptions(OptionRegistry registry) throws UnknownOptionException{
        // copy all options in parameter registry to this 
        // optionregistry and overwrite if exists before.
        Set<Map.Entry<String, Option>> set = registry.getAllOptions();
        Iterator<Map.Entry<String, Option>> itr = set.iterator();
        //iterate over all Map.entry
        while(itr.hasNext()) {
            Map.Entry<String, Option> entry = itr.next();
            String key = entry.getKey();
            Option o = entry.getValue();
            if(o instanceof StringOption) {
                addStringOption(key, ((StringOption) o).getValue());
            } else if(o instanceof IntegerOption) {
                addIntegerOption(key, ((IntegerOption) o).getValue());
            } else if(o instanceof RealOption) {
                addRealOption(key, ((RealOption) o).getValue());
            } else if(o instanceof BooleanOption) {
                addBooleanOption(key, ((BooleanOption) o).getValue());
            } else {
                throw new UnknownOptionException(
                        "Trying to copy unknown option with key: "+key+
                        " and description "+o.getDescription());
            }
        }
    }

    /**
     * \brief Make the first letter in a string capital.
     */
    public static Object capitalize(String str) {
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }

    public static String wrap(String str, String prefix, int width) {
        StringBuilder buf = new StringBuilder();
        int start = 0;
        int end = start + width;
        int len = str.length();
        while (end < len) {
            while (end > start && !Character.isWhitespace(str.charAt(end)))
                end--;
            buf.append(prefix);
            if (end <= start) {
                buf.append(str.substring(start, start + width - 1));
                start += width - 1;
                buf.append('-');
            } else {
                buf.append(str.substring(start, end));
                start = end + 1;
            }
            buf.append('\n');
            end = start + width;
        }
        buf.append(prefix);
        buf.append(str.substring(start));
        buf.append('\n');
        return buf.toString();
    }


    private abstract static class Option {
        protected final String key;
        private String description;
        private boolean descriptionChanged = false;
        private boolean defaultChanged = false;
        private OptionType type;

        public Option(String key, String description, OptionType type) {
            this.key = key;
            this.description = description;
            this.type = type;
        }

        public void exportXML(PrintStream out) {
            String type = getType();
            String tag = capitalize(type) + "Attributes";
            String attrs = String.format("\t\t\t<%s key=\"%s\" value=\"%s\"", tag, key, getValueString());
            out.print(String.format(indent("\t\t<Option type=\"%s\">\n"), type));
            out.print(indent(attrs));
//            if (description == null || description.isEmpty()) {
            if (description == null || description.equals("")) {
                out.print("/>\n");
            } else {
                out.print(indent(">\n\t\t\t\t<Description>\n"));
                out.print(wrap(description, indent("\t\t\t\t\t"), 80));
                out.print(indent("\t\t\t\t</Description>\n\t\t\t</"));
                out.print(tag);
                out.print(">\n");
            }
            out.print(indent("\t\t</Option>\n"));
        }

        public abstract String getType();
        public abstract String getValueString();

        public String getKey() {
            return key;
        }

        public String getDescription() {
            return description;
        }

        public void changeDescription(String desc) {
            if (descriptionChanged)
                throw new UnsupportedOperationException("Description of " + key + " has already been changed.");
            descriptionChanged = true;
            description = desc;
        }

        public String toString() {
            return "\'"+key+"\': " + description; 
        }

        protected void invalidValue(Object value, String allowedMsg) {
            throw new InvalidOptionValueException("Option '" + key + "' does not allow the value '" +
                    value + "'" + allowedMsg);
        }

        protected abstract void setValue(String str);

        protected void changeDefault() {
            if (defaultChanged)
                throw new IllegalArgumentException("Default value for " + key + " has already been changed.");
            defaultChanged = true;
        }
    }

    private static class IntegerOption extends Option {
        protected int value;
        private int min;
        private int max;

        public IntegerOption(String key, OptionType type, String description, int value) {
            this(key, type, description, value, Integer.MIN_VALUE, Integer.MAX_VALUE);
        }

        public IntegerOption(String key, OptionType type, String description, int value, int min, int max) {
            super(key, description, type);
            this.value = value;
            this.min = min;
            this.max = max;
        }

        @Override
        protected void setValue(String str) {
            try {
                setValue(Integer.parseInt(str));
            } catch (NumberFormatException e) {
                invalidValue(str, ", expecting integer value" + minMaxStr());
            }
        }

        public void setValue(int value) {
            if (value < min || value > max)
                invalidValue(value, minMaxStr());
            this.value = value;
        }

        private String minMaxStr() {
            return (min == Integer.MIN_VALUE ? "" : ", min: " + min) + (max == Integer.MAX_VALUE ? "" : ", max: " + max);
        }

        public void setDefault(int value) {
            changeDefault();
            this.value = value;
        }

        public int getValue() {
            return value;
        }

        public void expandMin(int val) {
            if (val < min)
                min = val;
        }

        public void expandMax(int val) {
            if (val > max)
                max = val;
        }

        @Override
        public String getType() {
            return "integer";
        }

        @Override
        public String getValueString() {
            return Integer.toString(value);
        }
    }

    private static class StringOption extends Option {
        protected String value;
        protected Map<String,String> vals;

        public StringOption(String key, OptionType type, String description, String value) {
            this(key, type, description, value, null);
        }

        public StringOption(String key, OptionType type, String description, String value, String[] vals) {
            super(key, description, type);
            this.value = value;
            if (vals == null) {
                this.vals = null;
            } else {
                this.vals = new HashMap<String,String>(8);
                for (String v : vals)
                    this.vals.put(v, v);
            }
        }

        @Override
        public void setValue(String value) {
            if (vals != null) {
                String v = vals.get(value);
                if (v != null) {
                    this.value = v;
                    return;
                }
                StringBuilder buf = new StringBuilder(", allowed values: ");
                Object[] arr = vals.keySet().toArray();
                Arrays.sort(arr);
                buf.append(Arrays.toString(arr).substring(1));
                invalidValue(value, buf.substring(0, buf.length() - 1));
            } else {
                this.value = value;
            }
        }

        public void setDefault(String value) {
            changeDefault();
            this.value = value;
        }

        public String addAllowed(String value) {
            if (vals == null)
                throw new IllegalArgumentException("This option allows any value");
            if (vals.containsKey(value)) {
                return vals.get(value);
            } else {
                vals.put(value, value);
                return value;
            }
        }

        public String getValue() {
            return value;
        }

        @Override
        public String getType() {
            return "string";
        }

        @Override
        public String getValueString() {
            return value;
        }
    }

    private static class RealOption extends Option {
        protected double value;
        protected double min;
        protected double max;

        public RealOption(String key, OptionType type, String description, double value) {
            this(key, type, description, value, Double.MIN_VALUE, Double.MAX_VALUE);
        }

        public RealOption(String key, OptionType type, String description, double value, double min, double max) {
            super(key, description, type);
            this.value = value;
            this.min = min;
            this.max = max;
        }

        @Override
        protected void setValue(String str) {
            try {
                setValue(Double.parseDouble(str));
            } catch (NumberFormatException e) {
                invalidValue(str, ", expecting integer value" + minMaxStr());
            }
        }

        public void setValue(double value) {
            if (value < min || value > max)
                invalidValue(value, minMaxStr());
            this.value = value;
        }

        private String minMaxStr() {
            return (min == Double.MIN_VALUE ? "" : ", min: " + min) + (max == Double.MAX_VALUE ? "" : ", max: " + max);
        }

        public void setDefault(double value) {
            changeDefault();
            this.value = value;
        }

        public double getValue() {
            return value;
        }

        public void expandMin(double val) {
            if (val < min)
                min = val;
        }

        public void expandMax(double val) {
            if (val > max)
                max = val;
        }

        @Override
        public String getType() {
            return "real";
        }

        @Override
        public String getValueString() {
            return Double.toString(value);
        }
    }

    private static class BooleanOption extends Option {
        protected boolean value;

        public BooleanOption(String key, OptionType type, String description, boolean value) {
            super(key, description, type);
            this.value = value;
        }

        @Override
        protected void setValue(String str) {
            if (str.equals("true") || str.equals("yes") || str.equals("on"))
                setValue(true);
            else if (str.equals("false") || str.equals("no") || str.equals("off"))
                setValue(false);
            else
                invalidValue(str, ", expecting boolean value.");
        }

        public void setValue(boolean value) {
            this.value = value;
        }

        public void setDefault(boolean value) {
            changeDefault();
            this.value = value;
        }

        public boolean getValue() {
            return value;
        }

        @Override
        public String getType() {
            return "boolean";
        }

        @Override
        public String getValueString() {
            return Boolean.toString(value);
        }
    }

    public interface OptionFilter {
        public boolean filter(Option o);
    }

    public class TypeOptionFilter implements OptionFilter {
        private OptionType type;

        public TypeOptionFilter(OptionType t) {
            type = t;
        }

        public boolean filter(Option o) {
            return o.type == type;
        }
    }

    public static final OptionFilter NULL_OPTION_FILTER = new OptionFilter() {
        public boolean filter(Option o) {
            return true;
        }
    };

    public static class UnknownOptionException extends RuntimeException { 
        private static final long serialVersionUID = 3884972549318063140L;

        public UnknownOptionException(String message) {
            super(message);
        }
    }

    public static class InvalidOptionValueException extends RuntimeException { 
        private static final long serialVersionUID = 3884972549318063141L;

        public InvalidOptionValueException(String message) {
            super(message);
        }
    }
}
