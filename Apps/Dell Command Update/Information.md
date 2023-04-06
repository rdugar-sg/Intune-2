## App type
App type: Windows app (Win32)
App: Use IntuneWin to generate a .intunewin file from entire source folder.
Source folder content:
- install.cmd and install.ps1
- uninstall.cmd and unistall.ps1
- DCU_Setup_4_8_0.exe (https://dl.dell.com/FOLDER09622916M/1/Dell-Command-Update-Application_714J9_WIN_4.8.0_A00.EXE)

## App information
Name: Dell Command Update  
Description: Dell Command Update provides a 2-click solution for getting all the latest drivers, firmware, and BIOS updates for your commercial client systems. It can also be scheduled to run automatically.  
Publisher: Dell Inc  
Version: 4.8.0  
Category: Computer Management  
Featured App: No  
Information URL: *No Value*  
Privacy URL: *No Value*  
Developer: *No Value*  
Owner: *No Value*  
Notes: *No Value*  
Logo: Logo.png  

## Program
Install Command: install.cmd  
Uninstall Command: uninstall.cmd  
Install Behavior: System  
Device restart behaviour: App install may force a device restart  

## Requirements
Operating system architecture: x64  
Minimum operating system: Windows 10 1909  
Disk space required (MB): *No Value*  
Physical memory required (MB): *No Value*  
Minimum number of logical processors required: *No Value*  
Minimum CPU speed required (MHz): *No Value*  
Configure additional requirement rules: *No Value*  

## Detection
Rules Format: Use a custom detection script  
File: DetectionScript.ps1  
Run script as 32-bit process on 64-bit clients: No  
Enforce script signature check and run script silently: No  
