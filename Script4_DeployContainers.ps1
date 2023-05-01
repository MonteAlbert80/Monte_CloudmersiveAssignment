<#
.Synopsis
   Deploy Containers: Run the container called "Hello-World"
.DESCRIPTION
   Deploy Containers: Run the container called "Hello-World" following steps:
   1. Making sure C:\Containers folder exist
   2. Create file Dockerfile with contents
   3. Create index.html with hello world
   4. Build webserver in docker container

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
    Docker Hello world setup
############################################### 
#>
#File content for container image
$dockerfileContent = @"
FROM mcr.microsoft.com/windows/servercore/iis
RUN powershell
COPY index.html C:/inetpub/wwwroot
"@
#Checking if the folder exist or not. If not, create it
$FolderName="C:\Containers"
if (-Not (Test-Path $FolderName)) {
   New-Item $FolderName -ItemType Directory
}

Set-Content "${FolderName}\Dockerfile" $dockerfileContent

#Html content for Hello World
$htmlFileContent = @"
<h1>Hello World!</h1>
<p>This is an example of a simple HTML page hosted on:</p>
<h2>container #1</h2>
"@

Set-Content "${FolderName}\index.html" $htmlFileContent

Set-Location $FolderName

Start-Sleep(2)

docker build -t webserver .
docker run --name container1 -d -p 80:80 webserver --restart=always
