$BinPath = Join-Path $PSScriptRoot "bin"
$VsWherePath = Join-Path $BinPath "vswhere.exe"

if (!(Test-Path $VsWherePath)) {
    throw "Installation corrupted! Could not find vswhere.exe!"
}

Write-Debug "VSWherePath: $VsWherePath"
Export-ModuleMember -Variable "VsWherePath"

<#
.SYNOPSIS
    Lists installed Visual Studio instances

.PARAMETER IncludePrerelease
    Include pre-release versions in the list

.PARAMETER MajorVersion
    Filter to only instances of the specified Major Version
#>
function Get-VisualStudio() {
    param(
        [Parameter(Mandatory=$false)][Alias("v")][int]$MajorVersion = -1,
        [Parameter(Mandatory=$false)][Alias("pre")][switch]$IncludePrerelease)

    # Build args for the vswhere invocation
    $vswhereargs = @("-all", "-format", "json", "-utf8")
    if($IncludePrerelease) {
        $vswhereargs += @("-prerelease")
    }

    $Vses = (& "$VsWherePath" @vswhereargs | ConvertFrom-Json) | ForEach-Object {
        $obj = New-Object PSCustomObject -Property @{
            "Id" = $_.instanceId;
            "InstallDate" = [DateTime]::Parse($_.installDate);
            "Name" = $_.installationName;
            "Path" = $_.installationPath;
            "Version" = [Version]::Parse($_.installationVersion);
            "ProductId" = $_.productId;
            "ProductPath" = $_.productPath;
            "Prerelease" = $_.isPrerelease;
            "DisplayName" = $_.displayName;
            "Channel" = $_.channelId;
            "ChannelUrl" = $_.channelUrl;
            "EnginePath" = $_.enginePath;
            "InstallChannelUrl" = $_.installChannelUrl;
            "ReleaseNotes" = $_.releaseNotes;
            "ThirdPartyNotices" = $_.thirdPartyNotices;
            "UpdateDate" = [DateTime]::Parse($_.updateDate);
            "RawJson" = $_;
        }
        $obj.PSObject.TypeNames.Insert(0, "PsVs.VsInstallation")
        $obj
    } | Where-Object {
        ($MajorVersion -eq -1) -or ($_.Version.Major -eq $MajorVersion)
    }

    $Vses | Sort-Object -Descending Version
}