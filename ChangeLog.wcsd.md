# May 2, 2024 (2)
  - Full rebase with WCSD changes implemented to hopefully make upstream changes easier to implement.
  - `Make_New_WCSD_Image.ps1` will append image type to FFU file name when finished.
    - Fixed final FFU path in `Make_New_WCSD_Image.ps1`
  - Removed Company Portal from Raptor image (requires something in Office to install successfully).
  - Fixed the formatting on this file


# May 2, 2024
  - Merged latest upstream changes - https://github.com/rbalsleyMSFT/FFU#updates
  - Migrated all WCSD specific changes out of `BuildFFUVM.ps1` and into `Make_New_WCSD_Image.ps1`
    - Makes upstream changes easy to merge. The only file that likely needs editing/monitoring for upstream changes is `ApplyFFU.ps1`
    - The BuildFFUUnattend files are now selected in `Make_New_WCSD_Image.ps1`
    - Added DEPLOYFFU-PROD.xml
    - Moved Office install command in each `InstallAppsandSysprep-*.cmd` file to be on the 3rd line.
      - This is required to comply with `BuildFFUVM.ps1`
  - Consolidated `ApplyFFU.ps1` changes for easier migration of upstream changes
    - All changes marked as a comment with `WCSD Edit {Number}`
  - Created a simpler FFU specific Umbrella install script to prevent false errors from being reported during installation


# April 5, 2024
  - Added new config for Raptor kiosks and updated `Make_New_WCSD_Image.ps1` to allow use
    - `FFUDevelopment\Apps/InstallAppsandSysprep-RAPTOR.cmd`
  - Removed old Umbrella installer and renamed `Umbrella-New` Apps folder to `Umbrella`
    - Updated InstallAppsandSysprep files to reflect this
  - Cleaned up all InstallAppsandSysprep files to make them more readable
  - Updated Umbrella tag files for latest version
  - The command to capture the VM host IP address in `Make_New_WCSD_Image.ps1` has been adjusted to account for some weird situations where the variable is filled as an array instead of a string (might happen on machnines with more than 1 nic)
  - Transitioned away from requiring PsExec to install winget apps for all users
    - Unfortunately, this broke full automation of image creation. Winget apps must now be installed by manually running a scheduled task that gets created.


# March 1, 2024
  - Added `Microsoft.BingNews` to `FFUDevelopment\Apps\MSBloatRemoval\uninstall_ms_bloat.ps1`
  - Disabled Win11 Copilot in `FFUDevelopment\Apps\RegistryEdits\RegistryEdits.ps1` - using default user registry hive


# January 30, 2024
  - Created this changelog!
  - Created readmes for base and kiosk
  - Added a `Clear-Host` towards the beginning of `WinPEDeployFFUFiles\ApplyFFU.ps1` for a cleaner experience when imaging
  - Added `@echo off` to WinPEDeployFFUFiles\Windows\System32\startnet.cmd for a cleaner experience when imaging
  - Transitioned Umbrella client to Cisco Secure Client version
  - Attempted to disable Copilot for Windows 11 via registry (did not work, so it is commented out)
  - Corrected a mistake in the Set-Registry function of Apps\RegistryEdits\RegistryEdits.ps1
  - Scripted the update of DesktopAppInstaller (AKA winget)
    - Image creation process no longer requires user interaction!