/********** ModelicaCasADi::Model **********/
%feature("docstring") ModelicaCasADi::Model::Model "
Creates a Model, instantiated without any arguments. 
";

%feature("docstring") ModelicaCasADi::Model::addVariable "
Adds a variable to the Model. Variables are assigned a VariableType if 
they do not have on set. 

Parameters::

    Variable --
        A Variable

";

%feature("docstring") ModelicaCasADi::Model::setTimeVariable "
Sets the time variable for this Model. Note that this variable is set
automatically when models are transferred.

Parameters::

    MX --
        A MX

";

%feature("docstring") ModelicaCasADi::Model::getTimeVariable "
Returns this model's time variable. 

Returns::

    MX --
        A MX

";

%feature("docstring") ModelicaCasADi::Model::addInitialEquation "
Adds an initial equation to the Model

Parameters::

    Equation --
        An Equation
";

%feature("docstring") ModelicaCasADi::Model::addDaeEquation "
Adds an equation to the Model

Parameters::

    Equation --
        An Equation

";

%feature("docstring") ModelicaCasADi::Model::setModelFunctionByItsName "
Sets a ModelFunction in the Model. ModelFunctions must have unique names,
and if there is one with name equal to the one passed in it is thrown away. 

Parameters::

    ModelFunction --
        A ModelFunction

";

%feature("docstring") ModelicaCasADi::Model::addNewVariableType "
Adds a new VariableType. VariableTypes are singletons and all variable 
types must have unique names.

Parameters::

    VariableType --
        A VariableType

";

%feature("docstring") ModelicaCasADi::Model::getVariableTypeByName "
Get a VariableType with a certain name in the Model.

Parameters::

    String --
        The name of the VariableType

Returns::

    VariableType --
        The VariableType, if present. Otherwise None
";


%feature("docstring") ModelicaCasADi::Model::getVariableByKind "
Returns a tuple with all Variables of a certain kind, as specified in the Model.

Parameters::

    VariableKind --
        A VariableKind, e.g. Model.DERIVATIVE

Returns::
    
    Tuple(Variable) --
        A tuple with zero or more Variables. 

";


%feature("docstring") ModelicaCasADi::Model::getVariableByName "
Returns the Variable with the provided name. If there is no 
variable with that name present in the Model None is returned.

This method does not discriminate between alias variables and 
an alias variable may be returned.

Parameters::

    String --
        String name of a Variable

Returns::

    Variable --
        The Variable with the provided name or None
        
";

%feature("docstring") ModelicaCasADi::Model::getModelVariableByName "
Returns the Variable with the provided name. If there is no 
variable with that name present in the Model None is returned.

This method does discriminate between alias variables, and if the
provided name is an alias variable its alias is returned instead. 

Parameters::

    String --
        String name of a Variable

Returns::

    Variable --
        The Variable with the provided name or its alias, or None
        
";
    
%feature("docstring") ModelicaCasADi::Model::getAllVariables "
Returns a tuple with all Variables present in the Model. 

Returns::
    
    Tuple(Variable) --
        A tuple with zero or more Variables. 

";  

%feature("docstring") ModelicaCasADi::Model::getModelVariables "
Returns a tuple with all model variables, i.e. that have not been 
alias eliminated, present in the Model.  

Returns::
    
    Tuple(Variable) --
        A tuple with zero or more Variables. 

";  
%feature("docstring") ModelicaCasADi::Model::getAliasVariables "
Returns a tuple with all alias variables present in the Model. 

Returns::
    
    Tuple(Variable) --
        A tuple with zero or more Variables. 

";  

%feature("docstring") ModelicaCasADi::Model::calculateValuesForDependentParameters "
Calculates the value of all dependent parameters. The calculated value is 
set in the attribute evaluatedBindingExpression for dependent parameters. 

";  
 
%feature("docstring") ModelicaCasADi::Model::getInitialResidual "
Returns all initial equations in a stacked MX on the form: rhs - lhs.

Returns::
    
    MX --
        A MX with the possibly stacked initial equations.

";      
%feature("docstring") ModelicaCasADi::Model::getDaeResidual "
Returns all DAE equations in a stacked MX on the form: rhs - lhs.

Returns::
    
    MX --
        A MX with the possibly stacked DAE equations.

";
        
%feature("docstring") ModelicaCasADi::Model::getModelFunctionByName "
Retrieves a ModelFunction with a certain name. 

Parameters::

    String --
        The name of the ModelFunction
        
