$ProgressPreference = 'SilentlyContinue'

$DeploymentFolder = "C:\deployment"
if(!(Test-Path -Path $DeploymentFolder -PathType Container)){
    mkdir $DeploymentFolder -Force
}

Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$DeploymentFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

#Install WinGet MSIXBundle 
Try{
    Write-Host "Installing MSIXBundle for App Installer..." 
    Add-AppxProvisionedPackage -Online -PackagePath "$DeploymentFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense 
    Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
}
Catch{
    Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
    Write-Host "Image creation may not complete successfully..."
    Read-Host "Press [ENTER] to continue anyway..."
} 

#Remove WinGet MSIXBundle 
Remove-Item -Path "$DeploymentFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue