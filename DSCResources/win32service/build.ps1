[CmdletBinding()]
param (
    [switch]
    $InstallDsc,

    [switch]
    $Test,

    [switch]
    $SkipBuild
)

if ($InstallDsc) {
    if (-not (Get-Command dsc.exe -Type Application -ErrorAction Ignore)) {
        Write-Verbose -Message "Installing dsc using PowerShell Gallery"
        Install-PSResource -Name PSDSC -Repository PSGallery -TrustRepository

        Install-DscExe
    }
}

$isPs2ExeInstalled = Get-Command Invoke-ps2exe -Type Function -ErrorAction Ignore
if (-not $isPs2ExeInstalled) {
    Write-Verbose -Message "Installing ps2exe using PowerShell Gallery"
    Install-PSResource -Name ps2exe -Repository PSGallery -TrustRepository
}

if (-not $SkipBuild) {
    Write-Verbose -Message "Building the project"
    $projectPath = Join-Path $PSScriptRoot 'src'
    $outputDir = Join-Path $PSScriptRoot 'output'

    if (-not (Test-Path -Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    try {
        Push-Location -Path $projectPath -ErrorAction Stop
        $mainFileContent = Get-Content -Path 'main.ps1' -Raw
        $indexAfterParamBlock = $mainFileContent.IndexOf("`n)") + 3
        foreach ($file in (Get-ChildItem -Path $projectPath -Filter '*.ps1' -Recurse)) {
            # Ensure the file is not the main script
            if ($file.Name -ne 'main.ps1') {
                Write-Verbose -Message "Processing file: $($file.FullName)"
                $content = Get-Content -Path $file.FullName -Raw

                # Insert content after indexAfterParamBlock
                $mainFileContent = $mainFileContent.Insert($indexAfterParamBlock, "`n`n# Dot-sourced script: $($file.Name)`n$content`n")
            }
        }
        # Write the combined content to the main_new.ps1 file
        $mainFilePath = Join-Path $projectPath 'main_new.ps1'
        Set-Content -Path $mainFilePath -Value $mainFileContent -Encoding UTF8 -Force
        # Build the project
        Invoke-Ps2Exe -inputFile $mainFilePath -outputFile $outputDir\win32service.exe -longPaths -Verbose
        Write-Verbose -Message "Build completed successfully. Output file: $outputDir\win32service.exe"
        Remove-Item -Path $mainFilePath -Force -ErrorAction Ignore

        # Copy localization files
        $localizationPath = Join-Path $projectPath 'Localization'
        foreach ($directory in Get-ChildItem -Path $localizationPath -Directory) {
            $lang = $directory.Name
            $destPath = Join-Path $outputDir "$lang"
            if (-not (Test-Path -Path $destPath)) {
                New-Item -Path $destPath -ItemType Directory -Force | Out-Null
            }
            Copy-Item -Path (Join-Path $directory.FullName '*.psd1') -Destination $destPath -Force
        }

        # Copy the resource manifest
        $resourceManifestPath = Join-Path $PSScriptRoot 'win32service.dsc.resource.json'
        if (Test-Path -Path $resourceManifestPath) {
            Copy-Item -Path $resourceManifestPath -Destination $outputDir -Force
        } else {
            Write-Warning -Message "Resource manifest file 'win32service.dsc.resource.json' not found in the root directory."
        }
    } finally {
        Pop-Location -ErrorAction Ignore
    }
}

if ($Test) {
    if (-not (Get-Module -ListAvailable -Name Pester)) {
        Install-PSResource Pester -Repository PSGallery -TrustRepository -ErrorAction Ignore
    }

    Invoke-Pester -ErrorAction Stop -Output Detailed
}