Returns::
    
    ModelFunction --
        The ModelFunction, or None if there is no ModelFunction with that name in the Model.

";      

/********** ModelicaCasADi::Equation **********/
%feature("docstring") ModelicaCasADi::Equation::Equation "
Creates an Equation, with a MX expressions for the left and right hand side.

Parameters::

    MX --
        MX expression for left hand side
    MX --
        MX expression for right hand side
        
"; 

%feature("docstring") ModelicaCasADi::Equation::getLhs "
Returns the left hand side expression

Returns::

    MX --
        MX expression for left hand side
        
"; 

%feature("docstring") ModelicaCasADi::Equation::getRhs "
Returns the right hand side expression

Returns::

    MX --
        MX expression for right hand side
        
"; 

%feature("docstring") ModelicaCasADi::Equation::getResidual "
Returns the residual on the form: right-hand-side - left-hand-side

Returns::

    MX --
        The residual expression
        
"; 

/********** ModelicaCasADi::Variable  **********/
%feature("docstring") ModelicaCasADi::Variable::Variable "
Creates an empty Variable. Note that Variable should not be used directly,
instead subclasses such as RealVariable should be used. 
"; 

%feature("docstring") ModelicaCasADi::Variable::Variable "
Creates a Variable with the symbolic MX, Causality and Variability provided.
Note that Variable should not be used directly, instead subclasses such 
as RealVariable should be used. 

Parameters::

    MX --
        A symbolic MX
        
    Causality --
        A Causality, e.g. Variable.INPUT
        
    Variability --
        A Variability, e.g. Variable.CONTINUOUS
        
    VariableType --
        A VariableType, default is None. 
"; 


%feature("docstring") ModelicaCasADi::Variable::isAlias "
Is this Variable an alias variable or not. 

Returns::

    bool --
       
"; 

%feature("docstring") ModelicaCasADi::Variable::isNegated "
Is this variable negated. 

Returns::

    bool --
        
"; 

%feature("docstring") ModelicaCasADi::Variable::setNegated "
Only alias variables may be negated. 

Params::

    bool --
        
"; 

%feature("docstring") ModelicaCasADi::Variable::setAlias "
Sets an alias for this variable, making it an alias variable

Params::

    Variable --
        
"; 
%feature("docstring") ModelicaCasADi::Variable::getAlias "
Returns this Variable's alias, or None if it does not have one. 

Params::

    Variable --
        
"; 

%feature("docstring") ModelicaCasADi::Variable::getName "
Returns the name of this variable

Returns::

    string --
        This variable's name. 
"; 

%feature("docstring") ModelicaCasADi::Variable::getVar "
Returns the symbolic MX for this Variable

Returns::

    MX --
        A symbolic MX
"; 
%feature("docstring") ModelicaCasADi::Variable::getType "
Returns the primitive Type for this Variable, e.g. Variable.REAL

Returns::

    Type --
        A Type
"; 
%feature("docstring") ModelicaCasADi::Variable::getCausality "
Returns the Causality for this Variable, e.g. Variable.INPUT

Returns::

    Causality --
        A Causality
"; 
%feature("docstring") ModelicaCasADi::Variable::getVariability "
Returns the Variability for this Variable, e.g. Variable.CONTINUOUS

Returns::

    Variability --
        A Variability
        
"; 
%feature("docstring") ModelicaCasADi::Variable::getDeclaredType "
Returns this Variable's declared type, if it has one. This may be
one of Modelica's built in types such as Real, and then it will
contain the Real types default attributes, or it may be a user
defined type. 

Returns::

    VariableType --
        A VariableType or None
        
"; 

%feature("docstring") ModelicaCasADi::Variable::setDeclaredType "
Sets this Variable's declared type. 

Parameters::

    VariableType --
        A VariableType
        
"; 
%feature("docstring") ModelicaCasADi::Variable::getAttribute "
Returns the value of the attribute with the specified name. Looks at
the local attributes then at its declared type, OR at its alias if 
this is an alias variable (whether this is a negated alias
variable or not is considered for the start, min, max and nominal attributes). 


Parameters::
    
    AttributeKey --
        A string name

Returns::

    AttributeValue --
        An AttributeValue, e.g. an MX expression
        
"; 
%feature("docstring") ModelicaCasADi::Variable::hasAttributeSet"
A check whether the variable has a certain attribute set, OR if 
its alias has a certain attribute set if this is an alias variable

Parameters::
    
    AttributeKey --
        A string name

