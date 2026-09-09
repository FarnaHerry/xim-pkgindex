local function asset(version, filename, sha256)
    return {
        url = string.format(
            "https://github.com/FarnaHerry/tinynext/releases/download/v%s/%s",
            version, filename),
        sha256 = sha256,
    }
end

package = {
    spec = "2",

    name = "tinynext",
    namespace = "FarnaHerry",
    description = "Cross-platform GUI downloader with aria2-next, video extraction, and a headless CLI",
    homepage = "https://github.com/FarnaHerry/tinynext",
    authors = {"FarnaHerry"},
    maintainers = {"FarnaHerry"},
    licenses = {"MIT"},
    repo = "https://github.com/FarnaHerry/tinynext",
    docs = "https://github.com/FarnaHerry/tinynext#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "dev",
    categories = {"app", "download", "tools"},
    keywords = {"downloader", "aria2", "torrent", "magnet", "yt-dlp", "gui"},

    -- The default entry is a GUI. Its CLI is argument-driven (`agent`,
    -- `--headless`, URLs, etc.), so it is not a standalone program for the
    -- generic Windows executable probe. `config()` still registers `tinynext`.
    programs = {},
    xvm_enable = true,

    -- v0.5.20 is the latest non-prerelease GitHub release (2026-09-05).
    -- The release currently ships Linux x86_64, macOS arm64, and Windows x64.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.5.20" },
            ["0.5.20"] = {
                x86_64 = asset("0.5.20", "tinynext-v0.5.20-linux-x86_64.tar.gz",
                    "e0dba9306f87560b614b58fc907dcf23242f587657c32eb255d0f0272774e48"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.5.20" },
            ["0.5.20"] = {
                aarch64 = asset("0.5.20", "tinynext-v0.5.20-macos-arm64.tar.gz",
                    "fb8ac11dc485473f7b362321c6185ae704dd0303da489bc153feb7208b950e"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.5.20" },
            ["0.5.20"] = {
                x86_64 = asset("0.5.20", "tinynext-v0.5.20-win64.zip",
                    "d71c768419cb934f687f97c25b4f0c1f0e92730da6cc2978712cc2226369dde0"),
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

local function chmod_if_file(filename)
    if os.isfile(filename) then
        system.exec(string.format('chmod +x "%s"', filename))
    end
end

function install()
    local dir = pkginfo.install_dir()
    local base = path.directory(pkginfo.install_file())
    os.tryrm(dir)

    -- Unix archives contain `dist/`; the Windows portable zip is flat.
    local src = is_host("windows") and base or path.join(base, "dist")
    copy_payload(src, dir)

    if not is_host("windows") then
        chmod_if_file(path.join(dir, "tinynext"))
        chmod_if_file(path.join(dir, "engines", "aria2-next"))
        chmod_if_file(path.join(dir, "engines", "yt-dlp"))
        chmod_if_file(path.join(dir, "engines", "ffmpeg"))
    end

    local exe = path.join(dir, is_host("windows") and "tinynext.exe" or "tinynext")
    return os.isfile(exe)
end

function config()
    xvm.add(package.name, { bindir = pkginfo.install_dir() })
    return true
end

function uninstall()
    xvm.remove(package.name)
    return true
end
