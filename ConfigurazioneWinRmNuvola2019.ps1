
# Eseguire queste righe in Powershell ISE 3.0

set-executionpolicy remotesigned

$url = "https://raw.githubusercontent.com/nuvola-github/rundeck-nuvola/master/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

Enable-PSremoting –SkipNetworkProfileCheck  
Enable-WSManCredSSP -Role Server -Force

powershell.exe -ExecutionPolicy ByPass -File $file
