<#
.SYNOPSIS
   Creates a new module folder
.DESCRIPTION
   Creates a new module folder and adds the loader (.psm1) and manifest (.psd1) files.
   The module will automatically import all functions from all script (.ps1) files stored in the module folder.
.PARAMETER ModuleName
   Name of the module. This name will be used to identify and import the module.
.PARAMETER AllUsers
   Module is created in the AllUsers module location. Administrator privileges are required.
   BY default, the new module is created in the callers' user profile
.EXAMPLE
   New-ScriptModule -Name myNetworktools
   Creates a new module named "myNetworktools" and saves it the callers' profile. 
   Use "Get-Module -ListAvailable" to verify module creation.
   Store PowerShell scripts in your module to import them. Make sure these scripts contain function definitions only.
   Do not store PowerShell scripts in a module that immediately execute code, or else this code will be accidentally executed each time the module is imported. This causes delays and can be dangerous.
.EXAMPLE
   New-ScriptModule -Name c:\myModules\myTools
   Creates a new module named "myTools" and saves it at the location specified in -Name. 
   Modules stored in non-default locations will not be listed by Get-Module -ListAvailable.
   You will need to supply the complete path to the module folder to Import-Module in order to import the module.
#>
function New-ScriptModule {
	param(
	[Parameter(Mandatory=$true)]
	$Name,
	$Description = '',
	$Author = '',
	$Company = '',
	$Copyright = '',
	$Guid = $([System.Guid]::NewGuid()),
	$NestedModules = @(),
	$TypesToProcess = @(),
	$FormatsToProcess = @(),
	$RequiredModules = @(),
	$RequiredAssemblies = @(),
	$FileList = @(),
	[switch]$AllUsers
	)

	$code = 'gci $psscriptroot\*.ps1 | % { . $_.FullName }'
	if ($name -notlike '*:*') {
		$index = 0
		if ($AllUsers) {$index = -1}

		$path = Join-Path $($env:psmodulepath.Split(';')[$index]) $name
	} else {
		$path = $name
		$name = Split-Path $name -Leaf
	}

	try {
		New-Item (Join-Path $path "$Name.psm1") -ItemType File -Force -Value $code -ea Stop | Out-Null
		New-ModuleManifest -Guid $Guid -NestedModules $NestedModules -path (Join-Path $path "$name.psd1") -author $author -companyname $company -description $description -copyright $Copyright -ModuleToProcess "$Name.psm1" -Types $TypesToProcess -Formats $FormatsToProcess -RequiredModules $RequiredModules -RequiredAssemblies $RequiredAssemblies -FileList $FileList
	}
	catch {
		Throw "New-ScriptModule: $_ When using option -AllUsers, administrative privileges are required."
	}
}

<#
.SYNOPSIS
   Returns the file location for a module.
.DESCRIPTION
   Returns the path to the module folder.
.PARAMETER Name
   Name of module
.PARAMETER Open
   opens the module folder in Windows Explorer
.EXAMPLE
   Get-ModulePath Trouble*
   Returns paths for all modules that start with "Trouble*"
.EXAMPLE
   Get-ModulePath Trouble*
   Returns paths for all modules that start with "Trouble*"
.EXAMPLE
   Get-ModulePath Trouble*
   Returns paths for all modules that start with "Trouble*" and opens these folders in Windows Explorer
   Use -open if you want to examine module content
#>
function Get-ModulePath($name, [switch]$open) {
	$path = @()
	$path += @(Get-Module $name | Select-Object -expandProperty ModuleBase)
	$path += @(Get-Module $name -listavailable | Select-Object -expandProperty ModuleBase)
	$path = $path | Sort-Object -Unique
	if ($open) { Invoke-Item $path }
	$path
}


<#
.SYNOPSIS
   Removes and permanently deletes a module.
.DESCRIPTION
   Removes the module folder and its content. This operation cannot be undone. Be very careful when using this function.
.PARAMETER Name
   Name of module to delete
.PARAMETER Confirm
   $true by default, confirmation needed before any files or folders are deleted.
   Use -confirm:$false to disable default confirmation
