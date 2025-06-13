load("//:aspect.bzl", "classpath_aspect", "ClassPathInfo")

def _vscode_settings_impl(ctx):
    all_jars = []
    all_source_roots = []

    for target in ctx.attr.targets:
        if ClassPathInfo in target:
            all_jars.extend(target[ClassPathInfo].jars.to_list())
            all_jars.extend(target[ClassPathInfo].jars.to_list())
            all_source_roots.extend(target[ClassPathInfo].source_roots.to_list())

    # Use a dict to automatically handle duplicates from the depset
    unique_jars = {j.class_jar: j.source_jar for j in all_jars}

    referenced_libs = []
    source_map = {}

    for class_jar, source_jar in unique_jars.items():
        if class_jar:
            referenced_libs.append(class_jar)
            if source_jar:
                source_map[class_jar] = source_jar

    settings = {
        "java.project.sourcePaths": sorted(all_source_roots),
        "java.import.maven.enabled": False,
        "java.import.gradle.enabled": False,
        "java.import.projectSelection": "manual",
        "java.project.referencedLibraries": {
            "include": sorted(referenced_libs),
            "sources": source_map,
        },
    }

    output_file = ctx.actions.declare_file(ctx.label.name + ".json")
    ctx.actions.write(
        output = output_file,
        content = json.encode_indent(settings, indent = "    "),
    )
    return [DefaultInfo(files = depset([output_file]))]

vscode_settings = rule(
    implementation = _vscode_settings_impl,
    attrs = {
        "targets": attr.label_list(
            aspects = [classpath_aspect],
            doc = "The list of top-level java targets to include in the project.",
        ),
    },
    doc = "Generates a VS Code settings.json file for a Java project.",
)
