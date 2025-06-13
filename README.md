# vscode.bzl

This is a [Bazel](https://bazel.build/) ruleset for making a Visual Studio Code (VSCode) project for Java projects.

Why?

IntelliJ has **2** plugins now that help with Java based projects, however lots of AI tools are available in the VSCode ecosystem. I would like to take advantage of them while still having some sensible intellisense.

> 🚨 At the moment this repository is meant to help with JVM based projects.
> If you are doing other languages, they already have decent support via other rulesets.

## Getting Started

```starlark
# use the latest version
bazel_dep(name = "vscode.bzl", version = ...)
```

Now in a top-level `BUILD.bazel` file declare the targets you would like to build the `settings.json` file for.

```starlark
load("@vscode.bzl", "vscode_settings")

vscode_settings(
    name = "vscode_settings",
    targets = [
        "//java/com/example:HelloWorld",
    ],
)
```

Simply build the `vscode_settings` target and it will produce a VSCode appropriate `settings.json` file.

```console
> bazel build //:vscode_settings
INFO: Invocation ID: 285601b2-2047-43d4-9f56-c416a839f43a
INFO: Analyzed target //:vscode_settings (1 packages loaded, 5 targets configured).
INFO: Found 1 target...
Target //:vscode_settings up-to-date:
  bazel-bin/vscode_settings.json
```

You will likely want to symlink that file to your `.vscode` directory

```bash
ln -s ../bazel-bin/vscode_settings.json .vscode/settings.json
```

Reload VSCode and voila!

> ❗ Make sure you have the [Java Extension Pack](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack) installed.


You will notice the `settings.json` file will be produced with source roots, compilation JARs **and** source-jars if you have them enabled through _rules_jvm_external_.