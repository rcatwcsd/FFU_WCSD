@ECHO OFF
REM M365 Apps/Office ProPlus
REM d:\Office\setup.exe /configure d:\office\DeployFFU.xml
REM Install Defender Platform Update
REM Install Defender Definitions
REM Install Windows Security Platform Update
REM Install OneDrive Per Machine
REM Install Edge Stable
REM THE ABOVE LINES MUST NOT BE CHANGED. DO NOT MOVE IT UNLESS YOU KNOW WHY.
REM _______________________________________________________________________________________

REM Add additional apps below here
REM Contoso App (Example)

REM EXAMPLE:
REM REM Install Example App
REM echo Installing this example app...
REM msiexec /i d:\Contoso\setup.msi /qn /norestart
REM END EXAMPLE

REM Installing/Updating DesktopAppInstaller (AKA winget)
powershell.exe -ex bypass -noprofile -file "d:\DesktopAppInstaller\update_winget.ps1"

REM Install Company Portal
echo Installing Company Portal...
powershell.exe -ex bypass -noprofile -file d:\WingetAppInstaller\WingetAppInstallerForFFU.ps1 -AppName "Company Portal" -AppDisplayName "CompanyPortal"

REM Uninstall MS Bloat
echo Uninstalling Microsoft bloat...
powershell.exe -ex bypass -noprofile -file "d:\MSBloatRemoval\uninstall_ms_bloat.ps1"

REM NEW Umbrella Client install
powershell.exe -ex bypass -noprofile -file d:\Umbrella\install_umbrella_ffu.ps1

REM Raptor Hardware Install
echo Installing .net 3.5 for Raptor Hardware Services...
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All 
echo Installing Raptor Hardware Services...
D:\RaptorHardware\RaptorHardwareServices.exe /s

REM Apply registry edits
echo Applying registry edits...
powershell.exe -ex bypass -noprofile -file  "d:\RegistryEdits\RegistryEdits.ps1"

REM Apply default power settings
echo Applying default power settings...
powershell.exe -ex bypass -noprofile -file "d:\PowerSettings\remediation.ps1"
echo Applying registry edits...
powershell.exe -ex bypass -noprofile -file  "d:\RegistryEdits\RegistryEdits.ps1"

REM Copy wifi profile to image
echo Adding wifi profile...
mkdir C:\deployment
copy "D:\WifiProfile\Wi-Fi-ap@WCSD.xml" "C:\deployment\Wi-Fi-ap@WCSD.xml"


REM DO NOT EDIT BELOW THIS LINE UNLESS YOU HAVE GOOD REASON
echo Finalizing the image...
REM The below lines will remove the unattend.xml that gets the machine into audit mode. If not removed, the OS will get stuck booting to audit mode each time.
REM Also kills the sysprep process in order to automate sysprep generalize
del c:\windows\panther\unattend\unattend.xml /F /Q
del c:\windows\panther\unattend.xml /F /Q
taskkill /IM sysprep.exe
timeout /t 10
REM Run Component Cleanup since dism /online /cleanup-image /analyzecomponentcleanup recommends it
REM If adding latest CU, definitely need to do this to keep FFU size smaller
dism /online /cleanup-image /startcomponentcleanup /resetbase
REM Sysprep/Generalize
c:\windows\system32\sysprep\sysprep.exe /quiet /generalize /oobe
