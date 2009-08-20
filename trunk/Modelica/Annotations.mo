within ;
package Annotations "Annotations for Modelica 3.1" 
  
  /*
     This file contains declarations for Modelica standard annotations
     that may be represented by records. Unfortunately, the annotation
     syntax is not well defined, and there are annotations that
     required special treatment. These are included in comment
     sections below.

     It would be good if the Modelica Association would review the
     annotation syntax with the aim to fit all annotations into a
     consistent framework, for example:
     - Move components from top level scope into records ('evaluate'
     into 'CodeGeneration', 'version' into 'Version', etc).
     - Remove the "DynamicsSelect" annotation in favour of allowing
     variable expressions where default values are used in editing
     state. Whether or not the dynamic values are to be applied is a
     semantic issue.
     - Redesign uses annotation to 'Uses("SomeLib 3.1")' or similar.
     - Redesign 'conversion' annotation to 'Conversion(from = "3.1",
     script = "...")', 'Conversion(from = "3.2", noConversion = true)'
     etc. (allowing multiple 'Conversion' annotations).
     - Change the 'derivative' annotation to
     'Derivatives(Derivative(order = 2, derfunc = foo2))'
     - Change the 'inverse' annotation to 'Inverses(Inverse(arg = 2, invfunc =
     foo2))'
     - Change the "Library" annotation to only support the vector
     form.
     - No idea what to do with the 'choice' annotation that takes
     expressions as arguments...

     Section numbers refer to the Modelica Language Specification
     Version 3.1.
  */
  
  /***************************************************************** 
     17.3 Annotations for Code Generation
  ******************************************************************/
  
  /***************************************************************** 
     17.4 Annotations for Simulation Experiments
  ******************************************************************/
  
  record experiment 
    Real StartTime = 0;
    Real StopTime = 1;
    Real Tolerance = 1e-5;
  end experiment;
  
  /***************************************************************** 
     17.5 Annotations for Graphical Objects 
  ******************************************************************/
  
  /* 17.5.1 Common Definitions */
  type DrawingUnit = Real(final unit="mm");
  type Point = DrawingUnit[2] "{x, y}";
  type Extent = Point[2] "Defines a rectangular area {{x1, y1}, {x2, y2}}";
  
  partial record GraphicItem 
    Boolean visible = true;
    Point origin = {0, 0};
    Real rotation(quantity="angle", unit="deg")=0;
  end GraphicItem;
  
  /* 17.5.1.1 Coordinate Systems */
  
  record CoordinateSystem 
    Extent extent;
    Boolean preserveAspectRatio=true;
    Real initialScale = 0.1;
    DrawingUnit grid[2];
  end CoordinateSystem;
  
  record Icon "Representation of the icon layer" 
    CoordinateSystem coordinateSystem(extent = {{-100, -100}, {100, 100}});
    GraphicItem[:] graphics;
  end Icon;
  
  record Diagram "Representation of the diagram layer" 
    CoordinateSystem coordinateSystem(extent = {{-100, -100}, {100, 100}});
    GraphicItem[:] graphics;
  end Diagram;
  
  /* 17.5.1.2 Graphical Properties */
  
  type Color = Integer[3](min=0, max=255) "RGB representation";
  constant Color Black = zeros(3);
  type LinePattern = enumeration(
      None, 
      Solid, 
      Dash, 
      Dot, 
      DashDot, 
      DashDotDot);
  type FillPattern = enumeration(
      None, 
      Solid, 
      Horizontal, 
      Vertical, 
      Cross, 
      Forward, 
      Backward, 
      CrossDiag, 
      HorizontalCylinder, 
      VerticalCylinder, 
      Sphere);
  type BorderPattern = enumeration(
      None, 
      Raised, 
      Sunken, 
      Engraved);
  type Smooth = enumeration(
      None, 
      Bezier);
  type Arrow = enumeration(
      None, 
      Open, 
      Filled, 
      Half);
  type TextStyle = enumeration(
      Bold, 
      Italic, 
      UnderLine);
  type TextAlignment = enumeration(
      Left, 
      Center, 
      Right);
  
  record FilledShape "Style attributes for filled shapes" 
    Color lineColor = Black "Color of border line";
    Color fillColor = Black "Interior fill color";
    LinePattern pattern = LinePattern.Solid "Border line pattern";
    FillPattern fillPattern = FillPattern.None "Interior fill pattern";
    DrawingUnit lineThickness = 0.25 "Line thickness";
  end FilledShape;
  
  /* 17.5.2 Component Instance */
  
  record Transformation 
    Point origin = {0, 0};
    Extent extent;
    Real rotation(quantity="angle", unit="deg")=0;
  end Transformation;
  
  record Placement 
    Boolean visible = true;
    Transformation transformation "Placement in the dagram layer";
    Transformation iconTransformation "Placement in the icon layer";
  end Placement;
  
  /* 17.5.3 Extends clause */
  
  record IconMap 
    Extent extent = {{0, 0}, {0, 0}};
    Boolean primitivesVisible = true;
  end IconMap;
  
  record DiagramMap 
    Extent extent = {{0, 0}, {0, 0}};
    Boolean primitivesVisible = true;
  end DiagramMap;
  
  /* 17.5.4 Connections 

     A connection is specified with an annotation containing a Line
     primitive, as specified below.
  */
  
  /* 17.5.5 Graphical primitives */
  
  record Line 
    extends GraphicItem;
    Point points[:];
    Color color = Black;
    LinePattern pattern = LinePattern.Solid;
    DrawingUnit thickness = 0.25;
    Arrow arrow[2] = {Arrow.None, Arrow.None};
  end Line;
  
  record Polygon 
    extends GraphicItem;
    extends FilledShape;
    Point points[:];
    Smooth smooth = Smooth.None "Spline outline";
  end Polygon;
  
  record Rectangle 
    extends GraphicItem;
    extends FilledShape;
    BorderPattern borderPattern = BorderPattern.None;
    Extent extent;
    DrawingUnit radius = 0 "Corner radius";
  end Rectangle;
  
  record Ellipse 
    extends GraphicItem;
    extends FilledShape;
    Extent extent;
    Real startAngle(quantity="angle", unit="deg")=0;
    Real endAngle(quantity="angle", unit="deg")=360;
  end Ellipse;
  
  record Text 
    extends GraphicItem;
    extends FilledShape;
    Extent extent;
    String textString;
    Real fontSize = 0 "unit pt";
    String fontName;
    TextStyle textStyle[:];
    TextAlignment horizontalAlignment = TextAlignment.Center;
  end Text;
  
  record Bitmap 
    extends GraphicItem;
    Extent extent;
    String fileName "Name of bitmap file";
    String imageSource "Base64 representation of bitmap";
  end Bitmap;
  
  /* 17.5.6 Variable Graphics and Schematic Animation 
     
     Any value (coordinates, color, text, etc) in graphical
     annotations can be dependent on class variables using the
     DynamicSelect expression. DynamicSelect has the syntax of a
     function call with two arguments, where the first argument
     specifies the value of the editing state and the second argument
     the value of the non-editing state. The first argument must be a
     literal expression. The second argument may contain references to
     variables to enable a dynamic behavior.
  */
  
  /* 17.5.7 User input */
  
  record OnMouseDownSetBoolean 
    Boolean variable "Name of variable to change when mouse button pressed";
    Boolean value "Assigned value";
  end OnMouseDownSetBoolean;
  
  record OnMouseUpSetBoolean 
    Boolean variable "Name of variable to change when mouse button released";
    Boolean value "Assigned value";
  end OnMouseUpSetBoolean;
  
  record OnMouseMoveXSetReal 
    Real xVariable "Name of variable to change when cursor moved
    in x direction";
    Real minValue;
    Real maxValue;
  end OnMouseMoveXSetReal;
  
  record OnMouseMoveYSetReal 
    Real yVariable "Name of variable to change when cursor moved
    in y direction";
    Real minValue;
    Real maxValue;
  end OnMouseMoveYSetReal;
  
  record OnMouseDownEditInteger 
    Integer variable "Name of variable to change";
  end OnMouseDownEditInteger;
  
  record OnMouseDownEditReal 
    Real variable "Name of variable to change";
  end OnMouseDownEditReal;
  
  record OnMouseDownEditString 
    String variable "Name of variable to change";
  end OnMouseDownEditString;
  
  /***************************************************************** 
     17.6 Annotations for the Graphical User Interface
  ******************************************************************/
  
  constant String defaultComponentName;
  constant String defaultComponentPrefixes;
  constant String missingInnerMessage;
  constant String unassignedMessage;
  
  record Dialog 
    parameter String tab = "General";
    parameter String group = "Parameters";
    parameter Boolean enable = true;
    parameter Boolean connectorSizing = false;
  end Dialog;
  
  /***************************************************************** 
     17.7 Annotations for Version Handling
  ******************************************************************/
  
  constant String version;
  
  // conversion ( noneFromVersion = VERSION-NUMBER)
  // conversion ( from (version = VERSION-NUMBER, script = "...") )
  // uses(IDENT (version = VERSION-NUMBER) )
  
  /***************************************************************** 
     17.7.4 Version Date and Build Information
  ******************************************************************/
  
  constant String versionDate 
    "UTC date of first version build (in format: YYYY-MM-DD)";
  constant Integer versionBuild 
    "Larger number is a more recent maintenance update";
  constant String dateModified 
    "UTC date and time of the latest change to the package in the following format (with one space between date and time): YYYY-MM-DD hh:mm:ssZ";
  constant String revisionId "Revision identifier of the version management system used to manage this library. It marks the latest submitted change to
