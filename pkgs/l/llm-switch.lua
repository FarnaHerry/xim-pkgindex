local function asset(version, filename, sha256)
    local url = string.format(
        "https://github.com:443/FarnaHerry/llm-switch/releases/download/v%s/%s",
        version, filename)
    return {
        -- Keep the official URL for both routes.  The explicit port prevents
        -- the CI download proxy from rewriting GitHub release URLs.
        url = { GLOBAL = url, CN = url },
        sha256 = sha256,
    }
end

package = {
    spec = "2",

    name = "llm-switch",
    namespace = "farnaherry",
    description = "Desktop provider switcher and local router for Claude Code, Codex, opencode, pi, and Claude Desktop",
    homepage = "https://github.com/FarnaHerry/llm-switch",
    authors = {"FarnaHerry"},
    maintainers = {"FarnaHerry"},
    licenses = {"MIT"},
    repo = "https://github.com/FarnaHerry/llm-switch",
    docs = "https://github.com/FarnaHerry/llm-switch#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "dev",
    categories = {"app", "ai", "tools"},
    keywords = {"llm", "claude", "codex", "opencode", "provider", "router"},

    -- This is a GUI-only binary; `config()` still registers the package name
    -- as its xvm entry, but there is no non-interactive program for CI to run.
    programs = {},
    xvm_enable = true,

    -- v0.1.10 is the latest non-prerelease GitHub release (2026-09-11).
    -- The per-arch maps deliberately leave unsupported host combinations
    -- absent so XPackage V2 fails closed instead of serving a wrong binary.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                x86_64 = asset("0.1.10", "llm-switch-v0.1.10-linux-x86_64.tar.gz",
                    "dda934829f28989b849d1b9c9fc58835937f491d6b2aba90fe3906a5ea8dd551"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                aarch64 = asset("0.1.10", "llm-switch-v0.1.10-macos-arm64.tar.gz",
                    "959b3caeb8cd8ad417439ec0f9995a6f3c89cef0522971899721a96f8b331ac8"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                x86_64 = asset("0.1.10", "llm-switch-v0.1.10-windows-x86_64.zip",
                    "b892d6ad0f0f19aa15376567139740d27d5d83ce3da8fb1cf223e043a34c3c38"),
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.system")
import("xim.libxpkg.xvm")

local function winpath(p)
    return (p:gsub("/", "\\"))
end

-- Linux and Windows archives contain a flat portable application directory;
-- macOS contains the complete `llm-switch.app` bundle.
local function copy_payload(src, dst)
    os.mkdir(dst)
    if is_host("windows") then
        system.exec(string.format('xcopy "%s\\*" "%s\\" /E /I /Y /Q',
            winpath(src), winpath(dst)))
    else
        system.exec(string.format('cp -a "%s"/. "%s"/', src, dst))
    end
end

function install()
    local dir = pkginfo.install_dir()
    local base = path.directory(pkginfo.install_file())
    os.tryrm(dir)
    os.mkdir(dir)

    if is_host("macosx") then
        local app = path.join(base, "llm-switch.app")
        os.mv(app, path.join(dir, "llm-switch.app"))
    else
        copy_payload(base, dir)
    end

    local exe = is_host("macosx")
        and path.join(dir, "llm-switch.app", "Contents", "MacOS", "llm-switch")
        or path.join(dir, is_host("windows") and "llm-switch.exe" or "llm-switch")
    if not is_host("windows") then
        -- Archive extraction does not reliably preserve executable bits.
        system.exec(string.format('chmod +x "%s"', exe))
    end
    return os.isfile(exe)
end

function config()
    local bindir = pkginfo.install_dir()
    if is_host("macosx") then
        bindir = path.join(bindir, "llm-switch.app", "Contents", "MacOS")
    end
    xvm.add(package.name, { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove(package.name)
    return true
end
