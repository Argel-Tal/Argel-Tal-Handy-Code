let
    OpenExcelFromSharePointBase = (sharePointDomain as text, targetSite as text, rowSkipCount as number, excelItemName as text, excelItemType as text, optional fileIndex as number) => 

        let
            // Any optional parameters always need to be handled for nulls
            ResolveFileIndex = if ( fileIndex is null ) then 0 else fileIndex,
            // begin function proper
            Source = SharePoint.Files((sharePointDomain & targetSite), [ApiVersion = 15]),
            #"Filtered to excel files" = Table.SelectRows(Source, each ([Extension] = ".xlsx")),
            #"Added Excel content from binary" = Table.AddColumn(#"Filtered to excel files", "ExcelContents", each Excel.Workbook([Content])),
            #"Expanded ExcelContents" = Table.ExpandTableColumn(#"Added Excel content from binary", "ExcelContents", {"Name", "Data", "Item", "Kind", "Hidden"}, {"ExcelContents.Name", "ExcelContents.Data", "ExcelContents.Item", "ExcelContents.Kind", "ExcelContents.Hidden"}),
            #"Filtered to item type and only visible" = Table.SelectRows(#"Expanded ExcelContents", each ([ExcelContents.Kind] = excelItemType and [ExcelContents.Hidden] = false)),
            // These filter steps could be consolidated into one step to make the code more efficient, but included as separate steps to show the workflow in detail
            #"Filtered to target item" = Table.SelectRows(#"Filtered to item type and only visible", each [ExcelContents.Name] = excelItemName),
            #"Kept only filename and the data" = Table.SelectColumns(#"Filtered to target item",{"Name", "ExcelContents.Data"}),
            getOnefile =  #"Kept only filename and the data"{fileIndex}[ExcelContents.Data],
            // In this example file, there are some rows with context before the actual data - this step removes these
            #"Removed excess top rows" = Table.Skip(getOnefile,rowSkipCount),
            #"Promoted first real row to Headers" = Table.PromoteHeaders(#"Removed excess top rows", [PromoteAllScalars=true])
        in
            #"Promoted first real row to Headers",

        // -------------------- Parameter documentation segment ---------------------------
        // Declare custom type for each parameter with parameter documentation
        // The type must match the base function declaration parameters, or invocation will fail
        sharePointDomainInput = type text
        meta [
            Documentation.FieldCaption  = "Base URL for your org's SharePoint (""include /sites/"")", 
            Documentation.SampleValues = { "https://orgname.sharepoint.com/sites/" }
        ],
        
        targetSiteInput = type text
        meta [
            Documentation.FieldCaption  = "Name of the site your file is on", 
            Documentation.SampleValues = { "myTest-Site" }
        ],

        fileIndexInput = type number
        meta [
            Documentation.FieldCaption  = "What number file you want if many matches?", 
            Documentation.SampleValues = { "0" }
        ], 

        rowSkipCountInput = type number
        meta [
            Documentation.FieldCaption  = "How many rows need to be skipped?", 
            Documentation.SampleValues = { "0" }
        ], 

        excelItemNameInput = type text
        meta [
            Documentation.FieldCaption  = "Excel file's name (not including '.xlsx')", 
            Documentation.SampleValues = { "Schema shipments" }
        ], 
    
        excelItemTypeInput = type text
        meta [
            Documentation.FieldCaption  = "Are trying to ingest a named Table or a Sheet", 
            Documentation.SampleValues = { "Sheet" },
            // Providing a list of allowed values will change the parameter input to a drop down in the GUI
            // However it does not enforce usage of these values, and manual invocation can use different values
            Documentation.AllowedValues = { "Sheet", "Table" }
        ], 
    
        
    // -------------------- Function documentation segment ----------------------------
    // Declare custom function type with function documentation
    OpenExcelFromSharePointType = type function (
        // Cast the parameters with the new custom parameter types
        // The parameter names here are arbitrary, but should be kept the same for clarity
        // The optional flag must be retained as per the base function
        sharePointDomain as sharePointDomainInput
        , targetSite as targetSiteInput
        , rowSkipCount as rowSkipCountInput
        , excelItemName as excelItemNameInput
        , excelItemType as excelItemTypeInput
        , optional fileIndex as fileIndexInput
        
    // The output type must match the base function
    ) as text
        meta [
            Documentation.Name = "Get the cell contents from a single Excel file from a specified SharePoint site",
            Documentation.Description = "Outputs the tabular data from a singular excel file in SharePoint, either from a target Sheet, or from a named Table. 
            <br>
            This function contains all the code you need to process multiple files at once into one big table, you will just need to unpack and edit it into standalone components.",
            Documentation.Examples =
            {
                [
                    Description = "Invocation with no optional parameters",
                    Code = "OpenExcelFromSharePoint(""https://orgname.sharepoint.com/sites/"", ""Demo-Site"", 12, ""Schema shipments"", ""Sheet"")",
                    Result = "[ your excel file's data contents ]"
                ],
                [
                    Description = "Invocation with specification of optional parameter: which number file",
                    Code = "OpenExcelFromSharePoint(""https://orgname.sharepoint.com/sites/"", ""Demo-Site"", 12, ""Schema shipments"", ""Sheet"", 0)",
                    Result = "[ your excel file's data contents ]"
                ]
            }
        ], 

    // ------------------------------- Output -----------------------------------------
    // Cast base function to new custom function type
    OpenExcelFromSharePoint = Value.ReplaceType ( OpenExcelFromSharePointBase, OpenExcelFromSharePointType )
    
in
    OpenExcelFromSharePoint