$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

Enable-PSremoting –SkipNetworkProfileCheck  
Enable-WSManCredSSP -Role Server -Force

powershell.exe -ExecutionPolicy ByPass -File $file