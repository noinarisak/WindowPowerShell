function Out-TextReport {

<#
.SYNOPSIS
   Saves results as text to a text file
.DESCRIPTION
   Saves results to text file and automatically adjusts the file width so no columns and no data is truncated.
   Truncation only occurs for object properties that contain multi-line text.
.PARAMETER Path
   Optional. Name of text file to create. Existing files will be overwritten. By default, a temporary file in the temp folder is created.
.PARAMETER Open
   Opens the text file after creation in the application that is associated with .txt-files.
.EXAMPLE
Get-Process | Where-Object { $_.MainWIndowTitle} | Select-Object Name, Description, Company, MainWindowTitle , CPU | Out-TextReport -Open
   Lists various pieces of information about running processes and writes them to a text file. The file width is automatically adjusted to provide enough room to display all information. The text file then is opened by its default application.
.EXAMPLE
   Get-ACL $env:windir | Out-TextReport -open
   Reads the windows folder NTFS permissions and writes the results to a text file. The text file then is opened by its default application.
   
#>
 param(
  $Path = "$env:temp\report.txt",
  [switch]$Open
 )
$Input | 
  Format-Table -AutoSize |
  Out-File $Path -Width 10000
 
  if($open) { Invoke-Item $Path }

}
