# Project Generator

A really simple project generator script. You can add files in the
[templates](templates) directory to have them copied into your project
when it is generated.

Hidden files should be saved without the dot prefix. Hidden files must also
be configured in the `rename` function, otherwise they won't be turned into
hidden files during the copy process.

Variable substitution is performed on all template files. If you need to add
new variables, modify the `sed` function.

Usage:
```shell
generate-project destination-dir [name] [description]
```

If a name is not provided, it will be the same as the directory name.
If a description is not provided, it will be the same as the project name.
