<#
.Synopsis
   This script downloads and install Windows patches updates
.DESCRIPTION
   This script downloads and install Windows patches updates by following steps:
   1. Make sure the system trusts PSGallery. Otherwise attempting to install PSWindowsUpdate will show a prompt saying it is untrusted. For that we first need to install Nuget provider (We can do it using AWSPowerShell.NetCore. This needs to be adjusted for other clouds)
   2. Install module PSWindowsUpdate
   3. Install all windows updates. And make sure we maintain update logs in C:\wulogs directory

.EXAMPLE
   
.INPUTS
   None
.OUTPUTS
   None
.NOTES
  Version:        1.0
  Author:         Monte Albert
  Creation Date:  4/21/2023
  Purpose/Change: Initial script development
#>

# initiating Utilities file to add our Write-Logs
Import-Module $PSScriptRoot\Utils.ps1

#Make sure the system trusts PSGallery. Otherwise attempting to install PSWindowsUpdate will show a prompt saying it is untrusted.
Get-PSRepository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Write-Log "PSGallery repository is trusted"
#install Nuget provider  (We can do it using AWSPowerShell.NetCore. This needs to be adjusted for other clouds)
Write-Log "Installing Nuget Provider.. For AWS, we are using AWSPowerShell.NetCore. Other clouds will have their own."
Install-Module -name AWSPowerShell.NetCore
#Install module PSWindowsUpdate
Write-Log "Installing Module PSWindowsUpdate"
Install-Module PSWindowsUpdate
#Get current timestamp for logs
$tstamp=Get-Date -Format "yyyyMMdd_HH_mm"
#Install all windows updates.
Write-Log "Writting logs in ${FolderName}\${tstamp}-MSUpdates.log"
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot | Out-File "${FolderName}\${tstamp}-MSUpdates.log" -Force
