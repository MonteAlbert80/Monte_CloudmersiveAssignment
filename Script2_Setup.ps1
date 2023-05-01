<#
.Synopsis
   Install Microsoft IIS, Google Chrome, and Docker Enterprise automatically, restarting the server if needed
.DESCRIPTION
   Install Microsoft IIS, Google Chrome, and Docker Enterprise automatically, restarting the server if needed by following steps:
   1. install IIS with admin tools
   2. install Google Chrome by downloading it's msi from dl.google.com. And cleaning up install file after that
   3. install docker by downloading it from https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe (Note that I tried finding the .MSI, but apparently they removed it. I was having trouble with correct installation and it keeps crashing)
   4. Restart the server if required by any of the three tasks. Note that if they are already installed, no restart would be needed.

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


$iisRestartNeeded = "No"
$chromeRestartNeeded = "No"
$dockerRestartNeeded = "No"

<#
############################################### 
      install IIS with admin tools
############################################### 
#>
Write-Log "installing IIS"
$windowsfeaturereturn = Install-WindowsFeature Web-Server -IncludeManagementTools
$iisRestartNeeded = $windowsfeaturereturn.RestartNeeded
Write-Log "IIS install completed. Restart Needed: $iisRestartNeeded"

<#
############################################### 
      installing Google chrome
############################################### 
#>
# Set the system architecture as a value.
$OSArchitecture = (Get-WmiObject Win32_OperatingSystem).OSArchitecture
$TempDirectory = "$ENV:Temp\Chrome"

if ($OSArchitecture -eq "64-Bit" -and $Installx64 -eq $True){
   $Link = 'http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi'
} ELSE {
   $Link = 'http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi'
}
try {
   New-Item -ItemType Directory "$TempDirectory" -Force | Out-Null
   (New-Object System.Net.WebClient).DownloadFile($Link, "$TempDirectory\Chrome.msi")
   Write-Log 'Chrome installer download success!'
   # Install Chrome
   $ChromeMSI = """$TempDirectory\Chrome.msi"""
   $processreturn = (Start-Process -filepath msiexec -argumentlist "/i $ChromeMSI /qn /norestart" -Wait -PassThru)
   $chromeRestartNeeded = $processreturn.RestartNeeded
   $ExitCode = $processreturn.ExitCode
   
   if ($ExitCode -eq 0) {
      Write-Log "success! Google Chrome Installed! Restart Needed: $chromeRestartNeeded" 
   } else {
      Write-Log "failed. There was a problem installing Google Chrome. MsiExec returned exit code $ExitCode."
   }
} catch {
   Write-Log 'failed. There was a problem with Chrome download.'
}

Write-Log 'Removing Chrome installer... ' -NoNewline
try {
     # Remove the installer
     Remove-Item "$TempDirectory\Chrome.msi" -ErrorAction Stop
     Write-Log 'success!' -ForegroundColor Green
 } catch {
     Write-Log "failed. You will have to remove the installer yourself from $TempDirectory\."
 }

<#
############################################### 
      installing Docker
############################################### 
#>
Write-Log "Checking if Docker service is currently installed"
$service = Get-Service "Docker Desktop Service" -ErrorAction SilentlyContinue
if ($service.Length -gt 0) {
   Write-Log "Docker desktop service already installed. Hence skipping this"
} else {
   $TempDirectory = "$ENV:Temp\Docker"
   $dockerexe = "${TempDirectory}\InstallDocker.exe"
   Write-Host "Will download into ${dockerexe}"
   try {
       
      New-Item -ItemType Directory "$TempDirectory" -Force | Out-Null
      Invoke-WebRequest "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerexe
      Write-Log 'Docker installer download success!'
      $processreturn = (Start-Process $dockerexe  -Wait install --quiet)
      $dockerRestartNeeded = $processreturn.RestartNeeded
      $ExitCode = $processreturn.ExitCode
      # Add Docker to the path for the current session.
      $env:path += ";$env:ProgramFiles\docker"

      # Optionally, modify PATH to persist across sessions.
      $newPath = "$env:ProgramFiles\docker;" +
      [Environment]::GetEnvironmentVariable("PATH",
      [EnvironmentVariableTarget]::Machine)

      [Environment]::SetEnvironmentVariable("PATH", $newPath,
      [EnvironmentVariableTarget]::Machine)

      # Register the Docker daemon as a service.
      Write-Log "Registering Docker Daemon as a service"
      dockerd --register-service

      # Making sure the service is set to auto start
      Set-Service docker  -StartupType Automatic

      # Start the Docker service.
      Write-Log "Starting Docker Service"
      Start-Service docker
   
      if ($ExitCode -eq 0) {
         Write-Log "success! Docker Installed! Restart Needed: $dockerRestartNeeded" 
      } else {
         Write-Log "failed. There was a problem installing Docker. Exit code $ExitCode."
      }
   } catch {
      Write-Log 'failed. There was a problem with Docker download.'
   }

}
<#
############################################### 
      Restarting the system if needed
############################################### 
#>
Write-Log "Checking if system reboot is needed"
if (($iisRestartNeeded -eq "Yes") -or ($chromeRestartNeeded -eq "Yes") -or ($dockerRestartNeeded -eq "Yes")) {
   Write-Log "Restart needed by either iis, Chrome or Docker. Hence restarting"
   Restart-Computer
} else {
   Write-Log "No reboot needed"
}
