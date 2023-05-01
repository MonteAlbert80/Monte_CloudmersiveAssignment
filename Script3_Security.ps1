<#
.Synopsis
   Scan all the files on the server for viruses using Windows Defender and scan the server for all executable files (.exe and .dll) that do not have valid Authenticodecertificates
.DESCRIPTION
   Scan all the files on the server for viruses using Windows Defender and scan the server for all executable files (.exe and .dll) that do not have valid Authenticodecertificates following steps:
   1. Make sure we are using TLS 1.2 protocol, just incase the server have some outdated TLS versions installed
   2. Scan system using Windows Defender. NOTE!!! This might take very long time because we are running full system scan
   3. Download and install Windows SDK
   4. Iterate through all local drives, and iterate through all .exe and .dll files and run Get-AuthenticodeSignature. NOTE!!! It will just display the status whether signature is valid or not.
      There is no action for non valid certificates. If there is need, change the code to if ((Get-AuthenticodeSignature $_).Status -ne 'Valid')

.EXAMPLE
   
.INPUTS
   None
.OUTPUTS
   None
.NOTES
  Version:        1.0
  Author:         Monte Albert
  Creation Date:  4/22/2023
  Purpose/Change: Initial script development
#>

# initiating Utilities file to add our Write-Logs
Import-Module $PSScriptRoot\Utils.ps1

<#
############################################### 
    Scanning system using Windows Defender
############################################### 
#>
Start-MpScan -ScanType FullScan


<#
############################################### 
    Scanning .exe and .dll for
    authenticode certificates
############################################### 
#>

#First we need to install Windows SDK to run Get-AuthenticodeSignature command
Write-Log "Downloading Windows SDK..."
$exePath = "$env:temp\wdksetup.exe"
try {
    (New-Object Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/?linkid=2083338', $exePath)
} catch {
    Write-Log "Error downloading windows SDK.."
    Write-Log $_
    Exit 1
}

Write-Log "Installing Windows SDK..."
try {
    cmd /c start /wait $exePath /features + /quiet
    Write-Host "Windows SDK Installed"
} catch {
    Write-Log "Error installing windows SDK.."
    Write-Log $_
    Remove-Item $exePath
    Exit 1
}

#Now get a list of drives in the system.
$drives = Get-PSDrive -PSProvider FileSystem

foreach ($drive in $drives) {
    #In each drive, list for files *.exe and *.dll
    Get-ChildItem -Path $Drive.Root -Include *.EXE,*.DLL -Recurse -File -ErrorAction SilentlyContinue -Force |
    ForEach-Object {
        Write-Log "Scanning file $_"
        Write-Log (Get-AuthenticodeSignature $_).Status
        # For now we just print the value of whether authenticode signature is valid or not. We do not have action item to do for files with invalid signatures.
        # If there is a need, uncomment following code, and comment the above Write-Log statements
        #if ((Get-AuthenticodeSignature $_).Status -ne 'Valid') {
            #TODO: Add code here for action items.
        #}

    }

}

