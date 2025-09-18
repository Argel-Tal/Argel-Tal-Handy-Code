// A basic Hello World function in Power Query

let
    HelloWorld = (firstName as text, optional lastName as text) as text =>
        let
            ResolveName = if (lastName is null) then firstName else firstName & " " & lastName,
            OutputMessage = "Hello, " & ResolveName & "!"
        in
            OutputMessage
in
    HelloWorld