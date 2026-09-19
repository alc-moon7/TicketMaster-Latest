param(
    [ValidateSet('base', 'android', 'flutter', 'vscode', 'verify')]
    [string]$Phase = 'base'
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Root = 'C:\Dev'
$DownloadsDir = Join-Path $Root 'downloads'
$ToolsDir = Join-Path $Root 'tools'
$SdkDir = Join-Path $Root 'sdk'
$AndroidSdkDir = Join-Path $SdkDir 'android'

$GitDir = Join-Path $ToolsDir 'git'
$JdkDir = Join-Path $ToolsDir 'jdk-17'
$PythonDir = Join-Path $ToolsDir 'python'
$NodeDir = Join-Path $ToolsDir 'node'
$CppDir = Join-Path $ToolsDir 'w64devkit'
$CMakeDir = Join-Path $ToolsDir 'cmake'
$MavenDir = Join-Path $ToolsDir 'maven'
$GradleDir = Join-Path $ToolsDir 'gradle'
$FlutterDir = Join-Path $ToolsDir 'flutter'

function Get-CppHome {
    $nestedDir = Join-Path $CppDir 'w64devkit'
    if (Test-Path -LiteralPath (Join-Path $nestedDir 'bin\gcc.exe')) {
        return $nestedDir
    }
    return $CppDir
}

function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Reset-Dir {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Download-IfMissing {
    param(
        [string]$Url,
        [string]$Destination
    )
    if (Test-Path -LiteralPath $Destination) {
        $existing = Get-Item -LiteralPath $Destination
        if ($existing.Length -eq 0) {
            Remove-Item -LiteralPath $Destination -Force
        }
    }

    if (-not (Test-Path -LiteralPath $Destination)) {
        Write-Host "Downloading $Url"
        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
        if ($curl) {
            & $curl.Source -L --fail --retry 5 --retry-delay 5 --output $Destination $Url
            if ($LASTEXITCODE -ne 0) {
                throw "curl download failed for $Url with exit code $LASTEXITCODE"
            }
        }
        else {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        }
    }
    else {
        Write-Host "Using cached download $Destination"
    }
}

function Expand-ZipTo {
    param(
        [string]$Archive,
        [string]$Destination,
        [switch]$StripSingleRoot
    )

    $tempDir = Join-Path $env:TEMP ("codex-unzip-" + [guid]::NewGuid().ToString())
    Ensure-Dir $tempDir
    $tar = Get-Command tar.exe -ErrorAction SilentlyContinue
    if ($tar) {
        & $tar.Source -xf $Archive -C $tempDir
        if ($LASTEXITCODE -ne 0) {
            throw "tar extraction failed for $Archive with exit code $LASTEXITCODE"
        }
    }
    else {
        Expand-Archive -Path $Archive -DestinationPath $tempDir -Force
    }

    Reset-Dir $Destination
    $sourceDir = $tempDir
    $items = @(Get-ChildItem -LiteralPath $tempDir -Force)
    if ($StripSingleRoot -and $items.Count -eq 1 -and $items[0].PSIsContainer) {
        $sourceDir = $items[0].FullName
    }

    Get-ChildItem -LiteralPath $sourceDir -Force | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $Destination -Force
    }

    Remove-Item -LiteralPath $tempDir -Recurse -Force
}

function Expand-SfxTo {
    param(
        [string]$Archive,
        [string]$Destination
    )

    Reset-Dir $Destination
    $process = Start-Process -FilePath $Archive -ArgumentList @("-y", "-o$Destination") -Wait -PassThru -NoNewWindow
    if ($process.ExitCode -ne 0) {
        throw "Extraction failed for $Archive with exit code $($process.ExitCode)"
    }
}

function Set-UserEnv {
    param(
        [string]$Name,
        [string]$Value
    )

    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
    Set-Item -Path "Env:$Name" -Value $Value
}

function Add-UserPathEntries {
    param([string[]]$Entries)

    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $pathParts = @()
    if ($userPath) {
        $pathParts += $userPath -split ';'
    }

    $preferredEntries = @(
        $Entries | Where-Object { $_ -and (Test-Path -LiteralPath $_) }
    )
    $remainingEntries = @(
        $pathParts | Where-Object { $_ -and ($_ -notin $preferredEntries) -and ($_ -notmatch 'WindowsApps') }
    )
    $windowsAppsEntries = @(
        $pathParts | Where-Object { $_ -and $_ -match 'WindowsApps' }
    )

    $newUserPath = (
        $preferredEntries +
        $remainingEntries +
        $windowsAppsEntries
    ) | Select-Object -Unique

    [Environment]::SetEnvironmentVariable('Path', ($newUserPath -join ';'), 'User')
    $sessionPathParts = @($newUserPath)
    if ($machinePath) {
        $sessionPathParts += $machinePath -split ';'
    }
    $env:Path = (($sessionPathParts | Where-Object { $_ } | Select-Object -Unique) -join ';')
}

function Sync-SessionEnvironment {
    $cppHome = Get-CppHome
    $sessionEntries = @(
        (Join-Path $GitDir 'cmd'),
        (Join-Path $PythonDir 'Scripts'),
        $PythonDir,
        $NodeDir,
        (Join-Path $JdkDir 'bin'),
        (Join-Path $cppHome 'bin'),
        (Join-Path $CMakeDir 'bin'),
        (Join-Path $MavenDir 'bin'),
        (Join-Path $GradleDir 'bin'),
        (Join-Path $AndroidSdkDir 'cmdline-tools\latest\bin'),
        (Join-Path $AndroidSdkDir 'platform-tools'),
        (Join-Path $FlutterDir 'bin')
    ) | Where-Object { Test-Path -LiteralPath $_ }

    $pathParts = @()
    if ($env:Path) {
        $pathParts += $env:Path -split ';'
    }
    $remainingEntries = @(
        $pathParts | Where-Object { $_ -and ($_ -notin $sessionEntries) -and ($_ -notmatch 'WindowsApps') }
    )
    $windowsAppsEntries = @(
        $pathParts | Where-Object { $_ -and $_ -match 'WindowsApps' }
    )
    $env:Path = ((
        $sessionEntries +
        $remainingEntries +
        $windowsAppsEntries
    ) | Select-Object -Unique) -join ';'

    if (Test-Path -LiteralPath $JdkDir) { $env:JAVA_HOME = $JdkDir }
    if (Test-Path -LiteralPath $PythonDir) { $env:PYTHON_HOME = $PythonDir }
    if (Test-Path -LiteralPath $NodeDir) { $env:NODE_HOME = $NodeDir }
    if (Test-Path -LiteralPath $MavenDir) { $env:MAVEN_HOME = $MavenDir }
    if (Test-Path -LiteralPath $GradleDir) { $env:GRADLE_HOME = $GradleDir }
    if (Test-Path -LiteralPath $AndroidSdkDir) {
        $env:ANDROID_HOME = $AndroidSdkDir
        $env:ANDROID_SDK_ROOT = $AndroidSdkDir
    }
    if (Test-Path -LiteralPath $FlutterDir) { $env:FLUTTER_HOME = $FlutterDir }
}

function Get-NodeInfo {
    $release = (Invoke-WebRequest 'https://nodejs.org/dist/index.json' -UseBasicParsing |
        Select-Object -ExpandProperty Content |
        ConvertFrom-Json) |
        Where-Object { $_.version -like 'v20.*' } |
        Select-Object -First 1

    [pscustomobject]@{
        Version = $release.version
        Url     = "https://nodejs.org/dist/$($release.version)/node-$($release.version)-win-x64.zip"
    }
}

function Get-JdkInfo {
    $release = Invoke-RestMethod 'https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&heap_size=normal&image_type=jdk&jvm_impl=hotspot&os=windows&vendor=eclipse'
    $asset = $release[0].binary.package
    [pscustomobject]@{
        FileName = $asset.name
        Url      = $asset.link
    }
}

function Get-PythonInfo {
    $page = Invoke-WebRequest 'https://www.python.org/downloads/windows/' -UseBasicParsing
    $href = $page.Links |
        Where-Object { $_.href -match 'python-3\.12\.[0-9]+-amd64\.exe' } |
        Select-Object -First 1 -ExpandProperty href

    [pscustomobject]@{
        FileName = Split-Path $href -Leaf
        Url      = $href
    }
}

function Get-GitInfo {
    $release = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest'
    $asset = $release.assets |
        Where-Object { $_.name -match '^MinGit-.*-64-bit\.zip$' } |
        Select-Object -First 1

    [pscustomobject]@{
        FileName = $asset.name
        Url      = $asset.browser_download_url
    }
}

function Get-W64DevkitInfo {
    $release = Invoke-RestMethod 'https://api.github.com/repos/skeeto/w64devkit/releases/latest'
    $asset = $release.assets |
        Where-Object { $_.name -match '^w64devkit-x64-.*\.7z\.exe$' } |
        Select-Object -First 1

    [pscustomobject]@{
        FileName = $asset.name
        Url      = $asset.browser_download_url
    }
}

function Get-CMakeInfo {
    $release = Invoke-RestMethod 'https://api.github.com/repos/Kitware/CMake/releases/latest'
    $asset = $release.assets |
        Where-Object { $_.name -match 'windows-x86_64\.zip$' } |
        Select-Object -First 1

    [pscustomobject]@{
        FileName = $asset.name
        Url      = $asset.browser_download_url
    }
}

function Get-MavenInfo {
    [xml]$metadata = Invoke-WebRequest 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/maven-metadata.xml' -UseBasicParsing |
        Select-Object -ExpandProperty Content
    $version = $metadata.metadata.versioning.release
    [pscustomobject]@{
        FileName = "apache-maven-$version-bin.zip"
        Url      = "https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/$version/apache-maven-$version-bin.zip"
    }
}

function Get-GradleInfo {
    $release = Invoke-RestMethod 'https://services.gradle.org/versions/current'
    [pscustomobject]@{
        FileName = Split-Path $release.downloadUrl -Leaf
        Url      = $release.downloadUrl
    }
}

function Get-FlutterInfo {
    $json = Invoke-RestMethod 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json'
    $release = $json.releases |
        Where-Object { $_.channel -eq 'stable' } |
        Sort-Object { [DateTime]$_.release_date } -Descending |
        Select-Object -First 1

    [pscustomobject]@{
        FileName = Split-Path $release.archive -Leaf
        Url      = "https://storage.googleapis.com/flutter_infra_release/releases/$($release.archive)"
    }
}

function Install-BaseTools {
    Write-Step 'Preparing directories'
    Ensure-Dir $Root
    Ensure-Dir $DownloadsDir
    Ensure-Dir $ToolsDir
    Ensure-Dir $SdkDir

    Write-Step 'Installing Git'
    if (-not (Test-Path -LiteralPath (Join-Path $GitDir 'cmd\git.exe'))) {
        $git = Get-GitInfo
        $archive = Join-Path $DownloadsDir $git.FileName
        Download-IfMissing -Url $git.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $GitDir -StripSingleRoot
    }

    Write-Step 'Installing Java 17'
    if (-not (Test-Path -LiteralPath (Join-Path $JdkDir 'bin\javac.exe'))) {
        $jdk = Get-JdkInfo
        $archive = Join-Path $DownloadsDir $jdk.FileName
        Download-IfMissing -Url $jdk.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $JdkDir -StripSingleRoot
    }

    Write-Step 'Installing Python 3.12'
    if (-not (Test-Path -LiteralPath (Join-Path $PythonDir 'python.exe'))) {
        $python = Get-PythonInfo
        $installer = Join-Path $DownloadsDir $python.FileName
        Download-IfMissing -Url $python.Url -Destination $installer
        $process = Start-Process -FilePath $installer -ArgumentList @(
            '/quiet',
            'InstallAllUsers=0',
            'AssociateFiles=0',
            'CompileAll=0',
            'Include_debug=0',
            'Include_dev=1',
            'Include_doc=0',
            'Include_launcher=0',
            'Include_pip=1',
            'Include_symbols=0',
            'Include_test=0',
            'Shortcuts=0',
            "TargetDir=$PythonDir"
        ) -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -ne 0) {
            throw "Python install failed with exit code $($process.ExitCode)"
        }
    }

    Write-Step 'Installing Node.js 20 LTS'
    if (-not (Test-Path -LiteralPath (Join-Path $NodeDir 'node.exe'))) {
        $node = Get-NodeInfo
        $archive = Join-Path $DownloadsDir (Split-Path $node.Url -Leaf)
        Download-IfMissing -Url $node.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $NodeDir -StripSingleRoot
    }

    Write-Step 'Installing C and C++ toolchain'
    if (-not (Test-Path -LiteralPath (Join-Path (Get-CppHome) 'bin\gcc.exe'))) {
        $cpp = Get-W64DevkitInfo
        $archive = Join-Path $DownloadsDir $cpp.FileName
        Download-IfMissing -Url $cpp.Url -Destination $archive
        Expand-SfxTo -Archive $archive -Destination $CppDir
    }
    $cppHome = Get-CppHome

    Write-Step 'Installing CMake'
    if (-not (Test-Path -LiteralPath (Join-Path $CMakeDir 'bin\cmake.exe'))) {
        $cmake = Get-CMakeInfo
        $archive = Join-Path $DownloadsDir $cmake.FileName
        Download-IfMissing -Url $cmake.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $CMakeDir -StripSingleRoot
    }

    Write-Step 'Installing Maven'
    if (-not (Test-Path -LiteralPath (Join-Path $MavenDir 'bin\mvn.cmd'))) {
        $maven = Get-MavenInfo
        $archive = Join-Path $DownloadsDir $maven.FileName
        Download-IfMissing -Url $maven.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $MavenDir -StripSingleRoot
    }

    Write-Step 'Installing Gradle'
    if (-not (Test-Path -LiteralPath (Join-Path $GradleDir 'bin\gradle.bat'))) {
        $gradle = Get-GradleInfo
        $archive = Join-Path $DownloadsDir $gradle.FileName
        Download-IfMissing -Url $gradle.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $GradleDir -StripSingleRoot
    }

    Write-Step 'Configuring environment variables'
    Set-UserEnv -Name 'DEV_HOME' -Value $Root
    Set-UserEnv -Name 'JAVA_HOME' -Value $JdkDir
    Set-UserEnv -Name 'PYTHON_HOME' -Value $PythonDir
    Set-UserEnv -Name 'NODE_HOME' -Value $NodeDir
    Set-UserEnv -Name 'MAVEN_HOME' -Value $MavenDir
    Set-UserEnv -Name 'GRADLE_HOME' -Value $GradleDir
    Set-UserEnv -Name 'CC' -Value (Join-Path $cppHome 'bin\gcc.exe')
    Set-UserEnv -Name 'CXX' -Value (Join-Path $cppHome 'bin\g++.exe')

    Add-UserPathEntries -Entries @(
        (Join-Path $GitDir 'cmd'),
        (Join-Path $PythonDir 'Scripts'),
        $PythonDir,
        $NodeDir,
        (Join-Path $JdkDir 'bin'),
        (Join-Path $cppHome 'bin'),
        (Join-Path $CMakeDir 'bin'),
        (Join-Path $MavenDir 'bin'),
        (Join-Path $GradleDir 'bin')
    )
}

