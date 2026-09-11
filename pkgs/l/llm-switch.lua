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
    -- v0.1.1 has no release assets and v0.1.9 has no remaining tag/release,
    -- so neither can be represented as an installable package version.
    -- All other releases with complete platform assets remain indexed below.
    -- The per-arch maps deliberately leave unsupported host combinations
    -- absent so XPackage V2 fails closed instead of serving a wrong binary.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                x86_64 = asset("0.1.10", "llm-switch-v0.1.10-linux-x86_64.tar.gz",
                    "dda934829f28989b849d1b9c9fc58835937f491d6b2aba90fe3906a5ea8dd551"),
            },
            ["0.1.8"] = {
                x86_64 = asset("0.1.8", "llm-switch-v0.1.8-linux-x86_64.tar.gz",
                    "74686e19746e76799579324554536df848ae3f6628a5b9e736932f7829ca85df"),
            },
            ["0.1.7"] = {
                x86_64 = asset("0.1.7", "llm-switch-v0.1.7-linux-x86_64.tar.gz",
                    "b804fb0e22e2b1e4fd4543ae845ad46e757f23a2cdae3269f1e992b2911ddba4"),
            },
            ["0.1.6"] = {
                x86_64 = asset("0.1.6", "llm-switch-v0.1.6-linux-x86_64.tar.gz",
                    "f382ffcc3e7fa612a34c16640b8c7f25d756cc17a0c3e9e8988f1d3f6be1ec71"),
            },
            ["0.1.5"] = {
                x86_64 = asset("0.1.5", "llm-switch-linux-x86_64.tar.gz",
                    "eb23474463eb4ca46e3f46e626e01d42211df061eecaa03762a9d6bd387f6c95"),
            },
            ["0.1.4"] = {
                x86_64 = asset("0.1.4", "llm-switch-linux-x86_64.tar.gz",
                    "7c16a479854bcc8a1565518463a66d038f8ba4889ffaab5a5c9a00e86cc27207"),
            },
            ["0.1.3"] = {
                x86_64 = asset("0.1.3", "llm-switch-v0.1.3-linux-x86_64.tar.gz",
                    "7b9831d58d22fab19d73e0554cfc7b2354e2ec994c48431550c8042d3afa85c5"),
            },
            ["0.1.2"] = {
                x86_64 = asset("0.1.2", "llm-switch-v0.1.2-linux-x86_64.tar.gz",
                    "7462d939fb30f65c007919e825c34dc6c0cc8f4dd6ace76a72a121a6728558d7"),
            },
            ["0.1.0"] = {
                x86_64 = asset("0.1.0", "llm-switch-linux-x86_64.tar.gz",
                    "e84881e7fad18294a6f13c7eba0eb3a333d46f484e991bee4a104e3f9b06cd9b"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                aarch64 = asset("0.1.10", "llm-switch-v0.1.10-macos-arm64.tar.gz",
                    "959b3caeb8cd8ad417439ec0f9995a6f3c89cef0522971899721a96f8b331ac8"),
            },
            ["0.1.8"] = {
                aarch64 = asset("0.1.8", "llm-switch-v0.1.8-macos-arm64.tar.gz",
                    "bf8ba4ed16fde34b8067f4994b3db57202f0fae6f9724f1beded1543e1be17c1"),
            },
            ["0.1.7"] = {
                aarch64 = asset("0.1.7", "llm-switch-v0.1.7-macos-arm64.tar.gz",
                    "27a28e8d596e7b38349baaf49deab540a01ff400f4080b7009147bdd86287c79"),
            },
            ["0.1.6"] = {
                aarch64 = asset("0.1.6", "llm-switch-v0.1.6-macos-arm64.tar.gz",
                    "befcfb0e621ce3a21d3b727fa667b98d43648c797912ea2033fded9a11f5c6b6"),
            },
            ["0.1.5"] = {
                aarch64 = asset("0.1.5", "llm-switch-macos-arm64.tar.gz",
                    "56f9c40c923cf7c51b0eb59352970d35f6b764dbec0990e32636c28de032eefd"),
            },
            ["0.1.4"] = {
                aarch64 = asset("0.1.4", "llm-switch-macos-arm64.tar.gz",
                    "e6f314855a4c9f73354f982e98e024cceb6c54b20d8868d042f22da8d3a20043"),
            },
            ["0.1.3"] = {
                aarch64 = asset("0.1.3", "llm-switch-v0.1.3-macos-arm64.tar.gz",
                    "548ed5817755a60af77b408f0185bc7a5965c8698df710e20952ea4e48daf709"),
            },
            ["0.1.2"] = {
                aarch64 = asset("0.1.2", "llm-switch-v0.1.2-macos-arm64.tar.gz",
                    "c8b7365633add5fe4b01f77493cf9c0220fbbf5c5783cdc3e24e2ed669e92492"),
            },
            ["0.1.0"] = {
                aarch64 = asset("0.1.0", "llm-switch-macos-arm64.tar.gz",
                    "82495225b34fff1b770772d53a71372540b620292d75d665efad6d9dfad3d9bc"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.10" },
            ["0.1.10"] = {
                x86_64 = asset("0.1.10", "llm-switch-v0.1.10-windows-x86_64.zip",
                    "b892d6ad0f0f19aa15376567139740d27d5d83ce3da8fb1cf223e043a34c3c38"),
            },
            ["0.1.8"] = {
                x86_64 = asset("0.1.8", "llm-switch-v0.1.8-windows-x86_64.zip",
                    "e77930f9fc1452dc5218260fd8f1f8ecaa3395d68259a3b48bb2cc1d2f634669"),
            },
            ["0.1.7"] = {
                x86_64 = asset("0.1.7", "llm-switch-v0.1.7-windows-x86_64.zip",
                    "ed1c4c5587d7fee43377be2f637a4ddeaa309228771cba5ef0344829c5690e33"),
            },
            ["0.1.6"] = {
                x86_64 = asset("0.1.6", "llm-switch-v0.1.6-windows-x86_64.zip",
                    "35d3f9dc112586768b9263498fe01f1ee4d24d37a547cd8b9c7e863d7760fea1"),
            },
            ["0.1.5"] = {
                x86_64 = asset("0.1.5", "llm-switch-windows-x86_64.zip",
                    "830973ce89be9bd19530792bedbe8924970d4997ad3758d879f98ff69f7f316f"),
            },
            ["0.1.4"] = {
                x86_64 = asset("0.1.4", "llm-switch-windows-x86_64.zip",
                    "5b529b8fdb8a358a735527a403b3df760866e13f4f277c6480e4ac0ac7d1996c"),
            },
            ["0.1.3"] = {
                x86_64 = asset("0.1.3", "llm-switch-v0.1.3-windows-x86_64.zip",
                    "a82f48b882d68f08a3af31931dd38331fd8333f0c22597f92e1884e6d45e9b9d"),
            },
            ["0.1.2"] = {
                x86_64 = asset("0.1.2", "llm-switch-v0.1.2-windows-x86_64.zip",
                    "af4dc7d5a72f76a514981b210cddab73b2b02ed0d4c0d5ebfb488932f136d25a"),
            },
            ["0.1.0"] = {
                x86_64 = asset("0.1.0", "llm-switch-windows-x86_64.zip",
                    "a25468a8ce8986ebffd50db2f876088f6dda909e7c7a948343ece044a31f33d6"),
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
