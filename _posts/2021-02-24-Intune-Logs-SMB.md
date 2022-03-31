---
title: Upload files with Intune to Azure file share
categories:

    - Intune

tags:

    - Azure
    - Powershell

excerpt: One of the features of Azure Storage account is hosting cloud file share. With Powershell it can be mapped as temporary drive

comments: true
toc: true
toc_label: Table of contents
---

# Intro

Getting logs for troubleshooting deployments and configurations driven by Intune may be difficult when device is off-prem (which nowadays is most of the times). In this post I will show you how to create Azure file share, map it as network drive and make Intune do the copying. ☁

# Azure file share

Creating Azure file share is very simple!
Go to [portal azure](https://portal.azure.com/#create/Microsoft.StorageAccount) and fil lout required boxes

![smb1]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB1.png)

After storage account is deployed navigate to **Overview** and then **File shares**:

![smb2]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB2.png)

Create new file share

![smb3]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB3.png)

Enter desired **name**, **quota** and click **create**

![smb4]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB4.png)

Go to created share and click on **connect**

![smb5]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB5.png)

You will get `Powershell` which performs connection test to the share over 445 port, saves credentials for it and permanently maps drive for you.
In this solution permanent mapping is not necessary so you will need to make some modifications this script.

```powershell
$connectTestResult = Test-NetConnection -ComputerName intunelogssmb.file.core.windows.net -Port 445
$Password = 'AutomaticallyGeneratedAccessKey'
$secret = ConvertTo-SecureString $Password -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ('Azure\intunelogssmb', $secret)
if ($connectTestResult.TcpTestSucceeded) {
    # Mount the drive
    New-PSDrive -Name W -PSProvider FileSystem -Root "\\intunelogssmb.file.core.windows.net\logs" -Credential $psCred
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
```

In my environment I've came upon issue while trying to map disc using method from above.
My issue was that `HKLM:SYSTEM\CurrentControlSet\Control\Lsa\LmCompatibilityLevel` was set to `1`.
After I've changed it to `3` it worked! 😄<br>
For additional troubleshooting visit [docs](https://docs.microsoft.com/en-us/azure/storage/files/storage-troubleshoot-windows-file-connection-problems).

# Copy logs using Intune

To deploy `Powershell` script with Intune you can create **Powershell script** profile or **Win32 App** (which is my personal favorite).
If you want to learn more about deploying `Powershell` scripts using **Win32 App** stop here and checkout my previous post - [Harness Intune Win32 app installer](https://universecitiz3n.tech/intune/Intune-Win32-CustomScript/) - I will wait... ⌚

3

2

1

Back already? Cool so let's continue!
Begin with creating your `Powershell` script.
Feel free to use my [template](https://github.com/UniverseCitiz3n/Intune-App-Sandbox/blob/master/Intune-App-Sandbox/Helpers/Install-ProgramScriptTemplate.ps1).
For example if you want to generate **mdmdiagnostics** and upload them to your file share it would look like:

```powershell
# Parameters
$Tag = 'IntuneLogs'
$OperatingFolder = 'C:\Program Files (x86)\Microsoft\Temp'
$InstallFailCode = 1618
$InstallSuccessCode = 1707

# Log
$LogFile = "$OperatingFolder\IntuneSoftwareInstall.log"
$LogFileError = "$OperatingFolder\IntuneSoftwareInstallError.log"

#Info
. $PSScriptRoot\Write-FileLog.ps1

#Custom exit
function Exit-WithCode {
 param
 (
  $exitcode
 )

 $host.SetShouldExit($exitcode)
}
#######################################################################
#Check for folder
If (Test-Path -Path $OperatingFolder -PathType Container) {
 Write-FileLog -FunctionStart -LogFile $LogFile
} Else {
 New-Item -Path $OperatingFolder -ItemType Directory
 Write-FileLog -Message "$OperatingFolder created" -LogFile $LogFile
}

#Process
Write-FileLog -FunctionStart -LogFile $LogFile
Try {
 Write-FileLog -Message "Mounting network drive" -LogFile $LogFile
 $connectTestResult = Test-NetConnection -ComputerName intunelogssmb.file.core.windows.net -Port 445
 $Password = 'AutomaticallyGeneratedAccessKey'
 $secret = ConvertTo-SecureString $Password -AsPlainText -Force
 $psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ('Azure\intunelogssmb', $secret)
 if ($connectTestResult.TcpTestSucceeded) {
  # Mount the drive
  New-PSDrive -Name W -PSProvider FileSystem -Root "\\intunelogssmb.file.core.windows.net\logs" -Credential $psCred
 } else {
  Write-FileLog -Type Error -Message "Unable to reach the Azure storage account via port 445" -LogFileError $LogFileError
  Exit-WithCode -exitcode $InstallFailCode
 }
 Write-FileLog -Message "Generating mdmdiagnostics" -LogFile $LogFile
 MdmDiagnosticsTool.exe -area 'Autopilot;DeviceEnrollment;DeviceProvisioning;TPM' -zip "$OperatingFolder\mdmdiagnostics.zip"
 Write-FileLog -Message "Uploading logs to file share" -LogFile $LogFile
 Move-Item -Path "$OperatingFolder\mdmdiagnostics.zip" -Destination W:\ -Force
} Catch {
 Write-FileLog -Type Error -Message "Script ERROR" -LogFileError $LogFileError
 $_ | Out-File -FilePath $LogFileError -Append -Encoding ASCII
 Write-FileLog -Type Warn -Message "Script TERMINATION" -LogFileError $LogFileError
 Write-FileLog -Type Warn -Message "Exitcode $InstallFailCode" -LogFileError $LogFileError
 Exit-WithCode -exitcode $InstallFailCode
}
```

To test your script it's the best to use [Intune-App-Sandbox](https://github.com/UniverseCitiz3n/Intune-App-Sandbox) - great tool to test `Powershell` scripts in `Windows Sandbox` in a matter of seconds!

After your package successfully passed the test you can create deployment profile!
Upload `.intunewin` file and enter install command

![smb6]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB6.png)

For detection let's check for our file in networkshare

![smb7]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB7.png)

Complete the rest of configuration and you are ready!
To access uploaded logs just map this file share on your device 😎

![smb8]({{ site.url }}/assets/images/posts/2021-02-24-SMB/SMB8.png)

# Summary

I love it! It's so brilliant in it's simplicity!
I hope that it will help you with gartering required files from endpoints.
See you in next! 😉 🧠
