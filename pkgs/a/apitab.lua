local function asset(version, filename, sha256)
    local url = string.format(
        "https://github.com:443/FarnaHerry/apitab/releases/download/v%s/%s",
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

    name = "apitab",
    namespace = "farnaherry",
    description = "Desktop API development tool with request management, testing, mocks, history, load testing, and a CLI",
    homepage = "https://github.com/FarnaHerry/apitab",
    authors = {"FarnaHerry"},
    maintainers = {"FarnaHerry"},
    licenses = {"MIT"},
    repo = "https://github.com/FarnaHerry/apitab",
    docs = "https://github.com/FarnaHerry/apitab#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "dev",
    categories = {"app", "api", "testing", "tools"},
    keywords = {"api", "http", "websocket", "mock", "load-testing", "cli"},

    -- The default entry is a GUI; its CLI is explicitly selected with
    -- `apitab --cli ...`, so it is not a standalone program for the generic
    -- Windows executable probe. `config()` still registers `apitab` in xvm.
    programs = {},
    xvm_enable = true,

    -- v0.1.1 is the latest non-prerelease GitHub release (2026-09-11).
    -- Linux and macOS publish portable archives. Windows publishes an NSIS
    -- installer, so its install hook below runs that installer into the
    -- xlings package directory instead of falling back to the old release.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                x86_64 = asset("0.1.1", "apitab-v0.1.1-linux-x86_64.tar.gz",
                    "af73459e6b404d209852d5ea126bcb074f8182a1e697f5bc374dbf4365bc6d0c"),
            },
            ["0.1.0"] = {
                x86_64 = asset("0.1.0", "apitab-v0.1.0-linux-x86_64.tar.gz",
                    "1d241798a15e87a4071daa0f702e6284d8dec16e38422f4b10bc323aba7d3429"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                aarch64 = asset("0.1.1", "apitab-v0.1.1-macos-arm64.tar.gz",
                    "41c1aee1cc32207fda2ab2274a4a834cf78705f5e93b8072ddbd644f2d9697fd"),
            },
            ["0.1.0"] = {
                aarch64 = asset("0.1.0", "apitab-v0.1.0-macos-arm64.tar.gz",
                    "0dc7f5e56b33393042e62c5d86323febed35b8890526b54667ac25a4cbdb5948"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                x86_64 = asset("0.1.1", "apitab-v0.1.1-windows-x86_64-setup.exe",
                    "3982acdcee90b7b9af378c5386d4f0b8bb121cf40b1d7511d79b368b7d770c5c"),
            },
            ["0.1.0"] = {
                x86_64 = asset("0.1.0", "apitab-v0.1.0-windows-x86_64.zip",
                    "9ed24a27c36bcddce146b7f75205302c8a9f11cebea91977207cf55874e5325f"),
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

    if is_host("windows") and pkginfo.version() == "0.1.1" then
        -- v0.1.1 only ships a per-user NSIS installer on Windows. NSIS uses
        -- /S for silent mode and /D= to select the package-owned directory.
        os.mkdir(dir)
        system.exec(string.format(
            [[powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%s' -ArgumentList '/S','/D=%s' -Wait | Out-Null"]],
            winpath(pkginfo.install_file()), winpath(dir)))
        return os.isfile(path.join(dir, "apitab.exe"))
    end

    -- Unix archives contain a `dist/` directory; the Windows zip is flat.
    local src = is_host("windows") and base or path.join(base, "dist")
    copy_payload(src, dir)

    local exe = path.join(dir, is_host("windows") and "apitab.exe" or "apitab")
    if not is_host("windows") then
        system.exec(string.format('chmod +x "%s" "%s"',
            exe, path.join(dir, "engines", "k6")))
    end
    return os.isfile(exe)
end

function config()
    xvm.add(package.name, { bindir = pkginfo.install_dir() })
    return true
end

function uninstall()
    xvm.remove(package.name)
    if is_host("windows") and pkginfo.version() == "0.1.1" then
        local uninstaller = path.join(pkginfo.install_dir(), "Uninstall.exe")
        if os.isfile(uninstaller) then
            system.exec(string.format(
                [[powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%s' -ArgumentList '/S' -Wait | Out-Null"]],
                winpath(uninstaller)))
        end
    end
    return true
end