.EXAMPLE
   Remove-ScriptModule -Name myNetworkTools
   Removes and deletes the module myNetworkTools permanently. A default confirmation asks for permission first. Once deleted, a module cannot be restored.
.EXAMPLE
   Remove-ScriptModule -Name myNetworkTools -confirm:$false
   Removes and deletes the module myNetworkTools permanently without prior confirmation. Use this for unattended operations. Deleting files or folders without confirmation can be dangerous.
#>
function Remove-ScriptModule {
	param(
	$Name,
	[switch]$confirm = $true
	)

	$path = Get-ModulePath $Name
	if (Test-Path $path) {
		Remove-Item $path -confirm:$confirm -recurse 
	}

}



<#
.SYNOPSIS
   Saves an in-memory-function to a file inside a module
.DESCRIPTION
   To import a function into a module, run the function and then use this Cmdlet to save it to a file inside a module. If the module does not yet exist, it will be created.
.PARAMETER FunctionName
   Name of the function. The function must exist in memory.
.PARAMETER ModuleName
   Name of the module to import the function into. 
   If the module does not yet exist, it will be created.
   If the function already exists inside the module, it will be updated after confirmation.
.EXAMPLE
   Out-Module -Function Out-TextReport -Module myTools
   adds the function "Out-TextReport" to the module "myTools"
   the function "Out-TextReport" must exist in memory.
#>
function Out-Module {
	param(
	[Parameter(Mandatory=$true)]
	$ModuleName,
  
  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
	$FunctionName
	)

	process {
    if ( @(Get-Module $ModuleName).Count -gt 0) {
      Remove-Module $ModuleName -force
    }
		try {
			$command = Get-Command -CommandType function $FunctionName -ErrorAction Stop
			$isFilter = $command.scriptblock.isFilter
		}
		catch {
			Throw "Cannot find function '$FunctionName'"
		}

		$definition = $command.Definition

		$scriptcode = & {

			$help = Get-Help $FunctionName
			if (-not ($help -is [System.String])) {
				$description = $help.Description | Select-Object -ExpandProperty Text
				$synopsis = $help.Synopsis
				$examples = $help.examples | Select-Object -ExpandProperty Example | ForEach-Object { 
					$rv = 1 | Select-Object Code, Remark
					$rv.Code = $_.Code
					$rv.Remark = $_.Remarks | Select-Object -ExpandProperty Text | Where-Object { $_ }
					$rv
				}
				try {
					$parameters = $help.parameters | Select-Object -ExpandProperty Parameter -ea Stop | ForEach-Object { 
						$rv = 1 | Select-Object Name, Description
						$rv.Name = $_.Name
						$rv.description = $_.description | Select-Object -ExpandProperty Text | Where-Object { $_ }
						$rv
					}
				} catch {}

				'<#'
				'.SYNOPSIS'
				"  $synopsis"
				'.DESCRIPTION'
				"  $description"
				$parameters | ForEach-Object {
					'.PARAMETER {0}' -f $_.Name
					$_.description | ForEach-Object {
						'  {0}' -f $_
					}
				}
				$examples | ForEach-Object {
					'.EXAMPLE'
					'  {0}' -f $_.Code
					$_.Remark | ForEach-Object {
						'  {0}' -f $_
					}
				} 
				'#>'
			} else {
				@'
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
'@
			}
			if ($isFilter) {
				"filter $FunctionName {"
			} else {
				"function $FunctionName {"
			}
			if ($definition -notlike '*CmdletBinding*') {
				if ($definition -notlike '*$Input*') {
					'[CmdletBinding()]'
					if ($command.Parameters.count -eq 0) {
					'param()'
					}
				}
			}

			$definition
			"}"
		}

		# make sure module exist
		$modulepath = Get-ModulePath $ModuleName
		if ($modulepath -eq $null) {
			New-ScriptModule $ModuleName
			$modulepath = Get-ModulePath $ModuleName 
		}
		$filename = Join-Path $modulepath "$functionName.ps1"
		if (Test-Path $filename) {
			$scriptcode | Out-File $filename -Confirm
		} else {
			$scriptcode | Out-File $filename
		}
    
	}
}

