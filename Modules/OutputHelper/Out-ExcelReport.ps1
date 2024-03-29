<#

 .SYNOPSIS
 
 Saves results to a csv file
 
 
 .DESCRIPTION
 
 Saves results to a csv file and automatically uses the culture-specific delimiter. Optionally opens the csv file in Excel.
 
 
 .PARAMETER path
 
 Optional. Name of text file to create. Existing files will be overwritten. By default, a timestamped temporary file in the temp folder is created.
 
 .PARAMETER open
 
 Opens the csv file after creation in MS Excel (if installed and available).
 
 
 .EXAMPLE
 
 C:\PS>Get-Process | Where-Object { $_.MainWIndowTitle} | Select-Object Name, Description, Company, MainWindowTitle , CPU | Out-ExcelReport -Open
 Lists various pieces of information about running processes and writes them to a csv file. The file then is opened by Microsoft Excel.
 
 .EXAMPLE
 
 C:\PS>Get-ACL $env:windir | Out-ExcelReport -open
 Reads the windows folder NTFS permissions and writes the results to a csv file. The file then is opened by Microsoft Excel.
#>
function Out-ExcelReport {

 param(
  $path = "$env:temp\report$(Get-Date -format yyyyMMddHHmmss).csv",
  [switch]$open
 )
$Input | 
  Export-Csv $path -NoTypeInformation -UseCulture -Encoding UTF8
 
  if($open) { Invoke-Item $path }

}
