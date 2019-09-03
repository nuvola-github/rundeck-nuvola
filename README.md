# rundeck-nuvola

Questi i file per la creazione dell'immagine in dockerhub personalizzata Nuvola,
oltre agli script powershell 3.0 di configurazione di WinRm sul client.


# contenuto
ansible.cfg   : con figurazione di ansible

inventory.ini : inventario di esempio per ansible formato ini

ConfigurazioneWinRmNuvola2019.ps1 : 
Sul client (nodo) deve essere installato Windows6.1-KB2819745-x86-MultiPkg.msu  affinché Ansible possa accedere, dopo eseguire lo script per la configurazione di WinRm per Powershell 3.0.


Nuvola 2019 (c) (r)