function Install-AndroidTools {
    Write-Step 'Preparing Android SDK folders'
    Ensure-Dir $AndroidSdkDir
    Ensure-Dir (Join-Path $AndroidSdkDir 'cmdline-tools')

    Write-Step 'Installing Android command-line tools'
    $sdkManager = Join-Path $AndroidSdkDir 'cmdline-tools\latest\bin\sdkmanager.bat'
    if (-not (Test-Path -LiteralPath $sdkManager)) {
        $archive = Join-Path $DownloadsDir 'commandlinetools-win-14742923_latest.zip'
        Download-IfMissing -Url 'https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip' -Destination $archive

        $tempDir = Join-Path $env:TEMP ("codex-android-cli-" + [guid]::NewGuid().ToString())
        Ensure-Dir $tempDir
        Expand-Archive -Path $archive -DestinationPath $tempDir -Force

        $latestDir = Join-Path $AndroidSdkDir 'cmdline-tools\latest'
        Reset-Dir $latestDir
        $sourceRoot = Join-Path $tempDir 'cmdline-tools'
        Get-ChildItem -LiteralPath $sourceRoot -Force | ForEach-Object {
            Move-Item -LiteralPath $_.FullName -Destination $latestDir -Force
        }
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }

    Write-Step 'Configuring Android environment variables'
    Set-UserEnv -Name 'ANDROID_HOME' -Value $AndroidSdkDir
    Set-UserEnv -Name 'ANDROID_SDK_ROOT' -Value $AndroidSdkDir
    Add-UserPathEntries -Entries @(
        (Join-Path $AndroidSdkDir 'cmdline-tools\latest\bin'),
        (Join-Path $AndroidSdkDir 'platform-tools')
    )

    $sdkManager = Join-Path $AndroidSdkDir 'cmdline-tools\latest\bin\sdkmanager.bat'
    $env:JAVA_HOME = $JdkDir

    Write-Step 'Accepting Android SDK licenses'
    1..80 | ForEach-Object { 'y' } | & $sdkManager --sdk_root=$AndroidSdkDir --licenses | Out-Host

    Write-Step 'Discovering Android packages'
    $sdkList = & $sdkManager --sdk_root=$AndroidSdkDir --list --channel=0 2>&1 | Out-String
    $platforms = [regex]::Matches($sdkList, '(?m)^\s*(platforms;android-\d+)\s+\|') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object { [int]($_ -replace 'platforms;android-', '') } -Descending |
        Select-Object -Unique -First 2
    $buildTools = [regex]::Matches($sdkList, '(?m)^\s*(build-tools;\d+\.\d+\.\d+)\s+\|') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object { [version]($_ -replace 'build-tools;', '') } -Descending |
        Select-Object -Unique -First 1

    $packages = @('platform-tools')
    if ($buildTools) {
        $packages += $buildTools
    }
    if ($platforms) {
        $packages += $platforms
    }
    if ($sdkList -match '(?m)^\s*extras;google;usb_driver\s+\|') {
        $packages += 'extras;google;usb_driver'
    }

    Write-Step ('Installing Android packages: ' + ($packages -join ', '))
    & $sdkManager --sdk_root=$AndroidSdkDir $packages | Out-Host
    if (Test-Path -LiteralPath (Join-Path $FlutterDir 'bin\flutter.bat')) {
        Write-Step 'Linking Flutter to Android SDK'
        & (Join-Path $FlutterDir 'bin\flutter.bat') config --android-sdk $AndroidSdkDir | Out-Host
    }
}

