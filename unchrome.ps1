Write-host "Closing all instances of Google Chrome..."
cmd /c taskkill /IM Chrome.exe /F

#Identify version and GUID of Google Chrome
Write-host "Identifying Google Chrome location..."
$AppInfo = Get-WmiObject Win32_Product -Filter "Name Like 'Google Chrome'"
$ChromeVer = $AppInfo.Version
$GUID = $AppInfo.IdentifyingNumber
Write-host "Google Chrome is installed as version:" $ChromeVer
Write-host "Google Chrome has GUID of:" $GUID


#Uninstall using MSIEXEC
Write-host "Attempting uninstall using MSIEXEC..."
& ${env:WINDIR}\System32\msiexec /x $GUID /Quiet /Passive /NoRestart


#Uninstall using Setup.exe uninstaller
Write-host "Attempting uninstall using Setup.exe uninstaller..."
If(Test-Path -Path C:\Progra~1\Google\Chrome\Application\$ChromeVer\Installer\){
    Write-host "Google Chrome is installed as 64-bit program..."
    & C:\Progra~1\Google\Chrome\Application\$ChromeVer\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
}
If(Test-Path -Path C:\Progra~2\Google\Chrome\Application\$ChromeVer\Installer\){
    Write-host "Google Chrome is installed as 32-bit program..."
    & C:\Progra~2\Google\Chrome\Application\$ChromeVer\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
}


#Uninstall using WMIC
Write-host "Attempting uninstall using WMIC..."
wmic product where "name like 'Google Chrome'" call uninstall /nointeractive


#Look for Google Chrome in HKEY_CLASSES_ROOT\Installer\Products\
Write-host "Deleting Google Chrome folder from HKLM:\Software\Classes\Installer\Products\"
$RegPath = "HKLM:\Software\Classes\Installer\Products\"

$ChromeRegKey = Get-ChildItem -Path $RegPath | Get-ItemProperty | Where-Object {$_.ProductName -match "Google Chrome"}
    
Write-Host "Product name found:" $ChromeRegKey.ProductName
Write-Host "Folder name found:" $ChromeRegKey.PSChildName

If(!$ChromeRegKey.PSChildName){
    Write-Host "Google Chrome not found in HKEY_CLASSES_ROOT\Installer\Products\"
}
If($ChromeRegKey.PSChildName){
    $ChromeDirToDelete = "HKLM:\Software\Classes\Installer\Products\" + $ChromeRegKey.PSChildName
    Write-Host "Google Chrome directory to delete:" $ChromeDirToDelete
    Remove-Item -Path $ChromeDirToDelete -Force -Recurse
}


Remove-Item -Path C:\Progra~1\Google\Chrome\ -Force -Recurse
Remove-Item -Path C:\Progra~2\Google\Chrome\ -Force -Recurse


Write-host "Uninstall operations have all completed." -fore green
