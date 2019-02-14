<#
.SYNOPSIS
    Shows the current list of directories available for navigation.
.DESCRIPTION
    Reads up the directory list stored in the $env:DIRS_PATH file. The contents of
    this file should be a json representation of a hashtable where the keys are integers
    and the values are directory paths. This file maintains the list of directories
    available for navigation in the shell.
.EXAMPLE
    PS C:\User\yoshi\tests> Show-DirectoryList
    Returns an OrderedDictionary  of directory paths keyed by an integer
.INPUTS
    None.
.OUTPUTS
    System.Collections.Specialized.OrderedDictionary
#>
function Show-DirectoryList {
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary
    $dirHash = Get-Content -Path $env:DIRS_PATH | ConvertFrom-Json -AsHashtable

    foreach($item in $dirHash.getEnumerator() | Sort-Object Key) {
        $orderedDictionary.Add($item.key, $item.Value)
    }

    $orderedDictionary | Write-Output 
}

<#
.SYNOPSIS
    Adds a directory to the available directory list.
.DESCRIPTION
    Adds a provided directory path to the list of available directories for navigation.
    A side effect of this function is to update the json represetation of the hash of
    direcories in the $env:DIRS_PATH
.EXAMPLE
    PS C:\User\yoshi\tests> Add-DirectoryToList /foo/bar/baz
.INPUTS
    Direcory path to add to list.
.OUTPUTS
    None.
#>
function Add-DirectoryToList {
    Param([Parameter(Mandatory=$true)] [string]$path)

    $dirHash = Get-Content -Path $env:DIRS_PATH | ConvertFrom-Json -AsHashtable
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary

    [int]$index = 1
    foreach ($item in $dirsHash.GetEnumerator() | Sort-Object Key) {
        $orderedDictionary.Add($item.key, $item.Value)
        $index ++
    }

    $orderedDictionary.Add([string]$index, $path)
    Write-Output $orderedDictionary | ConvertTo-Json | Out-File -FilePath $env:DIRS_PATH 

    Set-Location $path
}

<#
.SYNOPSIS
    Removes a directory from the available directory list.
.DESCRIPTION
    Removes a directory path from the list of available directories for navigation.
    The directory key to pass as a parameter is shown from a prior call to Show-DirectoryList.
    A side effect of this function is to update the json represetation of the hash of
    direcories in the $env:DIRS_PATH
.EXAMPLE
    PS C:\User\yoshi\tests> Remove-DirectoryFromList 3
.INPUTS
    Direcory path key
.OUTPUTS
    None.
#>
function Remove-DirectoryFromList {
    Param([Parameter(Mandatory=$true)] [string]$name)

    $dirHash = Get-Content -Path $env:DIRS_PATH | ConvertFrom-Json -AsHashtable
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary

    $dirsHash.Remove($name)

    [int]$index = 1
    foreach ($item in $dirsHash.GetEnumerator() | Sort-Object Key) {
        $orderedDictionary.Add([string]$index, $item.Value)
        $index ++
    }
    
    Write-Output $orderedDictionary | ConvertTo-Json | Out-File -FilePath $env:DIRS_PATH 
}

<#
.SYNOPSIS
    Enter a directory in the available directory list.
.DESCRIPTION
    Enter a directory path from the list of available directories for navigation.
    The directory key to pass in is shown from a prior call to Show-DirectoryList
.EXAMPLE
    PS C:\User\yoshi\tests> Enter-DirectoryInList 3
.INPUTS
    Direcory path key
.OUTPUTS
    None.
#>
function Enter-DirectoryInList {
    Param([Parameter(Mandatory=$true)] [string]$name)

    $dirHash = Get-Content -Path $env:DIRS_PATH | ConvertFrom-Json -AsHashtable
    
    Set-Location $dirsHash.Item([string]$name)
}
