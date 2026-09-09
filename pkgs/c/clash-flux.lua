local function asset(version, filename, sha256)
    return {
        url = string.format(
            "https://github.com/FarnaHerry/Clash-Flux/releases/download/v%s/%s",
            version, filename),
        sha256 = sha256,
    }
end

package = {
    spec = "2",

    name = "clash-flux",
    description = "C++23 desktop proxy client built around the mihomo core and Clash Verge Rev-style workflows",
    homepage = "https://github.com/FarnaHerry/Clash-Flux",
    authors = {"FarnaHerry"},
    maintainers = {"FarnaHerry"},
    licenses = {"MIT"},
    repo = "https://github.com/FarnaHerry/Clash-Flux",
    docs = "https://github.com/FarnaHerry/Clash-Flux#readme",

    type = "package",
    archs = {"x86_64", "aarch64"},
    status = "dev",
    categories = {"app", "network", "proxy", "tools"},
    keywords = {"clash", "mihomo", "proxy", "tun", "desktop"},

    programs = {"clash-flux"},
    xvm_enable = true,

    -- v0.1.3 is the latest non-prerelease GitHub release (2026-09-08).
    -- Linux ships x86_64 and arm64; macOS ships arm64; Windows ships x86_64.
    -- Unsupported platform/architecture combinations stay absent by design.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.3" },
            ["0.1.3"] = {
                x86_64 = asset("0.1.3", "clash-flux-v0.1.3-build-linux-x86_64.tar.gz",
                    "87263deb4ea50ec19a8c5c96b2c348f3b785e91607109b52d35f83663c2760d5"),
                aarch64 = asset("0.1.3", "clash-flux-v0.1.3-build-linux-arm64.tar.gz",
                    "578503bebff0111fbbd11b9518387b3f43b84419a4cf4684eec744eed83f8195"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.3" },
            ["0.1.3"] = {
                aarch64 = asset("0.1.3", "clash-flux-v0.1.3-build-macos-arm64.tar.gz",
                    "908b9b07f5b3c05d040adf9c73839b4ca0132d20587b0f506eb70aad6493c077"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.3" },
            ["0.1.3"] = {
                x86_64 = asset("0.1.3", "clash-flux-v0.1.3-windows-x86_64.zip",
                    "90f69e2cf5190dee8be8d2dd0c9b20e485ce89686d9485f1f8379c610461a4a2"),
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

-- Unix tarballs wrap the staged directory in a platform-specific top-level
-- folder. Locate it by the application artifact instead of assuming the
-- archive stem is also the extracted folder name.
local function unix_payload_root(base)
    for _, dir in ipairs(os.dirs(path.join(base, "*"))) do
        if is_host("macosx") then
            if os.isdir(path.join(dir, "clash-flux.app")) then
                return dir
            end
        elseif os.isfile(path.join(dir, "clash-flux")) then
            return dir
        end
    end
    error("cannot locate the clash-flux release payload under " .. tostring(base))
end

function install()
    local dir = pkginfo.install_dir()
    local base = path.directory(pkginfo.install_file())
    os.tryrm(dir)

    if is_host("windows") then
        copy_payload(base, dir)
    else
        copy_payload(unix_payload_root(base), dir)
    end

    local exe
    if is_host("macosx") then
        exe = path.join(dir, "clash-flux.app", "Contents", "MacOS", "clash-flux")
    else
        exe = path.join(dir, is_host("windows") and "clash-flux.exe" or "clash-flux")
    end
    if not is_host("windows") then
        local mihomo = is_host("macosx")
            and path.join(dir, "clash-flux.app", "Contents", "MacOS", "engines", "mihomo")
            or path.join(dir, "engines", "mihomo")
        system.exec(string.format('chmod +x "%s" "%s"', exe, mihomo))
    end
    return os.isfile(exe)
end

function config()
    local bindir = pkginfo.install_dir()
    if is_host("macosx") then
        bindir = path.join(bindir, "clash-flux.app", "Contents", "MacOS")
    end
    xvm.add(package.name, { bindir = bindir })
    return true
end

function uninstall()
    xvm.remove(package.name)
    return true
end
