<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>
function Get-ClipBoard {
 
	Add-Type -AssemblyName System.Windows.Forms 
	$tb = New-Object System.Windows.Forms.TextBox 
	$tb.Multiline = $true 
	$tb.Paste() 
	$tb.Text 

}
