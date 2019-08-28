---
title: Find file duplicates
categories:
    - PowerShell
tags:
    - PowerShell
    - Files
excerpt: When you just cipy files over and over and finally want to do some cleanup...
---

# Copy-Paste

Not all files can be held in GIT. Not everyone uses GIT. And then the chaos creeps in - `I'll just copy this folder to be sure`.  
Or maybe you're trying to clean up your photo collection `Let me copy this here, and I will look through it later`.

Sometimes file name changes - then looking is even harder. I've decided to make a hash (md5 for speed) of every file and compare hashes. If they match - I'll add file full path to a hashtable (again - speed).

Code is quite simple:

```powershell
$dict = @{}
$Path = 'c:\adminTools'
Get-ChildItem -Path $Path -File -Recurse |
    ForEach-Object {
        $hash = ($PSItem | Get-FileHash -Algorithm MD5).Hash
        if ($dict.ContainsKey($hash)) {
            [PSCustomObject]@{
                Original  = $dict[$hash]
                Duplicate = $PSItem.FullName
        }
        }
        else {
            $dict[$hash] = $PSItem.FullName
        }
    }
```

For each file a hash is generated. Then a lookup into hashtable is made with the hash as a `Key`:

- If not found, it's a added to the main (lookup) hashtable as `Key = [Hash] and Value = [File Full Name]`.
- If found - a new object is created with `Original = [Value of Given Hash = File Full Name] and Duplicate = [File Full Name of the other file]`
- then object is passed to pipeline

> In the end I get only duplicate objects

## Usable function

If you'd like to pass a bunch of paths or run it remotely I have you covered:

```powershell
function  Get-FileDuplicate {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Path to check for duplicates',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript( { Test-Path -Path $PSItem -PathType Container })]
        [string[]]
        $Path,

        [Parameter(Mandatory = $false, HelpMessage = 'Remote Computer to connect')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName,

        [Parameter(Mandatory = $false, HelpMessage = 'Provide Credential',
            ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.Credential()][System.Management.Automation.PSCredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    begin {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            $connectionProps = @{
                ComputerName = $ComputerName
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $connectionProps.Credential = $Credential
            }
            $remoteConnection = $true
        }
        $dict = @{}
    }
    process {
        if ($remoteConnection) {
            Invoke-Command -ComputerName @connectionProps -ScriptBlock {
                $duplicates = Get-ChildItem -Path $USING:Path -File -Recurse |
                ForEach-Object {
                    $hash = ($PSItem | Get-FileHash -Algorithm MD5).Hash
                    if ($dict.ContainsKey($hash)) {
                        [PSCustomObject]@{
                            Original  = $dict[$hash]
                            Duplicate = $PSItem.FullName
                        }
                    }
                    else {
                        $dict[$hash] = $PSItem.FullName
                    }
                }
                $duplicates
            }
        }
        else {
            $duplicates = Get-ChildItem -Path $Path -File -Recurse |
                ForEach-Object {
                    $hash = ($PSItem | Get-FileHash -Algorithm MD5).Hash
                    if ($dict.ContainsKey($hash)) {
                        [PSCustomObject]@{
                            Original  = $dict[$hash]
                            Duplicate = $PSItem.FullName
                        }
                    }
                    else {
                        $dict[$hash] = $PSItem.FullName
                    }
                }
                $duplicates
        }
    }
}
```

which looks like this:

```
Original                                    Duplicate
--------                                    ---------
C:\AdminTools\1_Member_Forest.jpg           C:\AdminTools\Issues\1_Member_Forest.jpg
C:\AdminTools\2_Member_Forest.jpg           C:\AdminTools\Issues\2_Member_Forest.jpg
C:\AdminTools\3_MemberOf_Forest.jpg         C:\AdminTools\Issues\3_MemberOf_Forest.jpg
C:\AdminTools\4_MemberOf_Forest.jpg         C:\AdminTools\Issues\4_MemberOf_Forest.jpg
```


