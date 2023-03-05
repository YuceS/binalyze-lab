<powershell>

Set-StrictMode -Version Latest
Set-ExecutionPolicy Unrestricted 

$downloadDir = "$env:LOCALAPPDATA\binalyze\air\agent"
Write-Log -Message "Download location is $PSScriptRoot"

Remove-Item $downloadDir -Force -Recurse -ErrorAction Ignore
New-Item -Path $downloadDir -ItemType Directory
Push-Location
Set-Location -Path $downloadDir

$share = 'http://${ServerName}:9999'

do {
    sleep 45
    $filelist = Invoke-WebRequest -Uri "$($share)/share/" -Method GET -DisableKeepAlive -UseBasicParsing 
    $installerName = $filelist.Links | ?{$_.href -match ".msi"}  | Select -ExpandProperty href    
    Write-Host "waiting..."
} while([string]::IsNullOrEmpty($installerName) )

echo $installerName
$installerurl = "$($share)/share/$($installerName)" 
$installerdir = "C:\Users\Administrator\AppData\Local\binalyze\air\agent\{0}" -f $installerName
echo $installerdir
(New-Object System.Net.WebClient).DownloadFile($installerurl, $installerdir)
Write-Host "downloaded..."
Start-Process C:\Windows\System32\msiexec.exe -ArgumentList "/i $installerName /quiet " -Wait
Write-Log "Installed."
Pop-Location
</powershell>
<persist>true</persist>
