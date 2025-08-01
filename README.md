# Greatdori

> [!NOTE]
> Greatdori project is still working in progress.

Greatdori includes DoriKit library, iOS app and watchOS app.
DoriKit allows you to fetch data from Bestdori API in Swifty way:
you can get raw data from the API,
or let DoriKit to process data from the API for you.
Apps in this project show you how to use the DoriKit,
and provide native experience to Bestdori.

## Using DoriKit
Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/WindowsMEMZ/Greatdori.git", branch: "main"),
```

Then add the dependency to targets you're going to use it:

```swift
.target(
    name: "MyTarget", 
    dependencies: [
        .product(name: "DoriKit", package: "Greatdori"),
    ]
),
```

> [!IMPORTANT]
> Greatdori project is on a **really early stage** of development,
> DO NOT depend on it in any production environment.

## Building
Xcode 26.0 (currently beta) is required for building this project.

Open `Greatdori.xcodeproj`, then select a scheme you want to build.

## Contributing to Greatdori
Contributions to Greatdori are welcomed and encouraged!
Fork the project, make changes and open your pull requests!

If you're experiencing some bugs, or have any suggestion to Greatdori,
filing an issue for it is also welcomed.

### `Greatdori.xcodeproj` & `Package.swift`
`Greatdori.xcodeproj` is the main project file of Greatdori,
we suggest you to open this project file in Xcode to make changes to Greatdori.

`Package.swift` makes it easier to embed DoriKit in other projects,
and should not be used for editing code of Greatdori,
because `xcodeproj` file maintains structures of all files in this project.

### About GYB Source Files
You may note that some source files have suffix `.swift.gyb` instead of `.swift`,
this kind of files are GYB templetes. GYB is a useful tool from the swiftlang project
which enables you to generate repeated source code from less code.

<details><summary>Usage of GYB</summary>

```

usage: gyb [-h] [-D NAME=VALUE] [-o TARGET] [--test] [--verbose-test] [--dump]
           [--line-directive LINE_DIRECTIVE]
           [file]

Generate Your Boilerplate!

positional arguments:
  file                  Path to GYB template file (defaults to stdin)

options:
  -h, --help            show this help message and exit
  -D NAME=VALUE         Bindings to be set in the template's execution context
  -o TARGET             Output file (defaults to stdout)
  --test                Run a self-test
  --verbose-test        Run a verbose self-test
  --dump                Dump the parsed template to stdout
  --line-directive LINE_DIRECTIVE
                        Line directive format string, which will be provided 2
                        substitutions, `%(line)d` and `%(file)s`. Example:
                        `#sourceLocation(file: "%(file)s", line: %(line)d)`
                        The default works automatically with the `line-
                        directive` tool, which see for more information.

    A GYB template consists of the following elements:

      - Literal text which is inserted directly into the output

      - %% or $$ in literal text, which insert literal '%' and '$'
        symbols respectively.

      - Substitutions of the form ${<python-expression>}.  The Python
        expression is converted to a string and the result is inserted
        into the output.

      - Python code delimited by %{...}%.  Typically used to inject
        definitions (functions, classes, variable bindings) into the
        evaluation context of the template.  Common indentation is
        stripped, so you can add as much indentation to the beginning
        of this code as you like

      - Lines beginning with optional whitespace followed by a single
        '%' and Python code.  %-lines allow you to nest other
        constructs inside them.  To close a level of nesting, use the
        "%end" construct.

      - Lines beginning with optional whitespace and followed by a
        single '%' and the token "end", which close open constructs in
        %-lines.

    Example template:

          - Hello -
        %{
             x = 42
             def succ(a):
                 return a+1
        }%

        I can assure you that ${x} < ${succ(x)}

        % if int(y) > 7:
        %    for i in range(3):
        y is greater than seven!
        %    end
        % else:
        y is less than or equal to seven
        % end

          - The End. -

    When run with "gyb -Dy=9", the output is

          - Hello -

        I can assure you that 42 < 43

        y is greater than seven!
        y is greater than seven!
        y is greater than seven!

          - The End. -

```

</details>

### Testing
You have to run testing by `DoriKitTests` scheme in Greatdori.xcodeproj (instead of Package.swift).

## License
This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE.txt) file for details.
