let
    #"Kept only key columns" = Table.SelectColumns(#"Table1",{"Name", "Document No.", "MergeKeyTable1"}),
    #"Antijoined w/ DA status mapping" = Table.NestedJoin(#"Kept only key columns", {"MergeKeyTable1"}, #"Table2", {"MergeKeyTable2"}, "CollapsedTable2Name", JoinKind.LeftAnti),
    #"Check count rows" = Table.IsEmpty(Table.Group(#"Antijoined w/ DA status mapping", {"Document No."}, {{"Count", each Table.RowCount(_), Int64.Type}}))
in
    #"Check count rows"