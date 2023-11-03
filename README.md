# Include Code Files Extension For Quarto

Filter to include code from source files.

The filter is largely inspired by
[pandoc-include-code](https://github.com/owickstrom/pandoc-include-code) and [sphinx-literalinclude](https://www.sphinx-doc.org/en/master/usage/restructuredtext/directives.html#directive-literalinclude).

## Installing

```bash
quarto add quarto-ext/include-code-files
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Usage

The filter recognizes code blocks with the `include` attribute present. It swaps the content of the code block with contents from a file.

Here is how you add the filter to a page (it can also be added to a `_quarto.yml` project file with the same syntax):

````markdown
---
title: "My Document"
filters:
   - include-code-files
---

````

### Including Files

Once adding the filter to you page or project, the simplest way to use the filter is the `include` attribute

    ```{.python include="script.py"}
    ```

You can still use other attributes, and classes, to control the code blocks:

    ```{.python include="script.py" code-line-numbers="true"}
    ```

### Dedent

Using the `dedent` attribute, you can have whitespaces removed on each line, where possible (non-whitespace character will not be removed even if they occur
in the dedent area).

    ```{.python include="script.py" dedent=4}
    ```

### Ranges

If you want to include a specific range of lines, use `start-line` and `end-line`:

    ```{.python include="script.py" start-line=35 end-line=80}
    ```

#### New in Version 1.1

`include-code-files` now supports additional attributes to specify ranges:

* `start-after`: Start immediately after the specified line
* `end-before`: End immediately before the specified line

Furthermore, all range attributes (including `start-line` and `end-line`) now support both numeric and string values.

Using string comments in code, in combination with the `start-after` and `end-before` range attributes allows for
editing of the include file without requiring you to re-determine the proper numeric values after the changes are complete.

For example, in this python file:

    ```python
    # [my_method start]
    def my_method():
        print("do work")
    # [my_method end]
    ```

To include just the method in your code block, you can do the following:

    ```{.python include="script.py" start-after="[my_method start]" end-after="[my_method end]"}
    ```

Then as you edit your method, only the lines between `[my_method start]` and `[my_method end]` will be included in the output.

Note that any combination of start and end attributes is supported. See the test setup in `index.qmd` for more examples.
