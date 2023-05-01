<#
.Synopsis
   This is a utility file, to be referenced by other scripts. Currently it contains Write-Log function which archives log file if it exceeds size. The main reason is to retain the logs for debugging, specially after restarts.
.DESCRIPTION
   This is a utility file, to be referenced by other scripts. Currently it contains Write-Log function. We make sure that if log file is beyond 1MB, we archive it and start new.
   1. First make sure we have a folder to have logs for entire assignment.
   2. Make sure we are using TLS 1.2 protocol, just incase the server have some outdated TLS versions installed
   3. Make sure File size is under 1MB. If not, archive and start new one
   4. Write-Log function is invoked in all scripts. It writes to log file and also to the console.

.EXAMPLE
   Import-Module $PSScriptRoot\Utils.ps1
   Write-Log "<Your text/debug statement here>"
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

#First make sure we have a folder to have logs for entire assignment.
$FolderName="C:\wulogs"
if (-Not (Test-Path $FolderName)) {
   New-Item $FolderName -ItemType Directory
}

# Also Make sure we are using TLS 1.2 protocol, just incase the server have some outdated TLS versions installed
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


$LogFile    = 'c:\wulogs\scriptLogs.log'   # this is the current log file
$maxLogSize = 1MB                    # the maximum size in bytes we want
function Write-Log {

    param (
        [string]$text
    )
    #Writing to the console regardless
    Write-Host $text

    #First validate that log file is not too big
    validateFileSize

    #Adding timestamp with log entry
    $tstamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$tstamp $text"
    #Adding content to the log file
    Add-content $LogFile -value $LogMessage
    
}


function validateFileSize {
    # check if the log file exists
    if (Test-Path -Path $LogFile -PathType Leaf) {
        # check if the LogFile is at its maximum size
        if ((Get-Item -Path $LogFile).Length -ge $maxLogSize) {
            $tstamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
            $oldLogs    = "scriptLogs_${tstamp}.log"  # the 'overflow' filename where old log contents is written to
            #Renaming current log file to log file with current timestamp
            Rename-Item -Path $LogFile -NewName $oldLogs
            #note that since we renamed the current file. Next Add-content will create a new file.
        }
    }
}
