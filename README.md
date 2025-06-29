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

Here is an example from the [example](./example/) directory that is produced.

```json
{
    "java.import.gradle.enabled": false,
    "java.import.maven.enabled": false,
    "java.import.projectSelection": "manual",
    "java.project.referencedLibraries": {
        "include": [
            "bazel-out/darwin_arm64-fastbuild/bin/external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/processed_gson-2.13.1.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/errorprone/error_prone_annotations/2.38.0/processed_error_prone_annotations-2.38.0.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/HelloWorld.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/libLibrary.jar"
        ],
        "sources": {
            "bazel-out/darwin_arm64-fastbuild/bin/external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/processed_gson-2.13.1.jar": "external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/gson-2.13.1-sources.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/errorprone/error_prone_annotations/2.38.0/processed_error_prone_annotations-2.38.0.jar": "external/rules_jvm_external++maven+maven/v1/https/repo1.maven.org/maven2/com/google/errorprone/error_prone_annotations/2.38.0/error_prone_annotations-2.38.0-sources.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/HelloWorld.jar": "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/HelloWorld-src.jar",
            "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/libLibrary.jar": "bazel-out/darwin_arm64-fastbuild/bin/java/com/example/libLibrary-src.jar"
        }
    },
    "java.project.sourcePaths": [
        "java"
    ]
}
```

## Common Gotchas

1. Make sure you `bazel build`

VSCode needs to be able to actually find the dependencies in the `bazel-out` directory which means you must have `bazel build` the targets you care about.
I recommend a `bazel build //...` to catch it all.

> Bazel keeps prior builds in the same `bazel-out` so subsequent builds for different targets doesn't affect it unless you do `bazel clean`.

2. If you are using _build without the bytes_, make sure you have `--remote_download_outputs=all` set so that all the needed dependencies are present.