Returns::

    Bool --
    
"; 
%feature("docstring") ModelicaCasADi::Variable::setAttribute "
Sets an attribute in this variable, OR if this is an alias variable
the attribute is propagated to its alias (whether this is a negated alias
variable or not is considered for the start, min, max and nominal attributes). 

Parameters::
    
    AttributeKey --
        A string name
        
    AttributeValue --
        An AttributeValue, e.g. an MX expression

"; 


/********** ModelFunction **********/
%feature("docstring") ModelicaCasADi::ModelFunction::ModelFunction "
Create a ModelFunction, which is basically a wrapper around an MXFunction 
that may be called and printed. 

Parameters::
    
    MXFunction --
        A MXFunction
        
"; 

%feature("docstring") ModelicaCasADi::ModelFunction::call "
Call the MXFunction kept in this class with a vector of MX as arguments.  
Returns a tuple with MX representing the outputs of the function call.

Parameters::
    
    MXVector --
        A MXVector with MX arguments to the function
    
Returns::

    tuple(MX) --
        A tuple with MX for the outputs of the call
        
"; 

%feature("docstring") ModelicaCasADi::ModelFunction::getName "

Returns::

    string --
        The name of the function.
        
";

/********** RealVariable **********/ 
%feature("docstring") ModelicaCasADi::RealVariable::RealVariable "
Create a RealVariable.

Parameters::

    MX --
        A symbolic MX.
    
    Causality --
        A Causality, e.g. RealVariable.INPUT
        
    Variability --
        A Variability, e.g. RealVariable.CONTINUOUS
        
    VariableType --
        A VariableType, default is None. 
        
";

%feature("docstring") ModelicaCasADi::RealVariable::getType "
Returns the Type Real

Returns::

    Type --
        The Type Real
        
";

%feature("docstring") ModelicaCasADi::RealVariable::setMyDerivativeVariable "
Sets the derivative variable associated with this variable, 

Parameters::

    Variable --
        A Variable to be set as derivative variable. It must be a DerivativeVariable.
        
";

%feature("docstring") ModelicaCasADi::RealVariable::getMyDerivativeVariable "
Retrieves the derivative variable associated with this variable.

Returns::

    Variable --
        A Variable, or None if not present. 
        
";

%feature("docstring") ModelicaCasADi::RealVariable::isDerivative "
Check whether this variable is a derivative. Since it is not a 
DerivativeVariable it is not a derivative. 

Returns::

    Bool --
        False
        
";

/********** DerivativeVariable **********/

%feature("docstring") ModelicaCasADi::DerivativeVariable::DerivativeVariable "
Create a derivative variable. A derivative variable takes its 
corresponding state variable as argument. Note that a state variable
must have real type and continuous variability. 

Parameters::

    MX --
        A symbolic MX
        
    Variable --
        This variable's state variable
        
    VariableType --
        A VariableType, default is None. 
        
";

%feature("docstring") ModelicaCasADi::DerivativeVariable::getMyDifferentiatedVariable "
Returns the state variable associated with this variable

Returns::

    Variable --
        
        
";

%feature("docstring") ModelicaCasADi::DerivativeVariable::isDerivative "
Returns True

Returns::

    Bool --
        True 
        
";

/********** IntegerVariable **********/

%feature("docstring") ModelicaCasADi::IntegerVariable::IntegerVariable "
Create an Integer Variable. An integer Variable may not have 
continuous variability. 

Parameters::

    MX --
        A symbolic MX
        
    Causality --
        A Causality, e.g. IntegerVariable.INPUT
        
    Variability --
        A Variability, e.g. IntegerVariable.DISCRETE
        
    VariableType --
        A VariableType, default is None. 
";

%feature("docstring") ModelicaCasADi::IntegerVariable::getType "
Returns the Type Integer

Returns::

    Type --
        The Type Integer
        
";

/********** BooleanVariable **********/

%feature("docstring") ModelicaCasADi::BooleanVariable::BooleanVariable "
Create a Boolean variable. Boolean variables may not have
continuous variability. 

Parameters::

    MX --
        A symbolic MX
        
    Causality --
        A Causality, e.g. BooleanVariable.INPUT
        
    Variability --
        A Variability, e.g. BooleanVariable.DISCRETE
        
    VariableType --
        A VariableType, default is None. 
";

%feature("docstring") ModelicaCasADi::BooleanVariable::getType "
Returns the Type Boolean

Returns::

    Type --
        The Type Boolean
        
