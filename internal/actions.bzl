load("@bazel_skylib//lib:shell.bzl", "shell")

def go_compile(ctx, *, srcs, stdlib, out):
    importcfg = stdlib[0]

    cmd = "go tool compile -o {out} -importcfg {importcfg} -- {srcs}".format(
        out = shell.quote(out.path),
        importcfg = shell.quote(importcfg.path),
        srcs = " ".join([shell.quote(src.path) for src in srcs]),
    )

    ctx.actions.run_shell(
        outputs = [out],
        inputs = srcs + stdlib,
        command = cmd,
        env = {"GOPATH": "/dev/null"},
        mnemonic = "GoCompile",
        use_default_shell_env = True,
    )

def go_link(ctx, *, archive, stdlib, out):
    importcfg = stdlib[0]

    cmd = "go tool link -o {out} -importcfg {importcfg} -- {archive}".format(
        out = shell.quote(out.path),
        importcfg = shell.quote(importcfg.path),
        archive = shell.quote(archive.path),
    )

    ctx.actions.run_shell(
        outputs = [out],
        inputs = [archive] + stdlib,
        command = cmd,
        env = {"GOPATH": "/dev/null"},
        mnemonic = "GoLink",
        use_default_shell_env = True,
    )

def go_build_stdlib(ctx, template):
    prefix = ctx.label.name + "_/"

    importcfg = ctx.actions.declare_file(prefix + "importcfg")
    cache = ctx.actions.declare_directory(prefix + "cache")
    executable = ctx.actions.declare_file(prefix + "build_stdlib.sh")

    ctx.actions.expand_template(
        template = template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{importcfg}": importcfg.path,
            "{cache}": cache.path,
        },
    )
    ctx.actions.run(
        outputs = [importcfg, cache],
        executable = executable,
        use_default_shell_env = True,
    )

    return importcfg, cache
