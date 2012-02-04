# -------------------------------------------------------------------------------------------------	
# Session Preferences
# -------------------------------------------------------------------------------------------------	
# Set script debug
Set-PSDebug -Strict

# Set the execution policy
Set-ExecutionPolicy RemoteSigned

# -------------------------------------------------------------------------------------------------	
# Session Variables
# -------------------------------------------------------------------------------------------------	
# Get $profile path.
$_profilePath = (Split-Path $profile)
if (!(Test-Path $_profilePath))
{
	Write-Warning "Issue with the profile path."
}

# -------------------------------------------------------------------------------------------------	
# Load Alias
# -------------------------------------------------------------------------------------------------	
. (Join-Path $_profilePath My.Alias.ps1)

# -------------------------------------------------------------------------------------------------	
# Load Modules
# -------------------------------------------------------------------------------------------------	
#Import-Module Pscx 												#Basic preference
Import-Module Pscx -arg "$_profilePath\Pscx.UserPreferences.ps1" 	#Load personal copy preference
#Import-Module Pscx -arg @{ModulesToImport = @{Prompt = $true}} 	#Force settings.

# Load SQLPSX modules
Import-Module adolib
Import-Module SQLServer
Import-Module Agent
Import-Module Repl
#Import-Module SSIS			#Need Microsoft.SqlServer.ManagedDTS.dll, do not know if there is Feature Pack for SSIS.
Import-Module SQLParser
Import-Module Showmbrs
Import-Module SQLMaint
Import-Module SQLProfiler
Import-Module PerfCounters

# Load ModuleHelper
Import-Module ModuleHelper

# Load OutputHelper
Import-Module OutputHelper