";

/********** OptimizationProblem  **********/
%feature("docstring") ModelicaCasADi::OptimizationProblem::OptimizationProblem "
Create an OptimizationProblem from the constraints, objective function
and start/final times.

Parameters::

    Model --
        A Model.
        
    ConstraintVector --
        A vector with the path constraints. 
   
    MX --
        A MX for the start time
        
    MX --
        A MX for the final time
        
    MX --
        A MX for the Lagrange term, default = MX(0)
    
    MX --
        A MX for the Mayer term, default = MX(0)
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getModel "
Returns the Model kept in this OptimizationProblem

Returns::

    Model --
        A Model, representing a constraint in the optimization problem. 
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getStartTime "
Returns the start time

Returns::

    MX --
        The start time
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getFinalTime "
Returns the final time

Returns::

    MX --
        The final time
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getPathConstraints "
Returns the path constraints

Returns::

    tuple(Constraint) --
        A tuple with the path constraints
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getLagrangeTerm "
Returns the Lagrange term

Returns::

    MX --
        The Lagrange term
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::getMayerTerm "
Returns the Mayer term

Returns::

    MX --
        The Mayer term
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::setStartTime "
Sets the start time

Parameters::

    MX --
        The start time to be set.
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::setFinalTime "
Sets the final time

Parameters::

    MX --
        The final time to be set.
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::setPathConstraint "
Sets the path constraints

Parameters::

    ConstraintVector --
        The path constraints
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::setLagrangeTerm "
Sets the Lagrange term

Parameters::

    MX --
        The Lagrange term to be set.
        
"; 

%feature("docstring") ModelicaCasADi::OptimizationProblem::setMayerTerm "
Sets the Mayer term

Parameters::

    MX --
        The Mayer term to be set.
        
"; 

/********** Constraint  **********/
%feature("docstring") ModelicaCasADi::Constraint::Constraint "
Create a constraint from MX for the left and right hand side, 
and a relation type (<, >, ==).

Parameters::

    MX --
        A MX expression for the left hand side

    MX --
        A MX expression for the right hand side

    Type --
        A relation type, e.g. Constraint.LEQ
        
"; 

%feature("docstring") ModelicaCasADi::Constraint::getLhs "
Return the MX expression for the left hand side. 

Returns::

    MX --
        A MX expression for the left hand side
        
"; 

%feature("docstring") ModelicaCasADi::Constraint::getRhs "
Return the MX expression for the right hand side. 

Returns::

    MX --
        A MX expression for the right hand side
        
"; 

%feature("docstring") ModelicaCasADi::Constraint::getResidual "
Returns the residual of the constraint as: right-hand-side - left-hand-side.

Returns::

    MX --
        A MX expression for the residual
        
"; 

%feature("docstring") ModelicaCasADi::Constraint::getType "
Returns the type of the relation type for this Constraint.

Returns::

    Type --
        A relation type, e.g. Constraint.LEQ
        
"; 

/********** transferOptimica **********/
%feature("docstring") ModelicaCasADi::transferOptimizationProblem "
Transfers the specified optimization problem.

Parameters::

    string --
        The name of the optimization problem
    
    string --
        The file that contains the optimization problem
    
    OptionRegistry --
        An OptionRegistry for passing compiler options to the JModelica compiler.
        Currently not accessible from Python. 
        
Returns::
    
    OptimizationProblem --
        The transferred optimization problem
        
";

%feature("docstring") ModelicaCasADi::transferOptimizationProblemWithoutInlining "
Transfers the specified optimization problem, with function inlining turned off. 

Parameters::

    string --
        The name of the optimization problem
    
    string --
        The file that contains the optimization problem
        
Returns::
    
    OptimizationProblem --
        The transferred optimization problem
        
"; 

/********** transferModelica **********/
%feature("docstring") ModelicaCasADi::transferModelicaModel "
Transfers the specified Modelica model

Parameters::

    string --
        The name of the model.
    
    string --
        The file that contains the model.
    
    OptionRegistry --
        An OptionRegistry for passing compiler options to the JModelica compiler.
        Currently not accessible from Python. 
        
Returns::
    
    Model --
        The transferred model
        
";

%feature("docstring") ModelicaCasADi::transferModelicaModelWithoutInlining "
Transfers the specified Modelica model, with function inlining turned off. 

Parameters::

    string --
        The name of the model.
    
    string --
        The file that contains the model.
        
Returns::
    
    Model --
        The transferred model
        
"; 
