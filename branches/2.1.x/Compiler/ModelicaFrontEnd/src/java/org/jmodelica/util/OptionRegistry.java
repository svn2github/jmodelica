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

import java.io.PrintStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.jmodelica.util.xml.DocBookColSpec;
import org.jmodelica.util.xml.DocBookPrinter;
import org.jmodelica.util.xml.StringUtil;
import org.jmodelica.util.xml.XMLPrinter;

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
    public abstract static class OptionContributor {
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

    /**
     * Extend this class and add an instance to the contributor list with 
     * {@link OptionRegistry#addRemover(OptionRemover)} to remove an option 
     * from the set of options. The preferred way to do this is by adding a static 
     * field in ModelicaCompiler that gets its value from a call to addRemover().
     */
    public abstract static class OptionRemover {
        /**
         * A list of the options to remove in the option registry when this remover is added.
         * 
         * @return  a list of the names of the options to remove.
         */
        public abstract String[] options();

        /**
         * Returns an object that uniquely identifies this contributor, to protect 
         * against the same contributor being added several times. One example is when 
         * Modelica and Optimica versions of compiler are loaded in the same JVM.
         * 
         * Recommended is a string literal in the jrag file.
         */
        public abstract Object identity();
    }

    public abstract static class Default<T> {
        public final Class<T> type;
        
        public Default(Class<T> type) {
            this.type = type;
        }
        
        public abstract T value();
    }

    public static class DefaultValue<T> extends Default<T> {
        private final T value;
        
        @SuppressWarnings("unchecked")
        public DefaultValue(T val) {
            super((Class<T>) val.getClass());
            value = val;
        }

        @Override
        public T value() {
            return value;
        }

        @Override
        public String toString() {
            return value.toString();
        }
    }

    public abstract class DefaultCopy<T> extends Default<T> {
        protected final String key;

        public DefaultCopy(String key, Class<T> type) {
            super(type);
            this.key = key;
        }
    }

    public class DefaultCopyInteger extends DefaultCopy<Integer> {
        public DefaultCopyInteger(String key) {
            super(key, Integer.class);
        }

        @Override
        public Integer value() {
            return getIntegerOption(key);
        }
    }

    public class DefaultCopyReal extends DefaultCopy<Double> {
        public DefaultCopyReal(String key) {
            super(key, Double.class);
        }

        @Override
        public Double value() {
            return getRealOption(key);
        }
    }

    public class DefaultCopyString extends DefaultCopy<String> {
        public DefaultCopyString(String key) {
            super(key, String.class);
        }

        @Override
        public String value() {
            return getStringOption(key);
        }
    }

    public class DefaultCopyBoolean extends DefaultCopy<Boolean> {
        public DefaultCopyBoolean(String key) {
            super(key, Boolean.class);
        }

        @Override
        public Boolean value() {
            return getBooleanOption(key);
        }
    }

    public class DefaultInvertBoolean extends Default<Boolean> {
        private final Default<Boolean> op;

        public DefaultInvertBoolean(Default<Boolean> operand) {
            super(Boolean.class);
            op = operand;
        }

        public DefaultInvertBoolean(String key) {
            this(new DefaultCopyBoolean(key));
        }

        @Override
        public Boolean value() {
            return !op.value();
        }
        
    }

    private static java.util.List<OptionContributor> CONTRIBUTORS = new ArrayList<OptionContributor>();
    private static java.util.List<OptionRemover> REMOVERS = new ArrayList<OptionRemover>();

    private static java.util.Map<Object, OptionContributor> CONTRIBUTOR_IDENTITES = new LinkedHashMap<Object,OptionContributor>();
    private static java.util.Map<Object, OptionRemover> REMOVER_IDENTITIES = new LinkedHashMap<Object, OptionRemover>();
    
    /**
     * Adds a new options contributor.
     * 
     * @param oc
     *          The contributor
     * @return
     *          The contributor, for convenience.
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

    /**
     * Adds a new options remover.
     * 
     * @param or
     *          The remover
     * @return
     *          The remover, for convenience.
     */
    public static OptionRemover addRemover(OptionRemover or) {
        Object id = or.identity();
        OptionRemover old = REMOVER_IDENTITIES.get(id);
        if (old == null) {
            REMOVER_IDENTITIES.put(id, or);
            REMOVERS.add(or);
            return or;
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
    }
    public interface FunctionIncidenceCalc {
        public static final String NONE  = "none";
        public static final String ALL = "all";
    }
    public interface CCompilerFiles {
        public static final String NONE      = "none";
        public static final String FUNCTIONS = "functions";
        public static final String ALL       = "all";
    }
    public interface CCompilerFlags {
        public static final String O1 = ":O1";
        public static final String O2 = ":O2";
    }

    public enum OptionType { compiler, runtime }

    public enum Category { common, user, uncommon, experimental, debug, internal, deprecated }

    /**
     * The listing of options for:
     * <ul>
     * <li>Compiler options.</li>
     * <li>Runtime options.</li>
     * </ul>
     */
    private enum OptionSpecification {

        /* ================== *
         *  Compiler options. *
         * ================== */

        GENERATE_ONLY_INITIAL_SYSTEM 
            ("generate_only_initial_system", 
             OptionType.compiler, 
             Category.user,
             false, 
             "If enabled, then only the initial equation system will be generated."),
        TEARING_DIVISION_TOLERANCE
            ("tearing_division_tolerance",
             OptionType.compiler,
             Category.user,
             1e-10,
             "The minimum allowed size for a divisior constant when performing tearing."),
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
        ALLOW_NON_SCALAR_NESTED_BLOCKS
            ("allow_non_scalar_nested_blocks",
             OptionType.compiler,
             Category.uncommon,
             true,
             "If disabled, an error is given if there are nested blocks which are non-scalar."),
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
        GENERATE_SPARSE_BLOCK_JACOBIAN_THRESHOLD
        	("generate_sparse_block_jacobian_threshold",
        	 OptionType.compiler,
        	 Category.experimental,
        	 100,
        	 "Threshold for when a sparse Jacobian should be generated. If the number of torn variables"
        	 + "is less than the threshold a dense Jacobian is generated.",
        	 0,Integer.MAX_VALUE),
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
        FMU_TYPE
        	("fmu_type",
        	 OptionType.compiler,
        	 Category.internal,
        	 "",
        	 "Semicolon separated list of defines to set, e.g. FMUCS20."),
        EXTRA_LIB
            ("extra_lib_dirs", 
             OptionType.compiler, 
             Category.internal,
             "", 
             "The value of this option is appended to the MODELICAPATH " +
             "when searching for libraries. Deprecated."),
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
        ELIM_ALIAS_PARAM
            ("eliminate_alias_parameters", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "If enabled, then alias parameters are eliminated from the model."),
        ELIM_ALIAS_CONST
            ("eliminate_alias_constants",
             OptionType.compiler,
             Category.uncommon,
             true,
             "If enabled, then alias constants are eliminated from the model."),
        ELIM_LINEAR_EQNS
            ("eliminate_linear_equations",
             OptionType.compiler,
             Category.uncommon,
             true,
             "If enabled, then equations with linear sub expressions are substituted and eliminated."),
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
        MUNKRES_MAX_INCIDENCES
            ("munkres_max_incidences", 
             OptionType.compiler, 
             Category.deprecated,
             0, 
             "The maximum number of incidences that can be in a graph when solving a munkres problem. " +
             "A value of zero or less results in no limit."),
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
             FMIVersion.FMI10, FMIVersion.FMI20),
        EXPOSE_TEMP_VARS_IN_FMU 
            ("expose_temp_vars_in_fmu", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "If enabled, then all temporary variables are exposed in the FMU XML and accessable as ordinary variables"),
        VAR_SCALE 
            ("enable_variable_scaling", 
             OptionType.compiler, 
             Category.uncommon,
             false, 
             "If enabled, then the 'nominal' attribute will be used to scale variables in the model."),
        EVENT_SCALE
            ("event_indicator_scaling", 
             OptionType.compiler, 
             Category.experimental,
             false, 
             "If enabled, event indicators will be scaled with nominal heuristics"),
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
             true, 
             "If enabled, the compiler will include the name of the component where the error was found, if applicable."),
        FILTER_WARNINGS
            ("filter_warnings",
             OptionType.compiler,
             Category.user,
             "",
             "A comma separated list of warning identifiers that should be omitted from the logs."),
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
         DEBUG_SAN_CHECK 
            ("debug_sanity_check", 
             OptionType.compiler, 
             Category.debug,
             false,
             "If enabled, flat tree will be checked for consistency between transformation steps."),
        RUNTIME_PARAM
            ("generate_runtime_option_parameters",
             OptionType.compiler,
             Category.uncommon,
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
        INIT_NLE_SOLVER
            ("init_nonlinear_solver",
             OptionType.compiler,
             Category.user,
             NonlinearSolver.KINSOL,
             "Decides which nonlinear equation solver to use in the initial system. Alternatives are 'kinsol or 'minpack'.",
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
        EVENT_OUTPUT_VARS
            ("event_output_vars",
             OptionType.compiler,
             Category.user,
             false,
             "If enabled, output variables are generated for each generated event."),
        DISABLE_SMOOTH_EVENTS
            ("disable_smooth_events",
             OptionType.compiler,
             Category.experimental,
             false,
             "If enabled, no events will be generated for smooth operator if order equals to zero."),
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
        COPY_SOURCE_FILES_TO_FMU
            ("copy_source_files_to_fmu",
            OptionType.compiler,
            Category.user,
            false,
            "If enabled, the generated source files will be copied to the FMU."),
        CC_EXTRA_FLAGS_APPLIES_TO
            ("cc_extra_flags_applies_to",
            OptionType.compiler,
            Category.uncommon,
            CCompilerFiles.FUNCTIONS,
            "Parts of c-code to compile with extra compiler flags specified by ccompiler_extra_flags",
            CCompilerFiles.NONE,CCompilerFiles.FUNCTIONS,CCompilerFiles.ALL),
        CC_EXTRA_FLAGS
            ("cc_extra_flags",
            OptionType.compiler,
            Category.uncommon,
            CCompilerFlags.O1,
            "Optimization level for c-code compilation",
            CCompilerFlags.O1, CCompilerFlags.O2),
        CC_SPLIT_ELEMENT_LIMIT
            ("cc_split_element_limit",
            OptionType.compiler,
            Category.uncommon,
            1000,
            "When generating code for large systems, the code is split into multiple functions and files for performance reasons."
            + " This option controls how many scalar elements can be evaluated by a function. Value less than 1 indicates no split."),
        CC_SPLIT_FUNCTION_LIMIT
            ("cc_split_function_limit",
            OptionType.compiler,
            Category.uncommon,
            20,
            "When generating code for large systems, the code is split into multiple functions and files for performance reasons."
            + " This option controls how many functions can be generated in a file. Value less than 1 indicates no split."),
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
        COMPILER_VERSION
            ("compiler_version", 
             OptionType.compiler,
             Category.internal,
             "compiler_version_file_not_read",
             "The version string for the compiler. Uses default value during unit testing."),

        /* ================== *
         *  Runtime options.  *
         * ================== */

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
             "0 - no scaling, 1 - automatic scaling, 2 - manual scaling, 3 - hybrid, 4- aggressive automatic scaling, 5 - automatic rescaling at full Jacobian update",
             0, 5),
        NLE_SOLVER_EXIT_CRITERION
            ("nle_solver_exit_criterion",
             OptionType.runtime, 
             Category.user,
             3,
             "Exit criterion mode: " +
             "0 - step length and residual based, 1 - only step length based, 2 - only residual based, 3 - hybrid.",
             0, 3),
        NLE_JACOBIAN_UPDATE_MODE
            ("nle_jacobian_update_mode",
             OptionType.runtime, 
             Category.user,
             2,
             "Mode for how to update the Jacobian: " +
             "0 - full Jacobian, 1 - Broyden update, 2 - Reuse Jacobian.",
             0, 2),
        NLE_JACOBIAN_CALCULATION_MODE
            ("nle_jacobian_calculation_mode",
             OptionType.runtime, 
             Category.user,
             0,
             "Mode for how to calculate the Jacobian: " +
             "0 - onesided differences, 1 - central differences, 2 - central differences at bound, 3 - central differences at bound and 0, 4 - central differences in second Newton solve, 5 - central differences at bound in second Newton solve, 6 - central differences at bound and 0 in second Newton solve, 7 - central differences at small residual, 8- calculate Jacobian externally, 9 - Jacobian compresssion.",
             0, 9),
        NLE_JACOBIAN_FINITE_DIFFERENCE_DELTA
            ("nle_jacobian_finite_difference_delta",
             OptionType.runtime, 
             Category.user,
             1.490116119384766e-08,
             "Delta to use when calculating finite difference Jacobians.",
             2.220446049250313e-16, 1e-1),
        NLE_ACTIVE_BOUNDS_MODE
            ("nle_active_bounds_mode",
             OptionType.runtime, 
             Category.user,
             0,
             "Mode for how to handle active bounds: " +
             "0 - project Newton step at active bounds, 1 - use projected steepest descent direction.",
             0, 1),
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
        BLOCK_SOLVER_PROFILING
            ("block_solver_profiling",
             OptionType.runtime, 
             Category.uncommon,
             false,
             "If enabled, methods involved in solving an equation block will be timed."),
        BLOCK_SOLVER_EXPERIMENTAL_MODE
            ("block_solver_experimental_mode",
             OptionType.runtime, 
             Category.experimental,
             0,
             "Activates experimental features of equation block solvers",
             0, Integer.MAX_VALUE),
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
        NLE_SOLVER_MAX_ITER_NO_JACOBIAN
            ("nle_solver_max_iter_no_jacobian",
             OptionType.runtime, 
             Category.uncommon,
             10,
             "Maximum number of iterations without jacobian update. Value 1 means an update in every iteration.",
             1, 500),
        NLE_SOLVER_STEP_LIMIT_FACTOR
            ("nle_solver_step_limit_factor",
             OptionType.runtime, 
             Category.uncommon,
             10,
             "Factor limiting the step-size taken by the nonlinear block solver.",
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
             true,
             "If enabled, the nominal values will be used as initial guess to the solver if initialization failed."),
        NLE_SOLVER_LAST_INTEGRATOR_STEP
            ("nle_solver_use_last_integrator_step",
             OptionType.runtime, 
             Category.uncommon,
             true,
             "If enabled, the intial guess for the iteration variables will be set to the iteration variables from the last integrator step."),
        EVENTS_DEFAULT_TOL
            ("events_default_tol",
              OptionType.runtime, 
             Category.uncommon,
              1e-10,
              "Default tolerance for the event iterations.",
              1e-14, 1e-2),
        TIME_EVENTS_DEFAULT_TOL
            ("time_events_default_tol",
              OptionType.runtime, 
             Category.uncommon,
              2.2204460492503131E-014,
              "Default tolerance for the time event iterations.",
              0, 1.0),
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
        CS_EXPERIMENTAL_MODE
            ("cs_experimental_mode",
             OptionType.runtime, 
             Category.experimental,
             0,
             "Activates experimental features of CS ode solvers",
             0, Integer.MAX_VALUE),
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
        public Default<?> val;
        public Default<?> testDefault;
        public Object[] lim;

        private <T> OptionSpecification(String k, OptionType t, Category c, Default<T> v, Default<T> td,
                String d, Object[] l) {

            key = k;
            type = t;
            desc = d;
            val = v;
            cat = c;
            testDefault = td;
            lim = (l != null && l.length > 0) ? l : null;
        }

        private <T> OptionSpecification(String key, OptionType optionType, Category category, T defaultValue,
                T testDefault, String description) {

            this(key, optionType, category, new DefaultValue<T>(defaultValue), new DefaultValue<T>(testDefault),
                    description, null);
        }

        private <T> OptionSpecification(String k, OptionType t, Category c, Default<T> v, String d, Object[] l) {
            this(k, t, c, v, v, d, l);
        }

        private <T> OptionSpecification(String k, OptionType t, Category c, Default<T> v, String d) {
            this(k, t, c, v, d, new Object[] {});
        }

        private OptionSpecification(String k, OptionType t, Category c, String v, String d) {
            this(k, t, c, new DefaultValue<String>(v), d);
        }

        private OptionSpecification(String k, OptionType t, Category c, String v, String d, String... l) {
            this(k, t, c, new DefaultValue<String>(v), d, l);
        }

        private OptionSpecification(String k, OptionType t, Category c, DefaultValue<String> v, String d, String... l) {
            this(k, t, c, v, d, (Object[]) l);
        }

        private OptionSpecification(String k, OptionType t, Category c, boolean v, String d) {
            this(k, t, c, new DefaultValue<Boolean>(v), d);
        }

        private OptionSpecification(String k, OptionType t, Category c, double v, String d) {
            this(k, t, c, new DefaultValue<Double>(v), d);
        }

        private OptionSpecification(String k, OptionType t, Category c, double v, String d, double min, double max) {
            this(k, t, c, new DefaultValue<Double>(v), d, new Object[] {min, max});
        }

        private OptionSpecification(String k, OptionType t, Category c, DefaultValue<Double> v, String d, double min, double max) {
                this(k, t, c, v, d, new Object[] {min, max});
        }

        private OptionSpecification(String k, OptionType t, Category c, int v, String d) {
            this(k, t, c, new DefaultValue<Integer>(v), d);
        }

        private OptionSpecification(String k, OptionType t, Category c, int v, String d, int min, int max) {
            this(k, t, c, new DefaultValue<Integer>(v), d, new Object[] {min, max});
        }

        private OptionSpecification(String k, OptionType t, Category c, DefaultValue<Integer> v, String d, int min, int max) {
            this(k, t, c, v, d, new Object[] {min, max});
        }

        @Override
        public String toString() {
            return key;
        }
    }

    /**
     * Contributor for base options.
     */
    static {
        addContributor(
            new OptionContributor() {
                public void addOptions(OptionRegistry opt) {
                    for (OptionSpecification o : OptionSpecification.values()) {
                        opt.defaultOption(o);
                    }
                }

                public Object identity() {
                    return "org.jmodelica.util.OptionRegistry.BASE_CONTRIBUTOR";
                }
        });
    }

    protected Map<String, Option<?>> optionsMap;

    /**
     * Constructs an {@code OptionRegistry} instance by collecting the {@code Option}s
     * from each {@link OptionContributor}.
     */
    public OptionRegistry() {
        optionsMap = new HashMap<String, Option<?>>();
        for (OptionContributor oc : CONTRIBUTORS) {
            oc.addOptions(this);
        }
        for (OptionContributor oc : CONTRIBUTORS) {
            oc.modifyOptions(this);
        }
        for (OptionRemover remover : REMOVERS) {
            for (String option : remover.options()) {
                if (!optionsMap.containsKey(option)) {
                    throw new UnknownOptionException("Failure trying to remove non-existent option " + option + ".");
                }
                optionsMap.remove(option);
            }
        }
    }

    /**
     * Create a copy of this OptionRegistry.
     * 
     * @return
     *          a new {@code OptionRegistry} with the same options and settings as {@code this}.
     */
    public OptionRegistry copy() {
        OptionRegistry res = new OptionRegistry() {};
        res.copyAllOptions(this);
        return res;
    }

    @SuppressWarnings({
        "unchecked", "rawtypes"
    })
    private List<Option> sortedOptions() {
        List<Option> opts = new ArrayList<Option>(optionsMap.values());
        Collections.<Option> sort(opts);
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
        for (Option<?> o : sortedOptions()) {
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
        for (Option<?> o : sortedOptions()) {
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
        for (Option<?> o : sortedOptions()) {
            if (o.getCategory().compareTo(maxCat) <= 0) {
                o.exportDocBook(out);
            }
        }
        out.exit(3);
    }

    @SuppressWarnings("unchecked")
    protected void defaultOption(OptionSpecification o) {
        if (o.val.type == Integer.class) {
            if (o.lim != null)
                createIntegerOption(o.key, o.type, o.cat, o.desc, (Default<Integer>) o.val,
                        (Default<Integer>) o.testDefault, iv(o.lim[0]), iv(o.lim[1]));
            else
                createIntegerOption(o.key, o.type, o.cat, o.desc,
                        (Default<Integer>) o.val, (Default<Integer>) o.testDefault);
        } else if (o.val.type == String.class) {
            String[] lim = (o.lim == null) ? null : Arrays.copyOf(o.lim, o.lim.length, String[].class);
            createStringOption(o.key, o.type, o.cat, o.desc, (Default<String>) o.val,
                    (Default<String>) o.testDefault, lim);
        } else if (o.val.type == Double.class) {
            if (o.lim != null)
                createRealOption(o.key, o.type, o.cat, o.desc, (Default<Double>) o.val, (Default<Double>) o.testDefault,
                        dv(o.lim[0]), dv(o.lim[1]));
            else
                createRealOption(o.key, o.type, o.cat, o.desc, (Default<Double>) o.val, (Default<Double>) o.testDefault);
        } else if (o.val.type == Boolean.class) {
            createBooleanOption(o.key, o.type, o.cat, o.desc,
                    (Default<Boolean>) o.val, (Default<Boolean>) o.testDefault);
        }
    }

    protected String unknownOptionMessage(String key) {
        String[] parts = key.split("_");
        for (int i = 0; i < parts.length; i++)
            parts[i] = parts[i].replaceAll("(ion|ing|s|e)$", "");
        String best = null;
        int bestScore = 0;
        for (Option<?> opt : sortedOptions()) {
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

    /**
     * Checks whether or not an option with the specified key exists in this registry.
     * 
     * @param key
     *          The key to the option.
     * @return
     *          {@code true} if the option exists in this registry, {@code false} otherwise.
     */
    public boolean hasOption(String key) {
        return optionsMap.containsKey(key);
    }

    /** ================================================== **
     **  Addition, creation, and modification of options.  **
     **  via the {@code OptionRegistry} instance.          **
     ** ================================================== **/

    /* ========== *
     *  General.  *
     * ========== */

    /**
     * Sets the value of an option using the string representation of its new value.
     * 
     * @param key
     *          The key to the option.
     * @param value
     *          The string representation of the new value to set the option to.
     */
    public void setOption(String key, String value) {
        Option<?> o = optionsMap.get(key);
        if (o == null)
            throw new UnknownOptionException(unknownOptionMessage(key));
        o.setValue(value);
    }

    protected StringOption findStringOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof StringOption)
            return (StringOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of string type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    public Boolean isLimited(String key) {
        Option<?> o = optionsMap.get(key);
        if (o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.isLimited();
    }

    public String getDescription(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getDescription();
    }

    public OptionType getOptionType(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getOptionType();
    }

    public Category getCategory(String key){
        Option<?> o = optionsMap.get(key);
        if(o == null) {
            throw new UnknownOptionException(unknownOptionMessage(key));
        }
        return o.getCategory();
    }

    private Set<Map.Entry<String, Option<?>>> getAllOptions() {
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
        for (Option<?> o : sortedOptions())
            if (filter.filter(o))
                res.add(o.key);
        Collections.sort(res);
        return res;
    }

    /**
     * Copies all of a registry's options to {@code this}'.
     * 
     * @param registry
     *          The {@code OptionRegistry} from which to copy options.
     * @throws UnknownOptionException
     *          if an unknown option was found in {@code registry}.
     */
    public void copyAllOptions(OptionRegistry registry) throws UnknownOptionException{
        /*
         * Copy all options in parameter registry to this option registry and overwrite it if it already exists.
         */
        for (Map.Entry<String, Option<?>> entry : registry.getAllOptions()) {
            entry.getValue().copyTo(this, entry.getKey());
        }
    }

    /* ================== *
     *  Boolean options.  *
     * ================== */

    protected void createBooleanOption(String key, OptionType type, Category cat, String description,
            Default<Boolean> def, Default<Boolean> testDefault) {

        optionsMap.put(key, new BooleanOption(key, type, cat, description, def, testDefault));
    }

    public void addBooleanOption(String key, OptionType type, Category cat, boolean def, String description) {
        addBooleanOption(key, type, cat, def, def, description);
    }

    public void addBooleanOption(String key, OptionType type, Category cat, boolean def,
            boolean testDefault, String description) {

        addBooleanOption(key, type, cat, new DefaultValue<Boolean>(def),
                new DefaultValue<Boolean>(testDefault), description);
    }

    public void addBooleanOption(String key, OptionType type, Category cat, Default<Boolean> def,
            Default<Boolean> testDefault, String description) {

        if (findBooleanOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createBooleanOption(key, type, cat, description, def, testDefault);
    }


    public void setBooleanOption(String key, boolean value) {
        findBooleanOption(key, false).setValue(value);
    }

    public void setBooleanOptionDefault(String key, Default<Boolean> def) {
        findBooleanOption(key, false).setDefault(def);
    }

    public Boolean getBooleanOptionDefault(String key) {
        return findBooleanOption(key, false).getDefault();
    }

    public boolean getBooleanOption(String key) {
        return findBooleanOption(key, false).getValue();
    }

    public boolean isBooleanOption(String key) {
        return optionsMap.get(key) instanceof BooleanOption;
    }

    protected BooleanOption findBooleanOption(String key, boolean allowMissing) {
        Option<?> o = optionsMap.get(key);
        if (o instanceof BooleanOption)
            return (BooleanOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of boolean type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    /* ================== *
     *  Integer options.  *
     * ================== */

    protected void createIntegerOption(String key, OptionType type, Category cat,
            String description, Default<Integer> def, Default<Integer> testDefault) {

        optionsMap.put(key, new IntegerOption(key, type, cat, description, def, testDefault));
    }

    protected void createIntegerOption(String key, OptionType type, Category cat, String description,
            Default<Integer> def, Default<Integer> testDefault, int min, int max) {

        optionsMap.put(key, new IntegerOption(key, type, cat, description, def, testDefault, min, max));
    }

    public void addIntegerOption(String key, OptionType type, Category cat, int def, String description,
            int min, int max) {

        addIntegerOption(key, type, cat, def, def, description, min, max);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, int def,
            int testDefault, String description) {

        addIntegerOption(key, type, cat, new DefaultValue<Integer>(def),
                new DefaultValue<Integer>(testDefault), description);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, int def, int testDefault,
            String description, int min, int max) {

        addIntegerOption(key, type, cat, new DefaultValue<Integer>(def), new DefaultValue<Integer>(testDefault),
                description, min, max);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, Default<Integer> def,
            Default<Integer> testDefault, String description) {

        if (findIntegerOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createIntegerOption(key, type, cat, description, def, testDefault);
    }

    public void addIntegerOption(String key, OptionType type, Category cat, Default<Integer> def,
            Default<Integer> testDefault, String description, int min, int max) {

        if (findIntegerOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createIntegerOption(key, type, cat, description, def, testDefault, min, max);
    }

    public void setIntegerOption(String key, int value) {
        findIntegerOption(key, false).setValue(value);
    }

    public void setIntegerOptionDefault(String key, int def) {
        findIntegerOption(key, false).setDefault(new DefaultValue<Integer>(def));
    }

    public void setIntegerOptionDefault(String key, Default<Integer> def) {
        findIntegerOption(key, false).setDefault(def);
    }

    public int getIntegerOptionDefault(String key) {
        return findIntegerOption(key, false).getDefault();
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
        Option<?> o = optionsMap.get(key);
        if (o instanceof IntegerOption)
            return (IntegerOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of integer type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    /* =============== *
     *  Real options.  *
     * =============== */

    protected void createRealOption(String key, OptionType type, Category cat, String description,
            Default<Double> def, Default<Double> testDefault) {

        optionsMap.put(key, new RealOption(key, type, cat, description, def, testDefault));
    }

    protected void createRealOption(String key, OptionType type, Category cat, String description, Default<Double> def,
            Default<Double> testDefault, double min, double max) {

        optionsMap.put(key, new RealOption(key, type, cat, description, def, testDefault, min, max));
    }


    public void addRealOption(String key, OptionType type, Category cat, double def,
            double testDefault, String description) {

        addRealOption(key, type, cat, new DefaultValue<Double>(def),
                new DefaultValue<Double>(testDefault), description);
    }

    public void addRealOption(String key, OptionType type, Category cat, double def, double testDefault,
            String description, double min, double max) {

        addRealOption(key, type, cat, new DefaultValue<Double>(def), new DefaultValue<Double>(testDefault), description,
                min, max);
    }

    public void addRealOption(String key, OptionType type, Category cat, Default<Double> def,
            Default<Double> testDefault, String description) {

        if (findRealOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createRealOption(key, type, cat, description, def, testDefault);
    }

    public void addRealOption(String key, OptionType type, Category cat, Default<Double> def,
            Default<Double> testDefault, String description, double min, double max) {

        if (findRealOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createRealOption(key, type, cat, description, def, testDefault, min, max);
    }

    public void setRealOption(String key, double value) {
        findRealOption(key, false).setValue(value);
    }

    public void setRealOptionDefault(String key, double def) {
        findRealOption(key, false).setDefault(new DefaultValue<Double>(def));
    }

    public void setRealOptionDefault(String key, Default<Double> def) {
        findRealOption(key, false).setDefault(def);
    }

    public double getRealOptionDefault(String key) {
        return findRealOption(key, false).getDefault();
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
        Option<?> o = optionsMap.get(key);
        if (o instanceof RealOption)
            return (RealOption) o;
        if (o != null)
            throw new UnknownOptionException("Option: " + key + " is not of real type");
        if (allowMissing)
            return null;
        throw new UnknownOptionException(unknownOptionMessage(key));
    }

    public int getIntegerOptionMax(String key) {
        return findIntegerOption(key, false).getMax();
    }

    public int getIntegerOptionMin(String key) {
        return findIntegerOption(key, false).getMin();
    }

    public double getRealOptionMax(String key) {
        return findRealOption(key, false).getMax();
    }

    public double getRealOptionMin(String key) {
        return findRealOption(key, false).getMin();
    }

    /* ================= *
     *  String options.  *
     * ================= */

    protected void createStringOption(String key, OptionType type, Category cat, String description, Default<String> def,
            Default<String> testDefault, String[] vals) {

        optionsMap.put(key, new StringOption(key, type, cat, description, def, testDefault, vals));
    }

    public void addStringOption(String key, OptionType type, Category cat, String def, String description) {
        addStringOption(key, type, cat, def, def, description);
    }

    public void addStringOption(String key, OptionType type, Category cat, String def,
            String description, String[] allowed) {

        addStringOption(key, type, cat, new DefaultValue<String>(def), new DefaultValue<String>(def),
                description, allowed);
    }

    public void addStringOption(String key, OptionType type, Category cat, String def,
            String testDefault, String description) {

        addStringOption(key, type, cat, new DefaultValue<String>(def),
                new DefaultValue<String>(testDefault), description);
    }

    public void addStringOption(String key, OptionType type, Category cat, String def, String testDefault,
            String description, String[] allowed) {

        addStringOption(key, type, cat, new DefaultValue<String>(def), new DefaultValue<String>(testDefault),
                description, allowed);
    }

    public void addStringOption(String key, OptionType type, Category cat, Default<String> def,
            Default<String> testDefault, String description) {

        addStringOption(key, type, cat, def, testDefault, description, (String[]) null);
    }

    public void addStringOption(String key, OptionType type, Category cat, Default<String> def,
            Default<String> testDefault, String description, String[] allowed) {

        if (findStringOption(key, true) != null)
            throw new IllegalArgumentException("The option " + key + " already exists.");
        createStringOption(key, type, cat, description, def, testDefault, allowed);
    }

    public void setStringOption(String key, String value) {
        findStringOption(key, false).setValue(value);
    }

    public void setStringOptionDefault(String key, String def) {
        findStringOption(key, false).setDefault(new DefaultValue<String>(def));
    }

    public void setStringOptionDefault(String key, Default<String> def) {
        findStringOption(key, false).setDefault(def);
    }

    public String getStringOptionDefault(String key) {
        return findStringOption(key, false).getDefault();
    }

    public Set<String> getStringOptionAllowed(String key) {
        return findStringOption(key, false).getAllowed();
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

    /**
     * \brief Make the first letter in a string capital.
     * 
     * @param string
     *          The string to capitalize. 
     * @return
     *          {@code string} with its first character in upper case.
     */
    public static String capitalize(String string) {
        return string.substring(0, 1).toUpperCase() + string.substring(1);
    }

    /**
     * Base class for options.
     *
     * @param <T>
     *          The type of option ({@code Boolean}, {@code Double} (real), {@code Integer}, or {@code String}).
     */
    protected abstract static class Option<T> implements Comparable<Option<T>> {
        protected final String key;
        protected Default<T> defaultValue;
        protected Default<T> testDefault;
        protected T value;

        private OptionType type;
        private Category category;
        private String description;

        protected boolean isSet;
        private boolean descriptionChanged = false;
        private boolean defaultChanged = false;

        /**
         * Creates an option with an initial value, as well as a different default value to use when under test.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefault
         *          The option's default value when under test.
         * @param value
         *          The initial value of the option.
         */
        public Option(String key, OptionType optionType, Category category, String description,
                Default<T> defaultValue, Default<T> testDefault, T value) {

            this.key = key;
            this.description = description;
            this.type = optionType;
            this.category = category;
            this.value = value;
            this.defaultValue = defaultValue;
            this.testDefault = testDefault;
            this.isSet = false;
        }

        /* =========== *
         *  Abstract.  *
         * =========== */

        /**
         * Retrieves the name of the option's type.
         * 
         * @return
         *           the name of the option's type.
         */
        public abstract String getType();

        /**
         * Retrieves the string representation of the option's value.
         * 
         * @return
         *           the string representation of the option's value.
         */
        public abstract String getValueString();

        protected abstract void copyTo(OptionRegistry registry, String key);
        protected abstract void setValue(String string);

        /**
         * Resets the option, enabling resetting its value.
         */
        public void clear() {
            this.isSet = false;
        }

        /**
         * Prints the option's DocBook documentation entry.
         * 
         * @param out
         *          The {@link DocBookPrinter} to which to print this option's entry.
         */
        public void exportDocBook(DocBookPrinter out) {
            out.enter("row");
            
            out.enter("entry");
            out.printLiteral(StringUtil.wrapUnderscoreName(key, 26));
            out.exit();
            
            out.enter("entry");
            out.printLiteral(getType());
            out.text("/", 80);
            out.printLiteral(getValueForDoc());
            out.exit();
            
            out.printWrappedPreFormatedText("entry", description);
            
            out.exit();
        }

        /**
         * Prints a string representation of the option to a {@link PrintStream}.
         * 
         * @param out
         *          The print stream to which to print the option.
         */
        public void exportPlainText(PrintStream out) {
            out.format("%-30s  %-15s\n", key, getValueForDoc());
            StringUtil.wrapText(out, description, "    ", 80);
        }

        /**
         * Prints the option's XML entry.
         * 
         * @param out
         *          The {@link XMLPrinter} to which to print this option's entry.
         */
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

        /**
         * Retrieves the default value of this option.
         * 
         * @return
         *          the default value of this option.
         */
        public T getDefault() {
            return defaultValue.value();
        }

        /**
         * Sets the default value of this option.
         * 
         * @param newDefault
         *          the new default value of this option.
         */
        public void setDefault(Default<T> newDefault) {
            changeDefault();
            this.defaultValue = newDefault;
        }

        /**
         * Retrieves this option's current value.
         * 
         * @return
         *          this option's current value.
         */
        public T getValue() {
            return isSet ? value : defaultValue.value();
        }

        /**
         * Retrieves this option's current value when under test.
         * 
         * @return
         *          this option's current value when under test.
         */
        public T getTestValue() {
            return isSet ? value : testDefault.value();
        }

        /**
         * Sets this option's value to a new value.
         * 
         * @param value
         *          the new value to set the option to.
         */
        public void setValue(T value) {
            this.isSet = true;
            this.value = value;
        }

        /**
         * Retrieves the key to this option.
         * 
         * @return
         *          the key to this option.
         */
        public String getKey() {
            return key;
        }

        /**
         * Retrieves the description text of this option.
         * 
         * @return
         *          the description text of this option.
         */
        public String getDescription() {
            return description;
        }

        /**
         * Retrieves the option type of this option.
         * 
         * @return
         *          the option type of this option.
         */
        public OptionType getOptionType() {
            return type;
        }

        /**
         * Checks whether or not this option's possible values are limited.
         * 
         * @return
         *          {@code true} if this option's values are limited, {@code false} otherwise.
         */
        public Boolean isLimited() {
            return false;
        }

        /**
         * Retrieves this option's category.
         * 
         * @return
         *          this option's category.
         */
        public Category getCategory() {
            return category;
        }

        /**
         * Retrieves the option values' string representation as to be used within documentation.
         * 
         * @return
         *          a string of the option values' representation as to be used within documentation.
         */
        public String getValueForDoc() {
            return getValueString();
        }

        @Override
        public int compareTo(Option<T> o) {
            int res = type.compareTo(o.type);
            if (res != 0) {
                return res;
            }
            if ((res = category.compareTo(o.category)) != 0) {
                return res;
            }
            return key.compareTo(o.key);
        }

        /**
         * Sets a new description for this option.
         * 
         * @param newDescription
         *          The new description of this option.
         */
        public void changeDescription(String newDescription) {
            if (descriptionChanged)
                throw new UnsupportedOperationException("Description of " + key + " has already been changed.");
            descriptionChanged = true;
            this.description = newDescription;
        }

        @Override
        public String toString() {
            return "\'"+key+"\': " + description; 
        }

        protected void invalidValue(Object value, String allowedMessage) {
            throw new InvalidOptionValueException("Option '" + key + "' does not allow the value '" +
                    value + "'" + allowedMessage);
        }

        protected void changeDefault() {
            if (defaultChanged) {
                throw new IllegalArgumentException("Default value for " + key + " has already been changed.");
            }
            defaultChanged = true;
        }
    }

    private static class IntegerOption extends Option<Integer> {
        private int min;
        private int max;

        /**
         * Creates an option for real values.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefeault
         *          The option's default value when under test.
         */
        public IntegerOption(String key, OptionType type, Category category, String description,
                Default<Integer> defaultValue, Default<Integer> testDefault) {

            this(key, type, category, description, defaultValue, testDefault, Integer.MIN_VALUE, Integer.MAX_VALUE);
        }

        /**
         * Creates an option for real values.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefeault
         *          The option's default value when under test.
         * @param min
         *          The minimum allowed value for this option.
         * @param max
         *          The maximum allowed value for this option.
         */
        public IntegerOption(String key, OptionType type, Category category, String description, 
                Default<Integer> defaultValue, Default<Integer> testDefault, int min, int max) {

            super(key, type, category, description, defaultValue, testDefault, null);
            this.min = min;
            this.max = max;
        }

        @Override
        public void setValue(Integer value) {
            if (value < min || value > max) {
                invalidValue(value, minMaxStr());
            }
            super.setValue(value);
        }

        @Override
        protected void setValue(String str) {
            try {
                setValue(Integer.parseInt(str));
            } catch (NumberFormatException e) {
                invalidValue(str, ", expecting integer value" + minMaxStr());
            }
        }

        private String minMaxStr() {
            return (min == Integer.MIN_VALUE ? "" : ", min: " + min) + (max == Integer.MAX_VALUE ? "" : ", max: " + max);
        }

        /**
         * Retrieves the minimum allowed value for this option.
         * 
         * @return
         *          the minimum allowed value for this option.
         */
        public int getMin() {
            return min;
        }

        /**
         * Retrieves the maximum allowed value for this option.
         * 
         * @return
         *          the maximum allowed value for this option.
         */
        public int getMax() {
            return max;
        }

        @Override
        public Boolean isLimited() {
            return (min != Integer.MIN_VALUE) || (max != Integer.MAX_VALUE);
        }

        /**
         * Lowers the minimum allowed value for this option. Will not raise it.
         * 
         * @param val
         *          The new minimum allowed value.
         */
        public void expandMin(int val) {
            if (val < min)
                min = val;
        }

        /**
         * Raises the maximum allowed value for this option. Will not lower it.
         * 
         * @param val
         *          The new minimum allowed value.
         */
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
            return Integer.toString(getValue());
        }

        @Override
        protected void copyTo(OptionRegistry reg, String key) {
            if (!reg.hasOption(key)) {
                reg.addIntegerOption(key, getOptionType(), getCategory(), defaultValue, testDefault, getDescription(),
                        min, max);
            }
            if (isSet) {
                reg.setIntegerOption(key, value);
            }
        }

    }

    private static class StringOption extends Option<String> {
        protected Map<String,String> values;
        private String[] valueArray;

        /**
         * Creates an option for string values.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefault
         *          The option's default value when under test.
         * @param values
         *          The option's possible values (settings).
         */
        public StringOption(String key, OptionType type, Category category, String description,
                Default<String> defaultValue, Default<String> testDefault, String[] values) {

            super(key, type, category, description, defaultValue, testDefault, null);

            this.value = null;
            if (values == null) {
                this.values = null;
            } else {
                this.values = new LinkedHashMap<String,String>(8);
                for (String v : values)
                    this.values.put(v, v);
            }
            valueArray = values;
        }

        @Override
        public void setValue(String value) {
            if (values != null) {
                String v = values.get(value);
                if (v != null) {
                    this.value = v;
                    isSet = true;
                    return;
                }
                StringBuilder buf = new StringBuilder(", allowed values: ");
                Object[] arr = values.keySet().toArray();
                Arrays.sort(arr);
                buf.append(Arrays.toString(arr).substring(1));
                invalidValue(value, buf.substring(0, buf.length() - 1));
            } else {
                this.value = value;
                isSet = true;
            }
        }

        @Override
        public String getDefault() {
            if (values != null) {
                String d = defaultValue.value();
                String v = values.get(d);
                return (v == null) ? d : v;
            } else {
                return defaultValue.value();
            }
        }

        /**
         * Allows an additional value (setting) for this option.
         * 
         * @param value
         *          The value to allow.
         * @return
         *          the value to allow.
         */
        public String addAllowed(String value) {
            if (values == null)
                throw new IllegalArgumentException("This option allows any value.");
            if (values.containsKey(value)) {
                return values.get(value);
            } else {
                values.put(value, value);
                return value;
            }
        }

        /**
         * Retrieves the allowed values (settings) for this option.
         * 
         * @return
         *          the allowed values for this option.
         */
        public Set<String> getAllowed() {
            if (values == null) {
                return Collections.unmodifiableSet(Collections.<String> emptySet());
            }
            return Collections.<String> unmodifiableSet(values.keySet());
        }

        @Override
        public String getType() {
            return "string";
        }

        @Override
        public String getValueString() {
            return getValue();
        }

        /**
         * Retrieves the documentation string for this option's current value.
         */
        public String getValueForDoc() {
            return (getValue() == null) ? "null" : String.format("'%s'", getValue());
        }

        @Override
        protected void copyTo(OptionRegistry reg, String key) {
            if (!reg.hasOption(key)) {
                reg.addStringOption(key, getOptionType(), getCategory(), defaultValue, testDefault,
                        getDescription(), valueArray);
            }
            if (isSet) {
                reg.setStringOption(key, value);
            }
        }

    }

    private static class RealOption extends Option<Double> {
        protected double min;
        protected double max;

        /**
         * Creates an option for real values.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefault
         *          The option's default value when under test.
         */
        public RealOption(String key, OptionType type, Category category, String description,
                Default<Double> defaultValue, Default<Double> testDefault) {

            this(key, type, category, description, defaultValue, testDefault, Double.MIN_VALUE, Double.MAX_VALUE);
        }

        /**
         * Creates an option for real values.
         * 
         * @param key
         *          The key to (name of) the option.
         * @param type
         *          The type of option.
         * @param category
         *          The category of the option.
         * @param description
         *          A description of the option.
         * @param defaultValue
         *          The option's default value.
         * @param testDefault
         *          The option's default value when under test.
         * @param min
         *          The minimum allowed value for this option.
         * @param max
         *          The maximum allowed value for this option.
         */
        public RealOption(String key, OptionType type, Category category, String description,
                Default<Double> defaultValue, Default<Double> testDefault, double min, double max) {

            super(key, type, category, description, defaultValue, testDefault, 0.0);
            this.min = min;
            this.max = max;
        }

        @Override
        public void setValue(Double d) {
            this.isSet = true;
            this.value = d.doubleValue();
        }

        @Override
        protected void setValue(String str) {
            try {
                setValue(Double.parseDouble(str));
            } catch (NumberFormatException e) {
                invalidValue(str, ", expecting integer value" + minMaxStr());
            }
        }

        /**
         * Sets the value for this option.
         * <p>
         * This method is required to avoid auto-boxing {@code double}s to {@link Double} and lose precision.
         */
        public void setValue(double value) {
            if (value < min || value > max) {
                invalidValue(value, minMaxStr());
            }
            this.isSet = true;
            this.value = value;
        }

        private String minMaxStr() {
            return (min == Double.MIN_VALUE ? "" : ", min: " + min) + (max == Double.MAX_VALUE ? "" : ", max: " + max);
        }

        /**
         * Retrieves the minimum allowed value for this option.
         * 
         * @return
         *          the minimum allowed value for this option.
         */
        public double getMin() {
            return min;
        }

        /**
         * Retrieves the maximum allowed value for this option.
         * 
         * @return
         *          the maximum allowed value for this option.
         */
        public double getMax() {
            return max;
        }

        @Override
        public Boolean isLimited() {
            return (min != Double.MIN_VALUE) || (max != Double.MAX_VALUE);
        }

        /**
         * Lowers the minimum allowed value for this option. Will not raise it.
         * 
         * @param val
         *          The new minimum allowed value.
         */
        public void expandMin(double val) {
            if (val < min)
                min = val;
        }

        /**
         * Raises the maximum allowed value for this option. Will not lower it.
         * 
         * @param val
         *          The new maximum allowed value.
         */
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
            return Double.toString(getValue());
        }

        @Override
        public String getValueForDoc() {
            String raw = getValueString();
            String round = String.format((Locale) null, "%.2E", getValue());
            return (round.length() < raw.length()) ? round : raw;
        }


        @Override
        protected void copyTo(OptionRegistry reg, String key) {
            if (!reg.hasOption(key)) {
                reg.addRealOption(key, getOptionType(), getCategory(), defaultValue, testDefault,
                        getDescription(), min, max);
            }
            if (isSet) {
                reg.setRealOption(key, value);
            }
        }

    }

    private static class BooleanOption extends Option<Boolean> {

        public BooleanOption(String key, OptionType type, Category cat, String description,
                Default<Boolean> def, Default<Boolean> testDefault) {

            super(key, type, cat, description, def, testDefault, false);
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

        @Override
        public String getType() {
            return "boolean";
        }

        @Override
        public String getValueString() {
            return Boolean.toString(getValue());
        }

        @Override
        protected void copyTo(OptionRegistry reg, String key) {
            if (!reg.hasOption(key)) {
                reg.addBooleanOption(key, getOptionType(), getCategory(), defaultValue, testDefault, getDescription());
            }
            if (isSet) {
                reg.setBooleanOption(key, value);
            }
        }

    }

    public interface OptionFilter {
        public boolean filter(Option<?> o);
    }

    public class TypeOptionFilter implements OptionFilter {
        private OptionType type;

        public TypeOptionFilter(OptionType t) {
            type = t;
        }

        public boolean filter(Option<?> o) {
            return o.type == type;
        }
    }

    public static final OptionFilter NULL_OPTION_FILTER = new OptionFilter() {
        public boolean filter(Option<?> o) {
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
