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
    -- Linux and macOS publish portable archives. Windows publishes a WiX Burn
    -- bundle whose HuxerUI bootstrapper is interactive, so the install hook
    -- below extracts its embedded MSI and runs that MSI silently.
    xpm = {
        linux = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                x86_64 = asset("0.1.1", "apitab-v0.1.1-linux-x86_64.tar.gz",
                    "af73459e6b404d209852d5ea126bcb074f8182a1e697f5bc374dbf4365bc6d0c"),
            },
        },
        macosx = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                aarch64 = asset("0.1.1", "apitab-v0.1.1-macos-arm64.tar.gz",
                    "41c1aee1cc32207fda2ab2274a4a834cf78705f5e93b8072ddbd644f2d9697fd"),
            },
        },
        windows = {
            ["latest"] = { ref = "0.1.1" },
            ["0.1.1"] = {
                x86_64 = asset("0.1.1", "apitab-v0.1.1-windows-x86_64-setup.exe",
                    "3982acdcee90b7b9af378c5386d4f0b8bb121cf40b1d7511d79b368b7d770c5c"),
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
        -- The release setup is a WiX Burn bundle with an interactive HuxerUI
        -- bootstrapper. Its embedded MSI is the package payload we need here;
        -- extract the second CAB in the bundle and invoke msiexec directly so
        -- xlings can install without a desktop prompt.
        os.mkdir(dir)
        local exe = winpath(path.join(dir, "apitab.exe"))
        os.exec(string.format([[
 Powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $setup='%s'; $dir='%s'; $stage=Join-Path ([IO.Path]::GetTempPath()) ('apitab-'+[guid]::NewGuid().ToString('N')); $inner=Join-Path $stage 'apitab-msi.cab'; $extract=Join-Path $stage 'payload'; New-Item -ItemType Directory -Path $extract -Force | Out-Null; try { $bytes=[IO.File]::ReadAllBytes($setup); $hits=0; $offset=-1; for ($pos=0; $pos -lt $bytes.Length-3; ) { $pos=[Array]::IndexOf($bytes,[byte]0x4d,$pos); if ($pos -lt 0) { break }; if ($bytes[$pos+1] -eq 0x53 -and $bytes[$pos+2] -eq 0x43 -and $bytes[$pos+3] -eq 0x46) { $hits++; if ($hits -eq 2) { $offset=$pos; break } }; $pos++ }; if ($offset -lt 0) { throw 'apitab setup does not contain its embedded MSI container' }; $source=[IO.File]::OpenRead($setup); try { $source.Seek($offset,[IO.SeekOrigin]::Begin) | Out-Null; $target=[IO.File]::Create($inner); try { $source.CopyTo($target) } finally { $target.Dispose() } } finally { $source.Dispose() }; $expand=Join-Path $env:SystemRoot 'System32\expand.exe'; & $expand '-F:*' $inner $extract; if ($LASTEXITCODE -ne 0) { throw ('failed to extract apitab MSI (exit code {0})' -f $LASTEXITCODE) }; $msi=Join-Path $extract 'a0'; if (-not (Test-Path -LiteralPath $msi)) { throw 'apitab setup did not yield an MSI payload' }; $msiexec=Join-Path $env:SystemRoot 'System32\msiexec.exe'; $p=Start-Process -FilePath $msiexec -ArgumentList @('/i',$msi,'/qn','/norestart',('INSTALLFOLDER={0}' -f $dir),'CREATE_DESKTOP_SHORTCUT=0') -PassThru -Wait; if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { throw ('apitab MSI install failed (exit code {0})' -f $p.ExitCode) }; $deadline=(Get-Date).AddSeconds(30); while (-not (Test-Path -LiteralPath '%s')) { if ((Get-Date) -ge $deadline) { throw 'apitab MSI did not produce apitab.exe' }; Start-Sleep -Milliseconds 250 } } finally { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }" ]],
            winpath(pkginfo.install_file()), winpath(dir), exe))
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
        -- The MSI is installed directly because the release bundle's custom
        -- bootstrapper has no unattended install path. Remove that MSI by its
        -- registered product code before xlings removes the payload directory.
        os.exec(string.format([[
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $roots=@('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'); $entry=Get-ItemProperty -Path $roots -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq 'apitab' -and $_.DisplayVersion -eq '%s' } | Select-Object -First 1; if ($entry -and $entry.PSChildName -match '^\{[0-9A-Fa-f-]+\}$') { $msiexec=Join-Path $env:SystemRoot 'System32\msiexec.exe'; $p=Start-Process -FilePath $msiexec -ArgumentList @('/x',$entry.PSChildName,'/qn','/norestart') -PassThru -Wait; if ($p.ExitCode -ne 0 -and $p.ExitCode -ne 3010) { throw ('apitab MSI uninstall failed (exit code {0})' -f $p.ExitCode) } }" ]],
            pkginfo.version()))
    end
    return true
end
