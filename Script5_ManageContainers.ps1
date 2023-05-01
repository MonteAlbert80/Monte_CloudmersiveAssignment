<#
.Synopsis
   Manage Containers: Stop all running containers
.DESCRIPTION
   Manage Containers: Stop all running containers by following steps:
   1. docker kill $(docker ps -q)

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
    Stopping all the docker containers
############################################### 
#>


docker kill $(docker ps -q)