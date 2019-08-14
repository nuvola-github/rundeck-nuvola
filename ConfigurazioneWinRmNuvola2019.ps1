$url = "https://github.com/nuvola-github/rundeck-nuvola/blob/master/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

Enable-PSremoting –SkipNetworkProfileCheck  
Enable-WSManCredSSP -Role Server -Force

powershell.exe -ExecutionPolicy ByPass -File $file