function Install-Flutter {
    Write-Step 'Installing Flutter'
    if (-not (Test-Path -LiteralPath (Join-Path $FlutterDir 'bin\flutter.bat'))) {
        $flutter = Get-FlutterInfo
        $archive = Join-Path $DownloadsDir $flutter.FileName
        Download-IfMissing -Url $flutter.Url -Destination $archive
        Expand-ZipTo -Archive $archive -Destination $FlutterDir -StripSingleRoot
    }

    Set-UserEnv -Name 'FLUTTER_HOME' -Value $FlutterDir
    Add-UserPathEntries -Entries @((Join-Path $FlutterDir 'bin'))
}

function Install-VsCodeExtensions {
    Write-Step 'Installing VS Code extensions'
    $codeCli = Get-Command code.cmd -ErrorAction SilentlyContinue
    if (-not $codeCli) {
        $codeCli = Get-Command code -ErrorAction Stop
    }

    $extensions = @(
        'ms-vscode.cpptools',
        'ms-python.python',
        'ms-python.vscode-pylance',
        'redhat.java',
        'vscjava.vscode-maven',
        'vscjava.vscode-gradle',
        'dbaeumer.vscode-eslint',
        'esbenp.prettier-vscode',
        'Dart-Code.dart-code',
        'Dart-Code.flutter'
    )

    foreach ($extension in $extensions) {
        & $codeCli.Source --install-extension $extension --force | Out-Host
    }
}

