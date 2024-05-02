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
echo Installing/Updating DesktopAppInstaller - AKA winget
powershell.exe -ex bypass -noprofile -file "d:\DesktopAppInstaller\update_winget.ps1"

REM Install Company Portal
echo Installing Company Portal...
powershell.exe -ex bypass -noprofile -file d:\WingetAppInstaller\WingetAppInstallerForFFU.ps1 -AppName "Company Portal" -AppDisplayName "CompanyPortal"

REM Install Teams (New)
REM powershell.exe -ex bypass -noprofile -file "d:\Teams\install_teams.ps1"
echo Installing Teams...
d:\Teams\teamsbootstrapper.exe -p

REM Uninstall MS Bloat
echo Uninstalling Microsoft bloat...
powershell.exe -ex bypass -noprofile -file "d:\MSBloatRemoval\uninstall_ms_bloat.ps1"

REM NEW Umbrella Client install
powershell.exe -ex bypass -noprofile -file d:\Umbrella\install_umbrella_ffu.ps1

REM PaperCut
echo Installing PaperCut...
msiexec /i "d:\PaperCut\pc-print-deploy-client[papercut.washoe.wcsd].msi" /qn /norestart

REM TestNav
echo Installing TestNav...
msiexec /i "d:\TestNav\testnav.msi" /qn /norestart

REM NWEA
echo Installing NWEA...
msiexec /i "d:\NWEA\NWEA Secure Testing Browser.msi" /qn /norestart

REM DRC Insight
echo Installing DRC Insight...
msiexec /i "d:\DRC\drc_insight_setup.msi" /qn /norestart

REM Respondus LockDown Browser
echo Installing Respondus Lockdown Broswer...
msiexec /i "d:\Respondus\Respondus_LockDown_Browser_Lab_OEM.msi" /qn /norestart

REM Apply default power settings
echo Applying default power settings...
powershell.exe -ex bypass -noprofile -file "d:\PowerSettings\remediation.ps1"

REM Apply registry edits
echo Applying registry edits...
powershell.exe -ex bypass -noprofile -file  "d:\RegistryEdits\RegistryEdits.ps1"

REM Copying wifi profile to image
echo Adding wifi profile...
mkdir C:\deployment
copy "D:\WifiProfile\Wi-Fi-ap@WCSD.xml" "C:\deployment\Wi-Fi-ap@WCSD.xml"

REM Make weblinks
echo Making Clever shortcuts...
powershell.exe -executionpolicy bypass -file "D:\WebLinks\Intune_Shortcut_Maker.ps1" -Url "https://clever.com/in/washoe" -ShortcutName "Clever" -StartMenu -Desktop
echo Making Canvas shortcut...
powershell.exe -executionpolicy bypass -file "D:\WebLinks\Intune_Shortcut_Maker.ps1" -Url "https://washoe.instructure.com" -ShortcutName "Canvas" -StartMenu


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
