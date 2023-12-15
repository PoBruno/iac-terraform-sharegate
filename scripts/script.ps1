# Path: scripts/script.sh
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

mkdir 'c:\temp\test'

#Personal Windows Server 2022 Configs
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/install-powershell.ps1'))

Install-Module -Name PSWindowsUpdate -Force
Install-Module -Name PSReadLine -Force

ForEach ($Module in (Get-Module -ListAvailable)) {
    Write-Host "Updating Module $($Module.Name)..."
    Update-Module -Name $Module.Name -Force
}

Add-Content -Path $PROFILE -Value "Import-Module PSReadLine"
Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionSource History"
Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -EditMode Windows"
Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -BellStyle None"
Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionViewStyle ListView"
Add-Content -Path $PROFILE -Value "Set-PSReadLineOption -PredictionSource History"


#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Chocolatey Packages
choco install microsoft-windows-terminal -y
choco install vscode -y
choco install winget -y
winget upgrade

#Winget Packages
winget install Microsoft.PowerToys -y
winget install Microsoft.WindowsTerminal -y
winget install Microsoft.VisualStudioCode -y
winget install Microsoft.PowerShell -y
winget install Microsoft.PowerShellPreview -y
winget install Microsoft.PowerShell.SecretManagement -y
winget install Microsoft.PowerShell.SecretStore -y


#Install Winget

get-package -Name Microsoft.DesktopAppInstaller -ProviderName winget -ForceBootstrap | Uninstall-Package -Force -Verbose


