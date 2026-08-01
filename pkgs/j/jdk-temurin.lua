package = {
    spec = "2",

    -- base info
    name = "jdk-temurin",
    description = "Eclipse Temurin JDK 25 — a production-ready binary build of OpenJDK (LTS)",

    homepage = "https://adoptium.net",
    repo = "https://github.com/adoptium/temurin25-binaries",
    docs = "https://adoptium.net/docs",
    authors = {"Eclipse Adoptium"},
    licenses = {"GPL-2.0-with-classpath-exception"},

    -- xim pkg info
    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "stable",
    categories = {"language", "jvm", "runtime", "toolchain"},
    keywords = {"java", "jdk", "openjdk", "temurin", "jvm", "hotspot"},

    programs = {"java", "javac", "jar", "javadoc", "jshell"},
    xvm_enable = true,

    -- WHY THE NAME
    --
    -- The flavor is in the package name (`jdk-temurin`) so other
    -- distributions can coexist as jdk-oracle / jdk-microsoft / jdk-zulu
    -- later; the JDK version lives in the version dimension (25.0.4+7), so
    -- future JDK 26/27 land in this same package. This mirrors how apt
    -- (`openjdk-25-jdk`) / dnf (`java-25-openjdk`) / Arch (`jdk25-openjdk`)
    -- all embed the flavor in the name.
    --
    -- PROVENANCE — Temurin (Eclipse Adoptium) 25.0.4+7, released 2026-07-29.
    -- Per-arch sha256 fetched from the Adoptium API
    -- (api.adoptium.net/v3/assets/latest/25/hotspot).
    --
    -- RESOURCE SHAPE — Shape B per-arch resource maps, because Adoptium's
    -- release tag and archive filename encode the build number differently:
    --   tag  jdk-25.0.4+7                  (URL-escaped as %2B)
    --   file OpenJDK25U-jdk_..._25.0.4_7.  (build joined with '_')
    -- A URL template cannot express both encodings, so each os/arch URL is
    -- explicit. (The `+` version string itself is fine: it registers and
    -- resolves under current xlings, verified locally.)
    --
    -- ARCH COVERAGE — Temurin 25 ships linux + macosx on x86_64/aarch64 but
    -- only x86_64 on windows (no windows-aarch64 JDK image for 25), so the
    -- windows entry has a single arch. `archs = {x86_64, aarch64}` is the
    -- union; a windows-aarch64 host fails closed with a clear error, which is
    -- the intended fail-closed behavior.
    --
    -- RUNTIME DEPS — deliberately NONE on linux, unlike node.lua. The Temurin
    -- JDK dynamically links host glibc, and every host in CI has it. Rewriting
    -- INTERP/RPATH across the JDK's large ELF tree (libjvm & co.) via the
    -- predicate-driven elfpatch is unvalidated at index time and risky; Alpine
    -- / distroless support can add `deps = { runtime = {...} }` once a
    -- real-machine elfpatch pass is verified.
    xpm = {
        linux = {
            ["latest"] = { ref = "25.0.4+7" },
            ["25.0.4+7"] = {
                x86_64 = {
                    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4%2B7/OpenJDK25U-jdk_x64_linux_hotspot_25.0.4_7.tar.gz",
                    sha256 = "e58fcdcd637b25c03ca84cbbcefc70d11efb8f4b4cbd05decc9f661769d77f94",
                },
                aarch64 = {
                    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4%2B7/OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.4_7.tar.gz",
                    sha256 = "621f7196f0b682fb557da58bec89bd7dfe5419811fe1c0ba75c9cc8432f084c7",
                },
            },
        },
        macosx = {
            ["latest"] = { ref = "25.0.4+7" },
            ["25.0.4+7"] = {
                x86_64 = {
                    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4%2B7/OpenJDK25U-jdk_x64_mac_hotspot_25.0.4_7.tar.gz",
                    sha256 = "a5ac9c46dad47ac06df35e36d096913195d8da1f3f71918828bcc2cfe33869b7",
                },
                aarch64 = {
                    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4%2B7/OpenJDK25U-jdk_aarch64_mac_hotspot_25.0.4_7.tar.gz",
                    sha256 = "5a101c54abf5a9f16c0f70d8c38ba99e6567c1ba213378f0bb04497284f051bd",
                },
            },
        },
        windows = {
            ["latest"] = { ref = "25.0.4+7" },
            ["25.0.4+7"] = {
                x86_64 = {
                    url = "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25.0.4%2B7/OpenJDK25U-jdk_x64_windows_hotspot_25.0.4_7.zip",
                    sha256 = "7caab7db43bf4b94a2e6252c699e70d90084f9aa7c943cd3414761fd540937ae",
                },
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.xvm")
import("xim.libxpkg.log")

function install()
    -- Every Temurin archive — all os/arch pairs — expands to the SAME
    -- top-level directory `jdk-<version>/` (e.g. jdk-25.0.4+7), so this hook
    -- needs no arch knowledge.
    --
    -- Idempotent across xim engines (same rationale as perl.lua): some stage
    -- the extracted payload into install_dir() before/without the hook, others
    -- leave it in the hook CWD for us to move. Never wipe install_dir before a
    -- replacement payload is confirmed, and never report success unless the
    -- launcher is actually in place — `return true` over an empty dir gets
    -- stamped as installed and leaves dangling xvm shims behind.
    local exe = os.host() == "windows" and "java.exe" or "java"
    local staged = path.join(pkginfo.install_dir(), "bin", exe)
    if os.isfile(staged) then return true end

    local payload = "jdk-" .. pkginfo.version()
    if os.isdir(payload) then
        os.tryrm(pkginfo.install_dir())
        os.mv(payload, pkginfo.install_dir())
    end
    return os.isfile(staged)
end

function config()
    local bindir = path.join(pkginfo.install_dir(), "bin")
    local binding = "jdk-temurin@" .. pkginfo.version()

    -- Register the package name itself so `xlings use jdk-temurin` can switch
    -- between installed JDK versions.
    xvm.add("jdk-temurin", { bindir = bindir })

    -- Core developer-facing launchers. The tree also carries ~90 more tools
    -- (jlink, jmod, jpackage, keytool, ...); they stay reachable through
    -- <install>/bin and are deliberately NOT registered, so installing the
    -- JDK doesn't shadow unrelated system tools.
    for _, prog in ipairs({ "java", "javac", "jar", "javadoc", "jshell" }) do
        xvm.add(prog, { bindir = bindir, binding = binding })
    end

    return true
end

function uninstall()
    xvm.remove("jdk-temurin")
    for _, prog in ipairs({ "java", "javac", "jar", "javadoc", "jshell" }) do
        xvm.remove(prog)
    end
    return true
end