any file belonging to the package";
  
  /***************************************************************** 
     17.8 Annotations for Functions
  ******************************************************************/
  
  /* 17.8.1 Function Derivative Annotations See Section 12.7.1 */
  
  // derivative
  // zeroDerivative
  // noDerivative
  
  /* 17.8.2 Inverse Function Annotation See Section 12.8 */
  
  // inverse
  
  /* 17.8.3 External Function Annotations See Section 12.9.4. */
  
  // annotation(Library="libraryName")
  constant String[:] Library;
  constant String Include;
  
  /***************************************************************** 
     17.9 Annotation Choices for Modifications and Redeclarations
  ******************************************************************/
  
  /* See Section 7.3.4. */
  // choices
  // choice
  
  /***************************************************************** 
     17.10 Annotations to Map Models to Execution Environments
  ******************************************************************/
  
  /* See Section 16.5. */
  
  /* The code below is commented since it appears to be incomplete.

  record mapping
    Boolean apply=true 
      "= true, if mapping properties hold, otherwise they are ignored";
    Target target "Properties of target machine";
    Task task "Properties of asynchronous task running on the target machine";
    Subtask subtask "Properties of synchronous subtask running in the task";
  end mapping;

  record Target "Properties of target machine (processor, computer)"
    String identifier = "DefaultTarget" 
      "Unique identification of target machine (tool specific)";
    String kind = "DefaultTargetKind" 
      "Kind of target (defines, e.g., type of processor)";
  end Target;

  record Task 
    "Properties of asynchronous task running on a target machine"
    String identifier = "DefaultTask" "Unique identification of task on target";
    Integer onProcessor = -1 
      "If multi-processor/core target (otherwise ignored): = -1: automatic selection of processor/core; >= 0: run task onProcessor (tool specific)";
    Integer priority = 1 
      "Fixed priority value of task (may be overriden depending on scheduling policy)";
    Modelica.SIunits.Period sampleBasePeriod = 0 
      "Sample base period for periodic subtasks";
  end Task;

  record Subtask 
    "Properties of synchronous subtask running in a task"
    Integer samplePeriodFactor(min=1) = 1 
      "If Subtask.SamplingType.Periodic: sample period = samplePeriodFactor*task.sampleBasePeriod";
    Integer sampleOffsetFactor(min=0) = 0 
      "If Subtask.SamplingType.Periodic: sample offset = sampleOffsetFactor*task.sampleBasePeriod";
    IntegrationMethod integrationMethod = "SameAsSimulator" 
      "Integration method";
    Modelica.SIunits.Period fixedStepSize 
      "Step size for fixed step integration method";
  end Subtask;

  */
  
  annotation (uses(Modelica(version="2.2.2")));
end Annotations;
