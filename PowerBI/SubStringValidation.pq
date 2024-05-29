#"Added AreaCode" = Table.AddColumn(#"Expanded Redline Critical", "Area Code", each 
    // handle documents starting "RIS-UNA-", edge case
    if [Design Package] = null and [RIS_Start_Doc] = "YES"
    then 
        // checks if the document is structured like `RIS-UNA-100-162-00-CER-000024`, where the `100` is the area code
        if 
            Text.Length(Text.Middle([#"Document No."], 8,3)) = 3
            and 
            (
                try Type.Is(Text.InferNumberType(Text.Middle([#"Document No."], 8,3)  ), type number) 
                otherwise false
            )
        then Text.Middle([#"Document No."], 8,3)  
        // else block sets area code to null for documents like `RIS-UNA-GOV-MPL-00219`
        else null
    else
        // checks for standard UNITY document format, like `100-162-00-CER`, where the `100` is the area code
        if 
        Text.Length(Text.Middle([Design Package], 0, 3)) = 3
        and 
        (
            try Type.Is(Text.InferNumberType(Text.Middle([Design Package], 0, 3)), type number) 
            otherwise false
        )
        then Text.Middle([Design Package], 0, 3)
        else null
    // end area code logic
),