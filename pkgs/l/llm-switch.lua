local function asset(version, filename, sha256)
    return {
        url = string.format(
            "https://github.com/FarnaHerry/llm-switch/releases/download/v%s/%s",
            version, filename),
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

    -- v0.1.4 is the latest non-prerelease GitHub release (2026-09-08).
    -- The release currently ships Linux/Windows x86_64 and macOS arm64.
    -- The per-arch maps deliberately leave unsupported host combinations
    -- absent so XPackage V2 fails closed instead of serving a wrong binary.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.4" },
            ["0.1.4"] = {
                x86_64 = asset("0.1.4", "llm-switch-linux-x86_64.tar.gz",
                    "7c16a479854bcc8a1565518463a66d038f8ba4889ffaab5a5c9a00e86cc27207"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.4" },
            ["0.1.4"] = {
                aarch64 = asset("0.1.4", "llm-switch-macos-arm64.tar.gz",
                    "e6f314855a4c9f73354f982e98e024cceb6c54b20d8868d042f22da8d3a20043"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.4" },
            ["0.1.4"] = {
                x86_64 = asset("0.1.4", "llm-switch-windows-x86_64.zip",
                    "5b529b8fdb8a358a735527a403b3df760866e13f4f277c6480e4ac0ac7d1996c"),
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
