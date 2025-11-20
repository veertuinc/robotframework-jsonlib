# robotframework-jsonlib

[![Test and Lint](https://github.com/veertuinc/robotframework-jsonlib/actions/workflows/python-app.yml/badge.svg)](https://github.com/veertuinc/robotframework-jsonlib/actions/workflows/python-app.yml)

``JSONLib`` is a [Robot Framework](http://robotframework.org/) test library for manipulating [JSON](http://json.org/) Object. You can manipulate your JSON object using [JSONPath](http://goessner.net/articles/JsonPath/)

It is a continuation of the original [robotframework-jsonlib](https://github.com/robotframework-thailand/robotframework-jsonlibrary) library which is no longer maintained.

JSONPath is an expression which can help to access to your JSON document. The JSONPath structure is in the same way as XPath which use for accessing XML document. This is an example of JSONPath syntax.

| JSONPath | Description |
|----------|-------------|
| $        | the root object/element |
| @        | the current object/element |
| . or []  | child operator |
| ..       | recursive descent. JSONPath borrows this syntax from E4X |
| *        | wildcard. All objects/element regardless their names. |
| []       | subscript operator. XPath uses it to iterate over element collections and for predicates. In Javascript and JSON it is the native array operator. |
| [,]      | Union operator in XPath results in a combination of node sets. JSONPath allows alternate names or array indices as a set. |
| [start\: end\: step] | array slice operator borrowed from ES4 |
| ?()      | applies a filter (script) expression. |
| ()       | script expression, using the underlying script engine. |

This library can help you to add, get, update and delete your JSON object. So it's very useful in case that you have a very large JSON object.

# Features

- ✅ Load JSON from files or strings
- ✅ Query JSON using JSONPath expressions
- ✅ Update values in JSON objects
- ✅ Add new objects to JSON
- ✅ Delete objects from JSON
- ✅ Validate JSON against schemas
- ✅ Convert between JSON objects and strings
- ✅ Pretty-print JSON with custom indentation
- ✅ Support for complex nested JSON structures

# Notes

Please note this library is a bridge between the Robot Framework and the parser jsonpath-ng. Hence, issues related to parsing should be raised on https://github.com/h2non/jsonpath-ng

Starting with version 0.4, Python2 support is dropped as Python2 reached end of life on 1st of January 2020.

# Installation

Install robotframework-jsonlib via ``pip``:

```bash
pip install -U robotframework-jsonlib
```

# Example Test Case

|\*** Settings \***|                     |                  |            |                  |
|:----------------- |-------------------- |----------------- |----------- |----------------- |
|Library           | JSONLib         |                  |            |                  |
|__\*** Test Cases \***__|                     |                  |            |                  |
|${json_obj}=      | Load Json From File | example.json     |            |                  |
|${object_to_add}= | Create Dictionary   | country=Thailand |            |                  |
|${json_obj}=      | Add Object To Json  | ${json_obj}      | $..address | ${object_to_add} |
|${value}=         | Get Value From Json | ${json_obj}      | $..country |                  |
|Should Be Equal As Strings | ${value[0]} | Thailand       |            |                  |
|${value_to_update}=| Set Variable     | Japan             |            |                  |
|${json_obj}=     | Update Value To Json | ${json_obj}     | $..country | ${value_to_update}|
|Should Be Equal As Strings | ${json_obj['country'] | ${value_to_update} |   |             |
|Should Have Value In Json  | ${json_obj} |  $..isMarried |
|Should Not Have Value In Json  | ${json_obj} |  $..hasSiblings |
|Dump Json To File  | \${OUTPUT_DIR}\${/}output.json | ${json} |
|${schema_json_obj}=      | Load Json From File | schema.json     |            |                  |
|Validate Json By Schema      | ${json_obj} | ${schema_json_obj} |         |           |
|Validate Json By Schema File | ${json_obj} | schema.json |         |           |

# Documentation

- **Keyword Documentation**: [https://veertuinc.github.io/robotframework-jsonlib](https://veertuinc.github.io/robotframework-jsonlib)
- **JSONPath Syntax Examples**: [https://goessner.net/articles/JsonPath/index.html#e3](https://goessner.net/articles/JsonPath/index.html#e3)
- **JSONPath Parser (jsonpath-ng)**: [https://github.com/h2non/jsonpath-ng](https://github.com/h2non/jsonpath-ng)
- **GitHub Repository**: [https://github.com/veertuinc/robotframework-jsonlib](https://github.com/veertuinc/robotframework-jsonlib)

# Contributing

Contributions are welcome! Please see [DEVELOPMENT.md](DEVELOPMENT.md) for:
- Setting up your development environment
- Running tests and CI checks
- Building and publishing the package
- Coding standards and guidelines

# Help & Support

- **Issues**: Report bugs or request features at [GitHub Issues](https://github.com/veertuinc/robotframework-jsonlib/issues)
- **Discussions**: Ask questions at [GitHub Discussions](https://github.com/veertuinc/robotframework-jsonlib/discussions)



