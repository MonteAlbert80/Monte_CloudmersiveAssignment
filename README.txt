****************************************
Cloudmersive Coding exercise project
@Author: Monte Albert
****************************************

Summary:
This project contains powershell files for each item in the project requirement:
    - Script 1: Patching: Install all the latest Windows Updates, if any, and restart the server if needed
    - Script 2: Setup: Install Microsoft IIS, Google Chrome, and Docker Enterprise automatically, restarting
    the server if needed
    - Script 3: Security: Scan all the files on the server for viruses using Windows Defender, and scan the
    server for all executable files (.exe and .dll) that do not have valid Authenticode certificates
    - Script 4: Deploy Containers: Run the container called “hello-world” (Windows Server 2022 version);
    container should run in the background, on port 80, and auto-restart. If server is rebooted, then the
    container should automatically start when the computer is rebooted.
    - Script 5: Manage Containers: Stop all running containers

All the .ps1 files are named with Script numbers and the title. We have additional file Utils.ps1 that is imported in every single file. The current implementation of it is it uses logs.

PreRequisites:
This project works based on the following assumptions.
* You have already commissioned an AWS EC2 instance with Windows 2022. (Note that if needed, I can open up my instance to be accessible by your IP and provide you RDP file if you needed to test)
* If this needs to be run on any other cloud Windows 2022, a line in Script1 needs to be modified regarding AWSPowerShell.NetCore
* Scripts needs to be run in proper sequence. Except Script3 can run independently as it only scans items.

How-To:
* You need to actually RDP into the Windows Server 2022 machine maping your local drive to copy the contents on the folder.
* Start powershell (as administrator/elevated might be needed for some tasks specially docker installation)
* Run the scripts like:
    C:\<your path here>\Script1_Patching.ps1
    C:\<your path here>\Script2_Setup.ps1
    C:\<your path here>\Script3_Security.ps1
    C:\<your path here>\Script4_DeployContainers.ps1
    C:\<your path here>\Script5_ManageContainers.ps1
* Do not run Utils.ps1. It is included by all the above scripts.


Troubleshooting/Checking sequence of events
* open c:\wulogs\scriptLogs.log in a notepad

Misc comments/Future refinements:
* Script3_Security takes a very long time in scanning using windows defender.
* Script3_Security go through each .exe and .dll file and prints whether the file
* Script2_Setup installs IIS and Google Chrome perfectly, but might need more refinements since there was a problem running docker for Script4_DeployContainers. It keeps crashing on my EC2 instance. Hence I was not able to fully test Script4_DeployContainers and Script5_ManageContainers
* I am submitting the assignment as is for now since it's already 24 hours. I will research more on docker installation on EC2 instances later, since intallation itself is super time consuming task for docker.