/* --------------------------------------------------------------------------------
An advanced version of the Hello World function that incorporates function and
parameter documentation metadata to improve usability.

Adapted from the following sources:
https://blog.crossjoin.co.uk/2014/11/27/specifying-allowed-values-sample-values-and-descriptions-for-function-parameters-in-power-querypart-1/
https://datameerkat.com/documentation-options-in-power-query
-------------------------------------------------------------------------------- */

let
    // ------------------------ Function logic segment --------------------------------
    // Declare the base function logic, including the parameters and their types
    HelloWorldBase = ( firstName as text, optional lastName as text ) as text =>
        let
            // Any optional parameters always need to be handled for nulls
            ResolveName = if ( lastName is null ) then firstName else firstName & " " & lastName,
            OutputMessage = "Hello, " & ResolveName & "!"
        in
            OutputMessage,
    
    // -------------------- Parameter documentation segment ---------------------------
    // Declare custom type for each parameter with parameter documentation
    // The type must match the base function declaration parameters, or invocation will fail
    FirstNameType = type text
        meta [
            Documentation.FieldCaption  = "Please enter your first name", 
            Documentation.SampleValues = { "John" },
            // Providing a list of allowed values will change the parameter input to a drop down in the GUI
            // However it does not enforce usage of these values, and manual invocation can use different values
            Documentation.AllowedValues = { "John", "Jane" }
        ], 
    // Any optional parameters in the base function must be typed as nullable
    LastNameType = type nullable text
        meta [
            Documentation.FieldCaption   = "Enter your last name", 
            Documentation.SampleValues = { "Doe" }
        ], 
    
    // -------------------- Function documentation segment ----------------------------
    // Declare custom function type with function documentation
    HelloWorldType = type function (
        // Cast the parameters with the new custom parameter types
        // The parameter names here are arbitrary, but should be kept the same for clarity
        // The optional flag must be retained as per the base function
        firstName as FirstNameType, 
        optional lastName as LastNameType
    // The output type must match the base function
    ) as text
        meta [
            Documentation.Name = "Hello World",
            Documentation.Description = "Outputs a simple hello message greeting the provided name.
            Also accepts an optional last name.",
            Documentation.Examples =
            {
                [
                    Description = "Invocation with only first name",
                    Code = "HelloWorld( ""John"" )",
                    Result = "Hello, John!"
                ],
                [
                    Description = "Invocation with first name and last name",
                    Code = "HelloWorld( ""John"", ""Smith"" )",
                    Result = "Hello, John Smith!"
                ]
            }
        ], 
    
    // ------------------------------- Output -----------------------------------------
    // Cast base function to new custom function type
    HelloWorld = Value.ReplaceType ( HelloWorldBase, HelloWorldType )
in
    HelloWorld