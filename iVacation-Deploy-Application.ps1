<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
	Deploy-Application.ps1
.EXAMPLE
	Deploy-Application.ps1 -DeployMode 'Silent'
.EXAMPLE
	Deploy-Application.ps1 -AllowRebootPassThru -AllowDefer
.EXAMPLE
	Deploy-Application.ps1 -DeploymentType Uninstall
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	
	[string]$appName = 'iVacation'
	[string]$appVersion = '1.0.41'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '3.6.5'
	[string]$appScriptDate = '04/26/2022'
	[string]$appScriptAuthor = 'Generator Systems'
	##*===============================================
	
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.6.5'
	[string]$deployAppScriptDate = '04/26/2022'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================
	
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'
		
		## Prompt the user to close the following applications if they are running:
	    Show-InstallationWelcome -CloseApps 'iVacation' -PersistPrompt -CloseAppsCountdown 600
	    
	    
		
		
		##*===============================================
		##* INSTALLATION
		##*===============================================
		[string]$installPhase = 'Installation'
		
		# Install the base MSI and apply a transform
	    
        Execute-Process -Path 'AdobeAIR.exe' -Parameters '-silent -eulaAccepted'
		# Check if media already exists on system
		If (!(test-path -Path "C:\Generator Systems Ltd\Holiday Inn Club Vacations\media_list.xml")) {
			[xml]$mediaXML = Get-Content -Path "C:\Generator Systems Ltd\Holiday Inn Club Vacations\media_list.xml"
            # Check version of existing media, ensure you set the match to the version text being deployed via zip file
			If ($mediaXML.data.version.id -notmatch "1.0.70") {
				Expand-Archive -Path "$dirFiles\iVacation_Media_1_0_70.zip" -DestinationPath "C:\" -Force
			}

        }
		# Media not found on system; unpack media assume new deployment
        else{
			Expand-Archive -Path "$dirFiles\iVacation_Media_1_0_70.zip" -DestinationPath "C:\" -Force
        }
		# Check if iVacation exists on system; if so remove it
        if (test-path -Path "C:\Program Files (x86)\Generator Systems Ltd") {
        
            Remove-MSIApplications -Name 'iVacation'
            Start-Sleep -s 10
			Remove-Folder -Path "C:\Program Files (x86)\Generator Systems Ltd"
        }
		# Install Generator Systems iVacation
		Execute-Process -Path 'iVacation_v1.0.42.exe' -Parameters '-silent'

		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>

        New-Shortcut -Path "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\iVacation.lnk" -TargetPath "C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\iVacation.exe" -IconLocation "C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\iVacation.exe" -Description 'iVacation' 
        New-Shortcut -Path "C:\Users\Public\Desktop\iVacation.lnk" -TargetPath "C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\iVacation.exe" -IconLocation "C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\iVacation.exe" -Description 'iVacation'
		
		
		######################################################################################################################################################################
		# Added 2023/02/17 by Christopher Smith
		# Comment out Battery Status Module to resolve issue with Windows 10 22H2 devices
		# Generator Systems determined Microsoft deprecated an API they were leveraging to determine battery status and this causes the application to not launch completely
		# only loading a white screen and HICV logo. They will issue a patch later and the following block of code will need to be removed from the deployment to restore
		# battery status indicators to the application
		# Load in config_starup.xml file on device
		[xml]$xml = Get-Content -Path "C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\xml\config_startup.xml"
		# Locate line with battery status and convert it to a XML Comment
		$xml.selectnodes('//group[2]/content[9]') | ForEach-Object { 
			$abc = $_
			$comment = $xml.CreateComment($abc.OuterXML)
			$abc.ParentNode.ReplaceChild($comment, $abc)
		}
		# Save the modified config_startup.xml file
		$xml.Save("C:\Program Files (x86)\Generator Systems Ltd\Presenter\iVacation\xml\config_startup.xml")
		# End block to correct battery status issue
		#####################################################################################################################################################################


		## Display a message at the end of the install
		Show-InstallationPrompt -Message 'Installation Finished' -ButtonRightText 'OK' -Icon Information -NoWait
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 1
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
