$RepoRoot = Split-Path -Parent $PSScriptRoot
$BinPath = Join-Path $RepoRoot "bin"

if (!(Test-Path $BinPath)) {
    mkdir $BinPath | Out-Null
}

$VsWherePath = Join-Path $BinPath "vswhere.exe"
$VsWhereJson = Join-Path $RepoRoot "vswhere.json"

# Download vswhere if needed
$VsWhereHash = ""
if (Test-Path $VsWherePath) {
    $VsWhereHash = (Get-FileHash $VsWherePath -Algorithm SHA256).Hash
}

$VsWhereInfo = Get-Content $VsWhereJson | ConvertFrom-Json
if ($VsWhereInfo.Hash -ne $VsWhereHash) {
    Write-Host "Downloading vswhere.exe..."
    Invoke-WebRequest -Uri $VsWhereInfo.Url -OutFile $VsWherePath
}