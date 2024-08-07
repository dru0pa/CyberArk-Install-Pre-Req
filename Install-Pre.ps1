#A script to Install some of the prerequisites for CyberArk.
#Place All files in a Folder called "Install-Folder"
#The script looks to install Chrome Enterprise.
#The script looks to install NotePad++(update the version as required)
#The script looks to install both vcredist_x64.exe and vcredist_x86.exe
#The script will install ndp48-x86-x64-allos-enu.exe as well
#It will also disable updates to Chrome via Service and ScheduledTask by disabling them.
#Writen By Andrew Price.

Write-Host "Start Chrome install"

# Define script location
$scriptPathG = Get-Location

# Define installer filename (replace with actual filename if different)
$installerFileG = "googlechromestandaloneenterprise.msi"

# Function to install Chrome Enterprise from local file
function InstallChromeLocal {
  param(
    [Parameter(Mandatory=$true)]
    [string] $installerFileG  # Name of the installer file
  )

  # Check if the installer file exists
  if (Test-Path "$scriptPathG\$installerFileG") {
    # Install Chrome silently
    Write-Host "Installing Chrome Enterprise from local file: $installerFileG..."
    Start-Process -FilePath "$scriptPathG\$installerFileG" "/quiet /norestart" -Wait
    Write-Host "Chrome Enterprise installation complete."
  } else {
    Write-Error "Error: Installer file '$installerFileG' not found in the script folder."
  }
}

# Install Chrome Enterprise
InstallChromeLocal -installerFileG $installerFileG

Write-Host "Chrome Enterprise installation complete (if the local file was found)."

Write-Host "Start NotePadd++ install"

# Define script location
$scriptPathNP = Get-Location

# Define installer filename (replace with actual filename if different)
$installerFileNP = "npp.8.6.9.Installer.x64.exe"

# Function to install Notepad++ from local file
function InstallNotepadPlusPlus {
  param(
    [Parameter(Mandatory=$true)]
    [string] $installerFileNP  # Name of the installer file
  )

  # Check if the installer file exists
  if (Test-Path "$scriptPathNP\$installerFileNP") {
    # Install silently (may require additional arguments depending on installer)
    Write-Host "Installing Notepad++ from local file: $installerFileNP..."
    Start-Process -FilePath "$scriptPathNP\$installerFileNP" -ArgumentList "/S" -Wait -NoNewWindow
  } else {
    Write-Error "Error: Installer file '$installerFileNP' not found in the script folder."
  }
}

# Install Notepad++
InstallNotepadPlusPlus -installerFileNP $installerFileNP

Write-Host "Notepad++ installation complete (if the local file was found)."


# Install vc

# Define script location
$scriptPathvc1 = Get-Location

# Define installer filename
$installerFilevc1 = "VC_redist.x86.exe"

# Function to install VC++ Redistributable (x86) from local file with error handling
function InstallVCRedistLocal {
  param(
    [Parameter(Mandatory=$true)]
    [string] $installerFilevc1
  )

  # Check if the installer file exists
  if (Test-Path "$scriptPathvc1\$installerFilevc1") {
    # Install silently (with error handling)
    Write-Host "Installing Visual C++ Redistributable (x86) from local file: $installerFilevc1..."
    try {
      Start-Process -FilePath "$scriptPathvc1\$installerFilevc1" -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
    } catch {
      Write-Error "Error installing VC++ Redistributable (x86): $($_.Exception.Message)"
    }
  } else {
    Write-Error "Error: Installer file '$installerFilevc1' not found in the script folder."
  }
}

# Install VC++ Redistributable (x86)
InstallVCRedistLocal -installerFilevc1 $installerFilevc1

Write-Host "Visual C++ Redistributable (x86) installation complete (if local file found and no errors occurred)."


# Define script location
$scriptPathvc2 = Get-Location

# Define installer filename
$installerFilevc2 = "VC_redist.x64.exe"

# Function to install VC++ Redistributable (x86) from local file with error handling
function InstallVCRedistLocal {
  param(
    [Parameter(Mandatory=$true)]
    [string] $installerFilevc2
  )

  # Check if the installer file exists
  if (Test-Path "$scriptPathvc2\$installerFilevc2") {
    # Install silently (with error handling)
    Write-Host "Installing Visual C++ Redistributable (x64) from local file: $installerFilevc2..."
    try {
      Start-Process -FilePath "$scriptPathvc2\$installerFilevc2" -ArgumentList "/quiet /norestart" -Wait -NoNewWindow
    } catch {
      Write-Error "Error installing VC++ Redistributable (x64): $($_.Exception.Message)"
    }
  } else {
    Write-Error "Error: Installer file '$installerFilevc2' not found in the script folder."
  }
}

# Install VC++ Redistributable (x64)
InstallVCRedistLocal -installerFile $installerFilevc2

Write-Host "Visual C++ Redistributable (x64) installation complete (if local file found and no errors occurred)."


Write-Host ".Net install started"

#install .Net

# Define script location
$scriptPathN = Get-Location

# Define installer filename (replace with actual filename if different)
$installerFileN = "ndp48-x86-x64-allos-enu.exe"


# Define the path to the local .NET Framework 4.8 installer file (replace with your actual path)
$installerPath = "$scriptPathN\$installerFileN"

# Check for Windows Server 2022
$isServer2022 = (Get-WmiObject Win32_OperatingSystem).Caption -like "*Windows Server 2022*"

# Check if .NET 4.8 is already installed OR if it's Windows Server 2022
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\Version\4.8") -and !$isServer2022) {
    # Check if the local installer file exists
    if (Test-Path $installerPath) {
        # Install .NET 4.8 silently
        Start-Process -FilePath $installerPath -ArgumentList "/q /norestart" -Wait -NoNewWindow
        Write-Host ".NET Framework 4.8 is being installed silently."
    } else {
        Write-Error "Error: Local installer file '$installerPath' not found."
    }
} else {
    if ($isServer2022) {
        Write-Host ".NET Framework 4.8 is not required for Windows Server 2022."
    } else {
        Write-Host ".NET Framework 4.8 is already installed."
    }
}

# Clean-up is not recommended for local installers (commented out)
# # Remove the local installer (optional)
# # Remove-Item -Path $installerPath -Force


# Get all services starting with "GoogleChrome"
$chromeServices = Get-Service -Name "GoogleChrome*"

# Stop and disable each service
foreach ($service in $chromeServices) {
    if ($service.Status -eq "Running") {
        Stop-Service -Name $service.Name
    }
    Set-Service -Name $service.Name -StartupType Disabled
}

Write-Host "All services starting with 'GoogleChrome' have been stopped and disabled."

# Get all services starting with "GoogleUpdater"
$googleServices = Get-Service -Name "GoogleUpdater*"

# Stop and disable each service
foreach ($service in $googleServices) {
    if ($service.Status -eq "Running") {
        Stop-Service -Name $service.Name
    }
    Set-Service -Name $service.Name -StartupType Disabled
}

Write-Host "All services starting with 'GoogleUpdate' have been stopped and disabled."

Write-Host "Chrome has been Installed and disabled services"

Write-Host "Group Police Report check"
Write-Host "Make sure there are no GPOs listed"
gpresult /h "C:\Install-Folder\LocalGrpPolReport.html"
start chrome "file:///C:/Install-Folder/LocalGrpPolReport.html"
Write-Host "Group Police Report check finished"
Write-Host "Checking for admin shares"
net share > share.txt
Write-Host "Checking for admin shares finished"
Write-Host "Finished the Script"
