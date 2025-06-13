"""Aspect that will collect information necessary for VSCode settings.json file creation."""

ClassPathInfo = provider(
    "Provider for classpath and source path information",
    fields = {
        "jars": "A depset of structs containing class_jar and source_jar paths.",
        "source_roots": "A depset of source root directories.",
    },
)

def _get_source_root(path):
    """Heuristically determines the source root from a source file's path.

    It looks for common Java source directory patterns.

    For a path like 'project/src/main/java/com/foo/Bar.java', it returns
    'project/src/main/java'. Returns the file's directory if no pattern is found.
    """
    # https://github.com/bazelbuild/rules_java/blob/d927aa05abfda8bf3fb988ab77dc73d5f2a825f5/java/common/rules/impl/java_helper.bzl#L109
    known_roots = [
        "src/main/java",
        "src/test/java",
        "src/main/kotlin",
        "src/test/kotlin",
        "src/main/scala",
        "src/test/scala",
        "src",
        "java",
        "testsrc",
    ]

    for known_root in known_roots:
        # Check if the pattern is a complete directory in the path
        # (e.g., 'src/main/java/' or 'src/main/java' at the end)
        search_pattern = known_root + "/"
        # Return the path up to and including the root part
        if search_pattern in path:
            return path.split(search_pattern, 1)[0] + known_root
    
    fail("Could not determine source root for path: " + path)

def _classpath_aspect_impl(target, ctx):
    java_info = target[JavaInfo]

    direct_jars = []
    if java_info.java_outputs:
        class_jar = java_info.java_outputs[0].class_jar
        source_jar = java_info.java_outputs[0].source_jar
        direct_jars.append(struct(
            class_jar = class_jar.path if class_jar else None,
            source_jar = source_jar.path if source_jar else None,
        ))

    transitive = [
        dep[ClassPathInfo].jars
        for dep in getattr(ctx.rule.attr, "deps", [])
        if ClassPathInfo in dep
    ]

    all_jars = depset(
        direct = direct_jars,
        transitive = transitive,
    )

    direct_source_roots = []
    for src in getattr(ctx.rule.attr, "srcs", []):
        source_root = _get_source_root(src.files.to_list()[0].path)
        direct_source_roots.append(source_root)

    transitive_source_roots = [
        dep[ClassPathInfo].source_roots
        for dep in getattr(ctx.rule.attr, "deps", [])
        if ClassPathInfo in dep
    ]

    all_source_roots = depset(
        direct = direct_source_roots,
        transitive = transitive_source_roots,
    )

    return [
        ClassPathInfo(
            jars = all_jars,
            source_roots = all_source_roots,
        ),
    ]

classpath_aspect = aspect(
    implementation = _classpath_aspect_impl,
    # attr_aspects is a list of rule attributes along
    # which the aspect propagates.
    attr_aspects = ["deps"],
    required_providers = [JavaInfo],
)
