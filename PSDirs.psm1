function Get-DirectoryListLocation {
    return '~/.config/powershell/current-directory-list.json'
}

function Read-DirectoryList {
    $location = Get-DirectoryListLocation
    return Get-Content -Path $location | ConvertFrom-Json -AsHashtable
}

<#
.SYNOPSIS
    Shows the current list of directories available to navigate to.
.DESCRIPTION
    Reads up the directory list stored in the current-directory-list.json file.
    This file maintains the list of directories available for navigation in the shell.
.EXAMPLE
    PS C:\GitHub\posh-git\tests> Show-DirectoryList
    Returns a hash of directory paths keyed by an integer
.INPUTS
    None.
.OUTPUTS
    HashTable
#>
function Show-DirectoryList {
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary
    $dirHash = Read-DirectoryList

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
.EXAMPLE
    PS C:\GitHub\posh-git\tests> Add-DirectoryToList /foo/bar/baz
.INPUTS
    Direcory path to add to list.
.OUTPUTS
    None.
#>
function Add-DirectoryToList {
    Param([Parameter(Mandatory=$true)] [string]$path)
    $dirsHash = Read-DirectoryList
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary

    [int]$index = 1
    foreach ($item in $dirsHash.GetEnumerator() | Sort-Object Key) {
        $orderedDictionary.Add($item.key, $item.Value)
        $index ++
    }

    $orderedDictionary.Add([string]$index, $path)
    $location = Get-DirectoryListLocation
    Write-Output $orderedDictionary | ConvertTo-Json | Out-File -FilePath $location 

    Set-Location $path
}

<#
.SYNOPSIS
    Removes a directory from the available directory list.
.DESCRIPTION
    Removes a directory path from the list of available directories for navigation.
    The directory key to pass in is shown from a prior call to Show-DirectoryList.
    Can't remove the user's home directory.
.EXAMPLE
    PS C:\GitHub\posh-git\tests> Remove-DirectoryFromList 3
.INPUTS
    Direcory path key
.OUTPUTS
    None.
#>
function Remove-DirectoryFromList {
    Param([Parameter(Mandatory=$true)] [string]$name)

    $dirsHash = Read-DirectoryList
    $orderedDictionary = New-Object System.Collections.Specialized.OrderedDictionary

    $dirsHash.Remove($name)

    [int]$index = 1
    foreach ($item in $dirsHash.GetEnumerator() | Sort-Object Key) {
        $orderedDictionary.Add([string]$index, $item.Value)
        $index ++
    }
    
    $location = Get-DirectoryListLocation
    Write-Output $orderedDictionary | ConvertTo-Json | Out-File -FilePath $location 
}

<#
.SYNOPSIS
    Enter a directory in the available directory list.
.DESCRIPTION
    Enter a directory path from the list of available directories for navigation.
    The directory key to pass in is shown from a prior call to Show-DirectoryList
.EXAMPLE
    PS C:\GitHub\posh-git\tests> Enter-DirectoryInList 3
.INPUTS
    Direcory path key
.OUTPUTS
    None.
#>
function Enter-DirectoryInList {
    Param([Parameter(Mandatory=$true)] [string]$name)
    $dirsHash = Read-DirectoryList
    
    Set-Location $dirsHash.Item([string]$name)
}