function Verify-Setup {
    Write-Step 'Verifying installed tools'
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    $checks = @(
        @{ Name = 'git'; Command = 'git --version' },
        @{ Name = 'gcc'; Command = 'gcc --version | Select-Object -First 1' },
        @{ Name = 'g++'; Command = 'g++ --version | Select-Object -First 1' },
        @{ Name = 'cmake'; Command = 'cmake --version | Select-Object -First 1' },
        @{ Name = 'java'; Command = 'cmd /c "java -version 2>&1" | Select-Object -First 1' },
        @{ Name = 'javac'; Command = 'cmd /c "javac -version 2>&1"' },
        @{ Name = 'python'; Command = 'python --version' },
        @{ Name = 'pip'; Command = 'pip --version' },
        @{ Name = 'node'; Command = 'node --version' },
        @{ Name = 'npm'; Command = 'npm --version' },
        @{ Name = 'mvn'; Command = 'mvn -version | Select-Object -First 1' },
        @{ Name = 'gradle'; Command = 'cmd /c "gradle -v" | Select-String ''^Gradle '' | Select-Object -First 1' },
        @{ Name = 'adb'; Command = 'adb version | Select-Object -First 1' },
        @{ Name = 'flutter'; Command = 'flutter --version | Select-Object -First 2' }
    )

    foreach ($check in $checks) {
        Write-Host ''
        Write-Host ('[' + $check.Name + ']') -ForegroundColor Yellow
        Invoke-Expression $check.Command | Out-Host
    }

    Write-Step 'Flutter doctor'
    & flutter doctor | Out-Host

    Write-Step 'ADB devices'
    & adb devices | Out-Host

    $ErrorActionPreference = $previousErrorActionPreference
}

Sync-SessionEnvironment

switch ($Phase) {
    'base' { Install-BaseTools }
    'android' { Install-AndroidTools }
    'flutter' { Install-Flutter }
    'vscode' { Install-VsCodeExtensions }
    'verify' { Verify-Setup }
}
