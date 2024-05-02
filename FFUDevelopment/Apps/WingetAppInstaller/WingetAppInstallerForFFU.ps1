#Requires -RunAsAdministrator

# This script is meant to be used to install MS Store apps system-wide using winget while a Windows image is in audit mode.
#
# Two things must be determined to use this script: The winget app name and the AppXProvisionedPackage displayname.
#   To get the winget app name, use the winget search command:
#       winget search "company portal"
#   To get the AppXProvisionedPackage display name, run one (or both) of the following commands on a machine or user profile with the app installed
#        Get-AppxPackage -name "Likely_app_name_here" # This is for the user install, can add *'s at the beginning and/or end as wildcards
#        Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -match "App_Name_Here"} # Use this if the app is already installed on the system, must be run as admin.
#
# To run the script, use the following syntax
#   WingetAppInstallerForFFU.ps1 -AppName "APP_NAME_HERE" -AppDisplayName "App_DisplayName_Here"
# Example: 
#   WingetAppInstallerForFFU.ps1 -AppName "Company Portal" -AppDisplayName "CompanyPortal"


param(
        [Parameter(Mandatory)]
        [string]$AppName,
        [Parameter(Mandatory)]
        [string]$AppDisplayName 
    )

function Start-RunAsSystem {
    param(
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][AllowEmptyString()][string]$Arguments 
    )
    Write-Host "    Leveraging Task Scheduler to run this as system..."
    $TaskName = "RunAsSystem_Install_$AppDisplayName"
    $TaskDescription = "We have to run as system this way because it's secure!"
    $Action = New-ScheduledTaskAction -Execute "$Command" `
        -Argument $CommandArguments
    # Create scheduled task and run it
    Register-ScheduledTask -Action $Action -TaskName $TaskName -Description $TaskDescription -User "NT AUTHORITY\SYSTEM"
    
    Write-Host "    Open Task Scheduler and run $TaskName manually." -ForegroundColor DarkYellow
    
    $TaskStatus = Get-ScheduledTaskInfo -TaskName $TaskName
    # Wait for task to complete then delete
    while($TaskStatus.LastTaskResult -ne 0){
        Start-Sleep -Seconds 15
        $TaskStatus = Get-ScheduledTaskInfo -TaskName $TaskName
    }

    # Delete scheduled task
    Unregister-ScheduledTask $Taskname -Confirm:$false
}
# Get current user to determine how the script should be run
$User = (whoami)

# If not system user, create scheduled task to run as SYSTEM to install app for all users
if(!($User -match "\\system$")){ # "\\system$" will match any domain's system user or a local system user.
    # Get path to this script to call again from scheduled task as SYSTEM user
    $ScriptFilePath = "`"$PSSCriptRoot\$($MyInvocation.MyCommand.Name)`""

    # Build scheduled task to be run as nt authority\system
    $Command = "cmd.exe"
    $CommandArguments = "/c powershell.exe -ex bypass -noprofile -file $ScriptFilePath -AppName `"$AppName`" -AppDisplayName `"$AppDisplayName`""

    # Create, run, and delete scheduled task
    Start-RunAsSystem -Command $Command -Arguments $CommandArguments

    # Check if app is installed
    $AppInstalled = Get-AppxprovisionedPackage -Online | Where-Object {$_.DisplayName -match "$AppDisplayName"}

    # Wait for app to install before exiting script
    While(!$AppInstalled){
        Start-Sleep -Seconds 15
        Write-Host "$AppName not yet installed..."
        $AppInstalled = Get-AppxprovisionedPackage -Online | Where-Object {$_.DisplayName -match "$AppDisplayName"}
    }
}
# If script is running as SYSTEM, use winget to install app for all users
else {
    Start-Transcript -Path "C:\deployment\$AppDisplayName.log"
    Write-Host "Installing $AppName..."
    [string]$WingetPackageName = 'Microsoft.DesktopAppInstaller'
    $WingetLocation = (Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq "$WingetPackageName"}).InstallLocation | Sort-Object -Descending | Select-Object -first 1

    #cmd /c """$WingetLocation\winget.exe"" install --name ""$AppName"" --accept-package-agreements --accept-source-agreements --source msstore --scope machine"
    Start-Process -FilePath "$WingetLocation\winget.exe" -ArgumentList "install --name ""$AppName"" --accept-package-agreements --accept-source-agreements --source msstore --scope machine" -Wait
    

    # Check if app is installed and exit with appropriate exit code
    $AppInstalled = Get-AppxprovisionedPackage -Online | Where-Object {$_.DisplayName -match "$AppDisplayName"}
    if(!$AppInstalled){
        Write-Host "$AppName installer failed."
        exit 1
    }else{
        Write-Host "$AppName installer succeeded."
        exit 0
    }

    Stop-Transcript
}