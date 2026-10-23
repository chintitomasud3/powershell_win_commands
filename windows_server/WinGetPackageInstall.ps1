# ১. ডাউনলোড ডিরেক্টরি তৈরি
$workDir = "$env:TEMP\winget-install"
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
Set-Location -Path $workDir

# TLS 1.2 নিশ্চিত করা
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ২. প্রয়োজনীয় ডিপেনডেন্সি (VCLibs & UI.Xaml) ডাউনলোড
Write-Host "Downloading dependencies..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "VCLibs.appx"
Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" -OutFile "UI.Xaml.appx"

# ৩. GitHub থেকে সর্বশেষ Winget (App Installer) ও লাইসেন্স ফাইল ডাউনলোড
Write-Host "Downloading Winget packages..." -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$msixBundleUrl = ($release.assets | Where-Object { $_.name -like "*.msixbundle" }).browser_download_url
$licenseUrl = ($release.assets | Where-Object { $_.name -like "*License1.xml" }).browser_download_url

Invoke-WebRequest -Uri $msixBundleUrl -OutFile "AppInstaller.msixbundle"
Invoke-WebRequest -Uri $licenseUrl -OutFile "License.xml"

# ৪. প্যাকেজগুলো ইনস্টল করা
Write-Host "Installing packages..." -ForegroundColor Yellow
Add-AppxPackage -Path "VCLibs.appx"
Add-AppxPackage -Path "UI.Xaml.appx"
Add-AppxProvisionedPackage -Online -PackagePath "AppInstaller.msixbundle" -LicensePath "License.xml"

# ৫. পাথ এনভায়রনমেন্ট ভ্যারিয়েবলে যোগ করা
$wingetPath = Resolve-Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe" | Select-Object -ExpandProperty Path -Last 1
if ($wingetPath) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$wingetPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$wingetPath", "Machine")
        $env:Path += ";$wingetPath"
    }
}

Write-Host "Installation completed!" -ForegroundColor Green
