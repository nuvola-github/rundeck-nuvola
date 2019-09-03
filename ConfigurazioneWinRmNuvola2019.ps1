# Eseguire queste righe in Powershell ISE 3.0 
# AVVIATO CON PERMESSI AMMINISTRATORE

# Controlla che la versionedi powershell  sia almento 3.0
$PSVersionTable

# Abilita l'elesuzione dello script di cui verrà fatto il download
set-executionpolicy remotesigned

# Esegui il  blocco sotto : 
$url = "https://raw.githubusercontent.com/nuvola-github/rundeck-nuvola/master/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

# Abilita la configurazione di winrm su tutte le schede di rete
Enable-PSremoting –SkipNetworkProfileCheck  

# Abilita l'autenticazione con il protocollo CredSSP
Enable-WSManCredSSP -Role Server -Force

# Configura winrm per questa macchina
powershell.exe -ExecutionPolicy ByPass -File $file
