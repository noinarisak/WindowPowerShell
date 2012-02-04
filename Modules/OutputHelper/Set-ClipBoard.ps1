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
function Set-ClipBoard {
	param(
	$text
	)
	Add-Type -AssemblyName System.Windows.Forms 
	$tb = New-Object System.Windows.Forms.TextBox 
	$tb.Multiline = $true 
	
	if ($Input -ne $null) {
		$Input.Reset()
	  $tb.Text = $Input | Out-String
	} else {
		$tb.Text = $text 
	}
	$tb.SelectAll() 
	$tb.Copy() 
}