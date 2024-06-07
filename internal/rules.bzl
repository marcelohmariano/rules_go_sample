load(":actions.bzl", "go_build_stdlib", "go_compile", "go_link")

def _go_binary_impl(ctx):
    archive = ctx.actions.declare_file(
        "{name}_/{name}.a".format(name = ctx.label.name),
    )

    go_compile(
        ctx,
        srcs = ctx.files.srcs,
        stdlib = ctx.files._stdlib,
        out = archive,
    )

    executable_path = "{name}_/{name}".format(name = ctx.label.name)
    executable = ctx.actions.declare_file(executable_path)

    go_link(
        ctx,
        archive = archive,
        stdlib = ctx.files._stdlib,
        out = executable,
    )

    return [DefaultInfo(
        files = depset([executable]),
        executable = executable,
    )]

go_binary = rule(
    implementation = _go_binary_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".go"],
        ),
        "_stdlib": attr.label(
            default = ":stdlib",
        ),
    },
    executable = True,
)

def _go_stdlib_impl(ctx):
    importcfg, cache = go_build_stdlib(ctx, ctx.file._template)
    return [
        DefaultInfo(files = depset([importcfg, cache])),
    ]

go_stdlib = rule(
    implementation = _go_stdlib_impl,
    attrs = {
        "_template": attr.label(
            default = ":build_stdlib.sh.tpl",
            allow_single_file = True,
        ),
    },
)
