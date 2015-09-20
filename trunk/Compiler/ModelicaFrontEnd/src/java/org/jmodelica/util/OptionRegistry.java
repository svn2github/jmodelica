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
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.StringWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

    private static java.util.Map<Object,OptionContributor> CONTRIBUTOR_IDENTITES = new LinkedHashMap<Object,OptionContributor>();

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
    public interface FunctionIncidenceCalc {
        public static final String NONE  = "none";
        public static final String ALL = "all";
    }

    public enum OptionType { compiler, runtime }

    public enum Category { common, user, uncommon, experimental, debug, internal }

    private enum Default {
        // Compiler options
        GENERATE_ONLY_INITIAL_SYSTEM 
            ("generate_only_initial_system", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, then only the initial equation system will be generated."),
        DIVIDE_BY_VARS_IN_TEARING 
            ("divide_by_vars_in_tearing", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, a less restrictive strategy is used for solving equations in the tearing algorithm. " +
             "Specifically, division by parameters and variables is permitted, by default no such divisions are " +
             "made during tearing."),
        LOCAL_ITERATION_IN_TEARING 
            ("local_iteration_in_tearing", 
             OptionType.compiler, 
             Category.uncommon,
             LocalIteration.OFF, 
             "This option controls whether equations can be solved local in tearing. Possible options are: 'off', " +
             "local iterations are not used (default). 'annotation', only equations that are annotated are " +
             "candidates. 'all', all equations are candidates.",
             LocalIteration.OFF, LocalIteration.ANNOTATION, LocalIteration.ALL),
        AUTOMATIC_TEARING
            ("automatic_tearing", 
             OptionType.compiler, 
             Category.user,
             true, 
             "If enabled, then automatic tearing of equation systems is performed."),
        CONV_FREE_DEP_PAR_TO_ALGS
            ("convert_free_dependent_parameters_to_algebraics", 
             OptionType.compiler, 
             Category.user,
             true, 
             "If enabled, then free dependent parameters are converted to algebraic variables."),
        GEN_DAE
            ("generate_dae", 
             OptionType.compiler, 
             Category.internal,
             false, 
             "If enabled, then code for solving DAEs are generated."),
        GEN_DAE_JAC
            ("generate_dae_jacobian", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, then code for computing DAE Jacobians are generated."),
        GEN_ODE_JAC
            ("generate_ode_jacobian", 
             OptionType.compiler, 
             Category.user,
             false,
             "If enabled, then code for computing ODE Jacobians are generated."),
        GEN_BLOCK_JAC
            ("generate_block_jacobian", 
             OptionType.compiler, 
             Category.user,
             false,
             "If enabled, then code for computing block Jacobians is generated. "+
             "If blocks are needed to compute ODE jacobians they will be generated anyway"),
        GEN_ODE
            ("generate_ode", 
             OptionType.compiler, 
             Category.internal,
             true, 
             "If enabled, then code for solving ODEs are generated. "),
        GEN_MOF_FILES
            ("generate_mof_files", 
             OptionType.compiler, 
             Category.user,
             false,
             "If enabled, then flat model before and after transformations will be generated."),
        EXTRA_LIB
            ("extra_lib_dirs", 
             OptionType.compiler, 
             Category.internal,
             "", 
             "The value of this option is appended to the MODELICAPATH " +
             "when searching for libraries. Decrepated."),
        START_FIX
            ("state_start_values_fixed", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, then initial equations are generated automatically for differentiated variables even " +
             "though the fixed attribute is equal to fixed. Setting this option to true is, however, often " +
             "practical in optimization problems."),
        ELIM_ALIAS
            ("eliminate_alias_variables", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, then alias variables are eliminated from the model."),
        VPROP
            ("variability_propagation", 
             OptionType.compiler, 
             Category.uncommon,
             true,
             "If enabled, the compiler performs a global analysis on the equation system and reduces variables to " +
             "constants and parameters where applicable."),
        COMMON_SUBEXP_ELIM
            ("common_subexp_elim", 
             OptionType.compiler, 
             Category.uncommon,
             true,
             "If enabled, the compiler performs a global analysis on the equation system and extract identical " +
             "function calls into common equations."),
        EXT_CEVAL
            ("external_constant_evaluation", 
             OptionType.compiler, 
             Category.user,
             5000,
             "Time limit (ms) when evaluating constant calls to external functions during compilation. " +
             "0 indicates no evaluation. -1 indicates no time limit."),
        EXT_CEVAL_MAX_PROC
            ("external_constant_evaluation_max_proc",
             OptionType.compiler,
             Category.uncommon,
             10,
             "The maximum number of processes kept alive for evaluation of external functions during compilation. " +
             "This speeds up evaluation of functions using external objects during compilation." + 
             "If less than 1, no processes will be kept alive, i.e. this feature is turned off. "),
        HALT_WARN
            ("halt_on_warning", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, compilation warnings will cause compilation to abort."),
        XML_EQU
            ("generate_xml_equations", 
             OptionType.compiler, 
             Category.internal,
             false, 
             "If enabled, then model equations are generated in XML format."),
        INDEX_RED
            ("index_reduction", 
             OptionType.compiler, 
             Category.user,
             true, 
             "If enabled, then index reduction is performed for high-index systems."),
        PROPAGATE_DERIVATIVES
            ("propagate_derivatives", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, the compiler will try to replace ordinary variable references with derivative " +
             "references. This is done by first finding equations on the form x = der(y). If possible, uses of x " +
             "will then be replaced with der(x)."),
        EQU_SORT
            ("equation_sorting", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, then the equation system is separated into minimal blocks that can be solved sequentially."),
        XML_FMI_ME
            ("generate_fmi_me_xml", 
             OptionType.compiler, 
             Category.internal,
             true, 
             "If enabled, the model description part of the XML variables file " + 
             "will be FMI for model exchange compliant. To generate an XML which will " + 
             "validate with FMI schema the option generate_xml_equations must also be false."),
        XML_FMI_CS 
            ("generate_fmi_cs_xml", 
             OptionType.compiler, 
             Category.internal,
             false, 
             "If enabled, the model description part of the XML variables file " + 
             "will be FMI for co simulation compliant. To generate an XML which will " + 
             "validate with FMI schema the option generate_xml_equations must also be false."),
        FMI_VER 
            ("fmi_version", 
             OptionType.compiler, 
             Category.internal,
             FMIVersion.FMI10, 
             "Version of the FMI specification to generate FMU for.", 
             FMIVersion.FMI10, FMIVersion.FMI20, FMIVersion.FMI20a /* Temporary alpha version for FMI 2.0. TODO: remove */),
        VAR_SCALE 
            ("enable_variable_scaling", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "If enabled, then the 'nominal' attribute will be used to scale variables in the model."),
        MIN_T_TRANS 
            ("normalize_minimum_time_problems", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, then minimum time optimal control problems encoded in Optimica are converted to fixed " + 
             "interval problems by scaling of the derivative variables. Has no effect for Modelica models."),
        STRUCTURAL_DIAGNOSIS 
            ("enable_structural_diagnosis", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, structural error diagnosis based on matching of equations to variables is used."),
        ADD_INIT_EQ 
            ("automatic_add_initial_equations", 
             OptionType.compiler, 
             Category.uncommon,
             true, 
             "If enabled, then additional initial equations are added to the model based equation matching. " +
             "Initial equations are added for states that are not matched to an equation."), 
        COMPL_WARN 
            ("compliance_as_warning", 
             OptionType.compiler, 
             Category.internal,
             false, 
             "If enabled, then compliance errors are treated as warnings instead. " + 
             "This can lead to the compiler or solver crashing. Use with caution!"),
        COMPONENT_NAMES_IN_ERRORS 
            ("component_names_in_errors", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, the compiler will include the name of the component where the error was found, if applicable."),
        GEN_HTML_DIAG 
            ("generate_html_diagnostics", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, model diagnostics are generated in HTML format. This includes the flattened model, " +
             "connection sets, alias sets and BLT form."), 
        DIAGNOSTICS_LIMIT 
            ("diagnostics_limit", 
             OptionType.compiler, 
             Category.uncommon,
             500, 
             "This option specifies the equation system size at which the compiler will start to reduce " +
             "model diagnostics. This option only affects diagnostic output that grows faster than linear " + 
             "with the number of equations.",
             0, Integer.MAX_VALUE), 
        EXPORT_FUNCS 
            ("export_functions", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "Export used Modelica functions to generated C code in a manner that is compatible with the " +
             "external C interface in the Modelica Language Specification."),
        EXPORT_FUNCS_VBA 
            ("export_functions_vba", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "Create VBA-compatible wrappers for exported functions. Requires the option export_functions."), 
        STATE_INIT_EQ 
            ("state_initial_equations", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, the compiler ignores initial equations in the model and adds parameters for controlling " + 
             "intitial values of states." +
             "Default is false."),
        INLINE_FUNCS 
            ("inline_functions", 
             OptionType.compiler, 
             Category.uncommon,
             Inlining.TRIVIAL, 
             "Controlles what function calls are inlined. " + 
             "'none' - no function calls are inlined. " + 
             "'trivial' - inline function calls that will not increase the number of variables in the system. " + 
             "'all' - inline all function calls that are possible.", 
             Inlining.NONE, Inlining.TRIVIAL, Inlining.ALL),
        HOMOTOPY 
            ("homotopy_type", 
             OptionType.compiler, 
             Category.uncommon,
             Homotopy.ACTUAL, 
             "Decides how homotopy expressions are interpreted during compilation. " + 
             "Can be set to either 'simplified' or 'actual' which will compile the model using only the simplified " + 
             "or actual expressions of the homotopy() operator.", 
             Homotopy.HOMOTOPY, Homotopy.ACTUAL, Homotopy.SIMPLIFIED),
        DEBUG_CSV_STEP_INFO 
            ("debug_csv_step_info", 
             OptionType.compiler, 
             Category.debug,
             false,
             "Debug option, outputs a csv file containing profiling recorded during compilation."),
        DEBUG_INVOKE_GC 
            ("debug_invoke_gc", 
             OptionType.compiler, 
             Category.debug,
             false,
             "Debug option, if enabled, GC will be invoked between the different steps during " +
             "model compilation. This makes it possible to output accurate memory measurements."),
        DEBUG_DUP_GEN 
            ("debug_duplicate_generated", 
             OptionType.compiler, 
             Category.debug,
             false,
             "Debug option, duplicates any generated files to stdout."),
         DEBUG_TRANSFORM_STEPS
            ("debug_transformation_steps",
             OptionType.compiler,
             Category.debug,
             "none",
             "Options for debugging the different transformation steps. If enabled, diagnostics files are written " +
             "after each transformation step. Allowed values are 'none', 'diag' (only fixed-size model diagnostics), " +
             "'full' (write diagnostics and flat tree).",
             "none", "diag", "full"),
        RUNTIME_PARAM
            ("generate_runtime_option_parameters",
             OptionType.compiler,
             Category.internal,
             true,
             "If enabled, generate parameters for runtime options. Should always be true for normal compilation."),
        WRITE_ITER_VARS
            ("write_iteration_variables_to_file",
             OptionType.compiler,
             Category.uncommon,
             false,
             "If enabled, two text files containing one iteration variable name per row is written to disk. The " +
             "files contains the iteration variables for the DAE and the DAE initialization system respectively. " +
             "The files are output to the resource directory of the FMU."),
        ALG_FUNCS
             ("algorithms_as_functions",
              OptionType.compiler,
              Category.experimental,
              false,
              "If enabled, convert algorithm sections to function calls."),
        WRITE_TEARING_PAIRS
            ("write_tearing_pairs_to_file",
             OptionType.compiler,
             Category.uncommon,
             false,
             "If enabled, two text files containing tearing pairs is written to disk. The files contains the " +
             "tearing pairs for the DAE and the DAE initialization system respectively. The files are output to " +
             "the working directory."),
        CHECK_INACTIVE
            ("check_inactive_contitionals",
             OptionType.compiler,
             Category.user,
             false,
             "If enabled, check for errors in inactive conditional components when compiling. When using check mode, " +
             "this is always done."),
        IGNORE_WITHIN
            ("ignore_within",
             OptionType.compiler,
             Category.uncommon,
             false,
             "If enabled, ignore within clauses both when reading input files and when error-checking."),
        NLE_SOLVER
            ("nonlinear_solver",
             OptionType.compiler,
             Category.user,
             NonlinearSolver.KINSOL,
             "Decides which nonlinear equation solver to use. Alternatives are 'kinsol or 'minpack'.",
             NonlinearSolver.KINSOL, NonlinearSolver.MINPACK),
        GENERATE_EVENT_SWITCHES
            ("generate_event_switches",
             OptionType.compiler,
             Category.experimental,
             true,
             "If enabled, event generating expressions generates switches in the c-code. " +
             "Setting this option to false can give unexpected results."),
        RELATIONAL_TIME_EVENTS
            ("relational_time_events",
             OptionType.compiler,
             Category.user,
             true,
             "If enabled, then relational operators are allowed to generate time events."),
       BLOCK_FUNCTION_EXTRACTION
            ("enable_block_function_extraction",
             OptionType.compiler,
             Category.user,
             false,
             "Looks for function calls in blocks. If a function call in a block doesn't depend on " + 
             "the block in question, it is extracted from the block."),
        FUNCTION_INCIDENCE_CALC
            ("function_incidence_computation",
             OptionType.compiler,
             Category.uncommon,
             FunctionIncidenceCalc.NONE,
             "Controls how matching algorithm computes incidences for function call equations. " + 
             "Possible values: 'none', 'all'. With 'none' all outputs are assumed to depend " + 
             "on all inputs. With 'all' the compiler analyses the function to determine dependencies.",
             FunctionIncidenceCalc.NONE, FunctionIncidenceCalc.ALL),
        MAX_N_PROC
            ("max_n_proc",
             OptionType.compiler,
             Category.uncommon,
             4,
             "The maximum number of processes used during c-code compilation."),
        DYNAMIC_STATES
            ("dynamic_states",
             OptionType.compiler,
             Category.uncommon,
             true,
             "If enabled, dynamic states will be calculated and generated."),
        MODELICAPATH
            ("MODELICAPATH",
             OptionType.compiler,
             Category.internal,
             "",
             "The MODELICAPATH to use during compilation."),

        // Runtime options
        /*
         * Note: Two JUnit tests are affected by changes to runtime options:
         * ModelicaCompiler : TransformCanonicalTests.mo : TestRuntimeOptions1
         * ModelicaCBackEnd : CCodeGenTests.mo : TestRuntimeOptions1
         */
        RUNTIME_LOG_LEVEL
            ("log_level",
             OptionType.runtime, 
             Category.user, 
             RuntimeLogLevel.WARNING,
             "Log level for the runtime: 0 - none, 1 - fatal error, 2 - error, 3 - warning, 4 - info, 5 - verbose, 6 - debug.",
             RuntimeLogLevel.NONE, RuntimeLogLevel.MAXDEBUG),
        ENFORCE_BOUNDS
            ("enforce_bounds",
             OptionType.runtime, 
             Category.user,
             true,
             "If enabled, min / max bounds on variables are enforced in the equation blocks."),
        USE_JACOBIAN_EQUILIBRATION
            ("use_jacobian_equilibration",
             OptionType.runtime, 
             Category.uncommon,
             false,
             "If enabled, jacobian equilibration will be utilized in the equation block solvers to improve linear solver accuracy."),
        USE_NEWTON_FOR_BRENT
            ("use_newton_for_brent",
             OptionType.runtime, 
             Category.uncommon,
             true,
             "If enabled, a few Newton steps are computed to get a better initial guess for Brent."),
        ITERATION_VARIABLE_SCALING
            ("iteration_variable_scaling",
             OptionType.runtime, 
             Category.user,
             1,
             "Scaling mode for the iteration variables in the equation block solvers: "+
             "0 - no scaling, 1 - scaling based on nominals, 2 - utilize heuristic to guess nominal based on min, max, start, etc.",
             0, 2),
        RESIDUAL_EQUATION_SCALING
            ("residual_equation_scaling",
             OptionType.runtime, 
             Category.user,
             1,
             "Equations scaling mode in equation block solvers: " +
             "0 - no scaling, 1 - automatic scaling, 2 - manual scaling, 3 - hybrid.",
             0, 3),
        NLE_SOLVER_MIN_RESIDUAL_SCALING_FACTOR
            ("nle_solver_min_residual_scaling_factor",
             OptionType.runtime, 
             Category.user,
             1e-10,
             "Minimal scaling factor used by automatic and hybrid residual scaling algorithm.",
             1e-32, 1),
        NLE_SOLVER_MAX_RESIDUAL_SCALING_FACTOR
            ("nle_solver_max_residual_scaling_factor",
             OptionType.runtime, 
             Category.user,
             1e10,
             "Maximal scaling factor used by automatic and hybrid residual scaling algorithm.",
             1, 1e32),
        RESCALE_EACH_STEP
            ("rescale_each_step",
             OptionType.runtime, 
             Category.user,
             false,
             "If enabled, scaling will be updated at every step (only active if automatic scaling is used)."),
        RESCALE_AFTER_SINGULAR_JAC
            ("rescale_after_singular_jac",
             OptionType.runtime, 
             Category.user,
             true,
             "If enabled, scaling will be updated after a singular jacobian was detected (only active if automatic scaling is used)."),
        USE_BRENT_IN_1D
            ("use_Brent_in_1d",
             OptionType.runtime, 
             Category.user,
             true,
             "If enabled, Brent search will be used to improve accuracy in solution of 1D non-linear equations."),
        BLOCK_SOLVER_EXPERIMENTAL_MODE
            ("block_solver_experimental_mode",
             OptionType.runtime, 
             Category.experimental,
             0,
             "Activates experimental features of equation block solvers",
             0, 255),
        NLE_SOLVER_DEFAULT_TOL
            ("nle_solver_default_tol",
             OptionType.runtime, 
             Category.user,
             1e-10,
             "Default tolerance for the equation block solver.",
             1e-14, 1e-2),
        NLE_SOLVER_CHECK_JAC_COND
            ("nle_solver_check_jac_cond",
             OptionType.runtime, 
             Category.uncommon, 
             false,
             "If enabled, the equation block solver computes and log the jacobian condition number."),
             NLE_SOLVER_BRENT_IGNORE_ERROR
            ("nle_brent_ignore_error",
             OptionType.runtime, 
             Category.uncommon, 
             false,
             "If enabled, the Brent solver will ignore convergence failures."),
        NLE_SOLVER_MIN_TOL
            ("nle_solver_min_tol",
             OptionType.runtime, 
             Category.uncommon,
             1e-12,
             "Minimum tolerance for the equation block solver. Note that, e.g. default Kinsol tolerance is machine precision pwr 1/3, i.e. 1e-6.", 
             1e-14, 1e-6),
        NLE_SOLVER_TOL_FACTOR
            ("nle_solver_tol_factor",
             OptionType.runtime, 
             Category.uncommon,
             0.0001,
             "Tolerance safety factor for the equation block solver. Used when external solver specifies relative tolerance.",
             1e-6, 1.0),
        NLE_SOLVER_MAX_ITER
            ("nle_solver_max_iter",
             OptionType.runtime, 
             Category.uncommon,
             100,
             "Maximum number of iterations for the equation block solver.",
             2, 500),
        NLE_SOLVER_STEP_LIMIT_FACTOR
            ("nle_solver_step_limit_factor",
             OptionType.runtime, 
             Category.uncommon,
             10,
             "Factor limiting the step-size taken by the nonlinear solver.",
             0, 1e10),
        NLE_SOLVER_REGULARIZATION_TOLERANCE
            ("nle_solver_regularization_tolerance",
             OptionType.runtime, 
             Category.uncommon,
             -1,
             "Tolerance for deciding when regularization should be activated (i.e. when condition number > reg tol).",
             -1, 1e20),
        NLE_SOLVER_NOMINALS_AS_FALLBACK
            ("nle_solver_use_nominals_as_fallback",
             OptionType.runtime, 
             Category.uncommon,
             false,
             "If enabled, the nominal values will be used as initial guess to the solver if initialization failed."),
        EVENTS_DEFAULT_TOL
            ("events_default_tol",
              OptionType.runtime, 
             Category.uncommon,
              1e-10,
              "Default tolerance for the event iterations.",
              1e-14, 1e-2),
        EVENTS_TOL_FACTOR
            ("events_tol_factor",
             OptionType.runtime, 
             Category.uncommon,
             0.0001,
             "Tolerance safety factor for the event indicators. Used when external solver specifies relative tolerance.",
             1e-6, 1.0),
        BLOCK_JACOBIAN_CHECK
            ("block_jacobian_check",
             OptionType.runtime, 
             Category.debug,
             false,
             "Compares the analytic block jacobians with the finite difference block jacobians during block evaluation. " + 
             "An error is given if the relative error is to big."),
        BLOCK_JACOBIAN_CHECK_TOL
            ("block_jacobian_check_tol",
             OptionType.runtime, 
             Category.debug,
             1e-6,
             "Specifies the relative tolerance for block jacobian check.",
             1e-12, 1.0),
        CS_SOLVER
            ("cs_solver",
             OptionType.runtime, 
             Category.user,
             0,
             "Specifies the internal solver used in Co-Simulation. 0 - CVode, 1 - Euler.",
             0, 1),
        CS_REL_TOL
            ("cs_rel_tol",
             OptionType.runtime, 
             Category.user,
             1e-6,
             "Tolerance for the adaptive solvers in the Co-Simulation case.",
             1e-14, 1.0),
        CS_STEP_SIZE
            ("cs_step_size",
             OptionType.runtime, 
             Category.user,
             1e-3,
             "Step-size for the fixed-step solvers in the Co-Simulation case."),
        RUNTIME_LOG_TO_FILE
            ("runtime_log_to_file",
             OptionType.runtime, 
             Category.user,
             false,
             "If enabled, log messages from the runtime are written directly to a file, besides passing it through the FMU interface. " +
             "The log file name is generated based on the FMU name."),
        ;

        public String key;
        public OptionType type;
        public Category cat;
        public String desc;
        public Object val;
        public Object[] lim;

        private Default(String k, OptionType t, Category c, Object v, String d, Object... l) {
            key = k;
            type = t;
            desc = d;
            val = v;
            cat = c;
            lim = (l != null && l.length > 0) ? l : null;
        }

        private Default(String k, OptionType t, Category c, Object v, String d) {
            this(k, t, c, v, d, (Object[]) null);
        }

        private Default(String k, OptionType t, Category c, boolean v, String d) {
            this(k, t, c, new Boolean(v), d);
        }

        private Default(String k, OptionType t, Category c, double v, String d, double min, double max) {
            this(k, t, c, new Double(v), d, new Object[] {min, max});
        }

        private Default(String k, OptionType t, Category c, int v, String d, int min, int max) {
            this(k, t, c, new Integer(v), d, new Object[] {min, max});
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

    private Map<String,Option> optionsMap;

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

    private List<Option> sortedOptions() {
        List<Option> opts = new ArrayList<OptionRegistry.Option>(optionsMap.values());
        Collections.sort(opts);
        return opts;
    }

    /**
     * Export all options as XML.
     * 
     * @param outStream  the stream to write to
     * @param maxCat     the maximum option category to display (as per order they are defined in)
     */
    public void exportXML(PrintStream outStream, Category maxCat) {
        XMLPrinter out = new XMLPrinter(outStream, "", "    ");
        out.enter("OptionsRegistry");
        out.enter("Options");
        for (Option o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportXML(out);
            }
        }
        out.exit(2);
    }

    /**
     * Export all options as a plain text table.
     * 
     * @param out     the stream to write to
     * @param maxCat  the maximum option category to display (as per order they are defined in)
     */
    public void exportPlainText(PrintStream out, Category maxCat) {
        out.format("%-30s  %-15s\n    Description\n", "Name", "Default value");
        for (Option o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportPlainText(out);
            }
        }
    }

    private static final String DB_TAB_IND = "        ";
    private static final String DB_TAB_ID = "models_tab_compiler_options";
    private static final String DB_TAB_TITLE = "Compiler options";
    private static final DocBookColSpec[] DB_TAB_COLS = new DocBookColSpec[] {
        new DocBookColSpec("Option",                      "left", "para",  "2.2*"),
        new DocBookColSpec("Option type / Default value", "left", "def",   "1.2*"),
        new DocBookColSpec("Description",                 "left", "descr", "3.6*")
    };

    /**
     * Export all options as a table in DockBook format.
     * 
     * @param outStream  the stream to write to
     * @param maxCat     the maximum option category to display (as per order they are defined in)
     */
    public void exportDocBook(PrintStream outStream, Category maxCat) {
        DocBookPrinter out = new DocBookPrinter(outStream, DB_TAB_IND);
        out.enter("table", "xml:id", DB_TAB_ID);
        out.oneLine("title", DB_TAB_TITLE);
        out.enter("tgroup", "cols", DB_TAB_COLS.length);
        for (DocBookColSpec s : DB_TAB_COLS) {
            s.printColspec(out);
        }
        out.enter("thead");
        out.enter("row");
        for (DocBookColSpec s : DB_TAB_COLS) {
            s.printTitle(out);
        }
        out.exit(2);
        out.enter("tbody");
        for (Option o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportDocBook(out);
            }
        }
        out.exit(3);
    }

    private static class XMLPrinter {
        private Stack<Entry> stack;
        private String indent;
        private PrintStream out;
        private String indentStep;
        
        public XMLPrinter(PrintStream out, String indent, String indentStep) {
            stack = new Stack<Entry>();
            this.indent = indent;
            this.out = out;
            this.indentStep = indentStep;
        }
        
        public void enter(String name, Object... args) {
            stack.push(new Entry(indent, name));
            printHead(name, args);
            out.println('>');
            indent = indent + indentStep;
        }
        
        public void exit(int n) {
            for (int i = 0; i < n; i++) {
                exit();
            }
        }
        
        public void exit() {
            Entry e = stack.pop();
            indent = e.indent;
            out.format("%s</%s>\n", indent, e.name);
        }
        
        public void single(String name, Object... args) {
            printHead(name, args);
            out.print(" />\n");
        }
        
        public void oneLine(String name, String cont, Object... args) {
            printHead(name, args);
            out.format(">%s</%s>\n", cont, name);
        }

        public void text(String text, int width) {
            wrapText(out, text, indent, width);
        }
        
        public String surround(String str, String tag) {
            return String.format("<%s>%s</%s>", tag, str, tag);
        }
        
        private void printHead(String name, Object... args) {
            out.format("%s<%s", indent, name);
            for (int i = 0; i < args.length - 1; i += 2) {
                out.format(" %s=\"%s\"", args[i], args[i + 1]);
            }
        }
        
        private static class Entry {
            public final String indent;
            public final String name;
            
            private Entry(String indent, String name) {
                this.indent = indent;
                this.name = name;
            }
        }
    }

    private static class DocBookPrinter extends XMLPrinter {
        private static final Pattern PREPARE_PAT = 
                Pattern.compile("(?<=^|[^-a-zA-Z_])('[a-z]+'|true|false|[a-z]+(_[a-z]+)+)(?=$|[^-a-zA-Z_])");
        
        public DocBookPrinter(PrintStream out, String indent) {
            super(out, indent, "  ");
        }
        
        public String lit(String str) {
            return surround(str, "literal");
        }
        
        public String prepare(String str) {
            return PREPARE_PAT.matcher(str).replaceAll("<literal>$1</literal>");
        }
    }

    private static class DocBookColSpec {
        private String title;
        private String align;
        private String name;
        private String width;
        
        public DocBookColSpec(String title, String align, String name, String width) {
            this.title = title;
            this.align = align;
            this.name = name;
            this.width = width;
        }
        
        public void printColspec(DocBookPrinter out) {
            out.single("colspec", "align", align, "colname", "col-" + name, "colwidth", width);
        }
        
        public void printTitle(DocBookPrinter out) {
            out.oneLine("entry", title, "align", "center");
        }
    }

    private static void doWrap(Writer out, String text, String prefix, String partSep, String suffix, char splitAt, int width) {
        try {
            if (width == 0) {
                width = Integer.MAX_VALUE;
            }
            int start = 0;
            int end = width;
            int len = text.length();
            while (end < len) {
                while (end > start && text.charAt(end) != splitAt)
                    end--;
                out.append(prefix);
                if (end <= start) {
                    out.append(text.substring(start, start + width - 1));
                    start += width - 1;
                    out.append('-');
                } else {
                    out.append(text.substring(start, end + 1));
                    start = end + 1;
                }
                out.append(suffix);
                out.append(partSep);
                end = start + width;
            }
            out.append(prefix);
            out.append(text.substring(start));
            out.append(suffix);
        } catch (IOException e) {
            // Not handled - left to caller to discover on next write
        }
    }

    private static void wrapText(PrintStream out, String text, String indent, int width) {
        doWrap(new OutputStreamWriter(out), text, indent, "", "\n", ' ', width);
    }

    private static String wrapUnderscoreName(String text, int width) {
        StringWriter out = new StringWriter();
        doWrap(out , text, "", " ", "", '_', width);
        return out.toString();
    }

    protected void defaultOption(Default o) {
        if (o.val instanceof Integer) {
            if (o.lim != null)
                createIntegerOption(o.key, o.type, o.cat, o.desc, iv(o.val), iv(o.lim[0]), iv(o.lim[1]));
            else
                createIntegerOption(o.key, o.type, o.cat, o.desc, iv(o.val));
        } else if (o.val instanceof String) {
            String[] lim = (o.lim == null) ? null : Arrays.copyOf(o.lim, o.lim.length, String[].class);
            createStringOption(o.key, o.type, o.cat, o.desc, (String) o.val, lim);
        } else if (o.val instanceof Double) {
            if (o.lim != null)
                createRealOption(o.key, o.type, o.cat, o.desc, dv(o.val), dv(o.lim[0]), dv(o.lim[1]));
            else
                createRealOption(o.key, o.type, o.cat, o.desc, dv(o.val));
        } else if (o.val instanceof Boolean) {
            createBooleanOption(o.key, o.type, o.cat, o.desc, bv(o.val));
        }
    }

    private String unknownOptionMessage(String key) {
        String[] parts = key.split("_");
        for (int i = 0; i < parts.length; i++)
            parts[i] = parts[i].replaceAll("(ion|ing|s|e)$", "");
        String best = null;
        int bestScore = 0;
        for (Option opt : sortedOptions()) {
            String name = opt.getKey();
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
        createIntegerOption(key, OptionType.compiler, Category.internal, description, defaultValue);
    }

    protected void createIntegerOption(String key, OptionType type, Category cat, String description, int defaultValue) {
        optionsMap.put(key, new IntegerOption(key, type, cat, description, defaultValue));
    }

    protected void createIntegerOption(String key, String description, int defaultValue, int min, int max) {
        createIntegerOption(key, OptionType.compiler, Category.internal, description, defaultValue, min, max);
    }

    protected void createIntegerOption(String key, OptionType type, Category cat, String description, int defaultValue, int min, int max) {
        optionsMap.put(key, new IntegerOption(key, type, cat, description, defaultValue, min, max));
    }


    public void addIntegerOption(String key, int value) {
        addIntegerOption(key, OptionType.compiler, Category.internal, value, "");
    }

    public void addIntegerOption(String key, int value, String description) {
        addIntegerOption(key, OptionType.compiler, Category.internal, value, description);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, int value, String description) {
        if (findIntegerOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createIntegerOption(key, type, cat, description, value);
    }

    public void addIntegerOption(String key, int value, String description, int min, int max) {
        addIntegerOption(key, OptionType.compiler, Category.internal, value, description, min, max);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, int value, String description, int min, int max) {
        if (findIntegerOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createIntegerOption(key, type, cat, description, value, min, max);
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
        createStringOption(key, OptionType.compiler, Category.internal, description, defaultValue, vals);
    }

    protected void createStringOption(String key, OptionType type, Category cat, String description, String defaultValue, String[] vals) {
        optionsMap.put(key, new StringOption(key, type, cat, description, defaultValue, vals));
    }

    public void addStringOption(String key, String value) {
        addStringOption(key, OptionType.compiler, Category.internal, value, "", null);
    }

    public void addStringOption(String key, String value, String description) {
        addStringOption(key, OptionType.compiler, Category.internal, value, description, null);
    }

    public void addStringOption(String key, OptionType type, Category cat, String value, String description) {
        addStringOption(key, type, cat, value, description, null);
    }

    public void addStringOption(String key, String value, String description, String[] allowed) {
        addStringOption(key, OptionType.compiler, Category.internal, value, description, allowed);
    }

    public void addStringOption(String key, OptionType type, Category cat, String value, String description, String[] allowed) {
        if (findStringOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createStringOption(key, type, cat, description, value, allowed);
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
        createRealOption(key, OptionType.compiler, Category.internal, description, defaultValue);
    }

    protected void createRealOption(String key, OptionType type, Category cat, String description, double defaultValue) {
        optionsMap.put(key, new RealOption(key, type, cat, description, defaultValue));
    }

    protected void createRealOption(String key, String description, double defaultValue, double min, double max) {
        createRealOption(key, OptionType.compiler, Category.internal, description, defaultValue, min, max);
    }

    protected void createRealOption(String key, OptionType type, Category cat, String description, double defaultValue, double min, double max) {
        optionsMap.put(key, new RealOption(key, type, cat, description, defaultValue, min, max));
    }

    public void addRealOption(String key, double value) {
        addRealOption(key, OptionType.compiler, Category.internal, value, "");
    }

    public void addRealOption(String key, double value, String description) {
        addRealOption(key, OptionType.compiler, Category.internal, value, description);
    }

    public void addRealOption(String key, OptionType type, Category cat, double value, String description) {
        if (findRealOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createRealOption(key, type, cat, description, value);
    }

    public void addRealOption(String key, double value, String description, double min, double max) {
        addRealOption(key, OptionType.compiler, Category.internal, value, description, min, max);
    }

    public void addRealOption(String key, OptionType type, Category cat, double value, String description, double min, double max) {
        if (findRealOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createRealOption(key, type, cat, description, value, min, max);
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
        createBooleanOption(key, OptionType.compiler, Category.internal, description, defaultValue);
    }

    protected void createBooleanOption(String key, OptionType type, Category cat, String description, boolean defaultValue) {
        optionsMap.put(key, new BooleanOption(key, type, cat, description, defaultValue));
    }



    public void addBooleanOption(String key, boolean value) {
        addBooleanOption(key, OptionType.compiler, Category.internal, value, "");
    }

    public void addBooleanOption(String key, boolean value, String description) {
        addBooleanOption(key, OptionType.compiler, Category.internal, value, description);
    }

    public void addBooleanOption(String key, OptionType type, Category cat, boolean value, String description) {
        if (findBooleanOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createBooleanOption(key, type, cat, description, value);
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
        return getTypeOptionKeys(OptionType.compiler);
    }

    public Collection<String> getRuntimeOptionKeys() {
        return getTypeOptionKeys(OptionType.runtime);
    }

    public Collection<String> getTypeOptionKeys(OptionType type) {
        return getFilteredOptionName(new TypeOptionFilter(type));
    }

    public Collection<String> getFilteredOptionName(OptionFilter filter) {
        List<String> res = new ArrayList<String>();
        for (Option o : sortedOptions())
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
            if (o instanceof StringOption) {
                setStringOption(key, ((StringOption) o).getValue(), o.getDescription(), true);
            } else if(o instanceof IntegerOption) {
                setIntegerOption(key, ((IntegerOption) o).getValue(), o.getDescription(), true);
            } else if(o instanceof RealOption) {
                setRealOption(key, ((RealOption) o).getValue(), o.getDescription(), true);
            } else if(o instanceof BooleanOption) {
                setBooleanOption(key, ((BooleanOption) o).getValue(), o.getDescription(), true);
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


    private abstract static class Option implements Comparable<Option> {
        protected final String key;
        private String description;
        private boolean descriptionChanged = false;
        private boolean defaultChanged = false;
        private OptionType type;
        private Category cat;

        public Option(String key, String description, OptionType type, Category cat) {
            this.key = key;
            this.description = description;
            this.type = type;
            this.cat = cat;
        }

        public void exportDocBook(DocBookPrinter out) {
            out.enter("row");
            out.oneLine("entry", out.lit(wrapUnderscoreName(key, 26)));
            out.oneLine("entry", String.format("%s / %s", out.lit(getType()), out.lit(getValueForDoc())));
            out.oneLine("entry", out.prepare(description));
            out.exit();
        }

        public void exportPlainText(PrintStream out) {
            out.format("%-30s  %-15s\n", key, getValueForDoc());
            wrapText(out, description, "    ", 80);
        }

        public void exportXML(XMLPrinter out) {
            String type = getType();
            out.enter("Option", "type", type);
            String tag = capitalize(type) + "Attributes";
            if (description == null || description.equals("")) {
                out.single(tag, "key", key, "value", getValueString());
            } else {
                out.enter(tag, "key", key, "value", getValueString());
                out.enter("Description");
                out.text(description, 80);
                out.exit(2);
            }
            out.exit();
        }

        public abstract String getType();
        public abstract String getValueString();

        public String getKey() {
            return key;
        }

        public String getDescription() {
            return description;
        }

        public Category getCategory() {
            return cat;
        }

        public String getValueForDoc() {
            return getValueString();
        }

        public int compareTo(Option o) {
            int res = type.compareTo(o.type);
            if (res != 0)
                return res;
            res = cat.compareTo(o.cat);
            if (res != 0)
                return res;
            return key.compareTo(o.key);
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

        public IntegerOption(String key, OptionType type, Category cat, String description, int value) {
            this(key, type, cat, description, value, Integer.MIN_VALUE, Integer.MAX_VALUE);
        }

        public IntegerOption(String key, OptionType type, Category cat, String description, int value, int min, int max) {
            super(key, description, type, cat);
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

        public StringOption(String key, OptionType type, Category cat, String description, String value) {
            this(key, type, cat, description, value, null);
        }

        public StringOption(String key, OptionType type, Category cat, String description, String value, String[] vals) {
            super(key, description, type, cat);
            this.value = value;
            if (vals == null) {
                this.vals = null;
            } else {
                this.vals = new LinkedHashMap<String,String>(8);
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

        public String getValueForDoc() {
            return String.format("'%s'", value);
        }
    }

    private static class RealOption extends Option {
        protected double value;
        protected double min;
        protected double max;

        public RealOption(String key, OptionType type, Category cat, String description, double value) {
            this(key, type, cat, description, value, Double.MIN_VALUE, Double.MAX_VALUE);
        }

        public RealOption(String key, OptionType type, Category cat, String description, double value, double min, double max) {
            super(key, description, type, cat);
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

        public BooleanOption(String key, OptionType type, Category cat, String description, boolean value) {
            super(key, description, type, cat);
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
