$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

if ($isAdmin){
    $newClient = $args
    echo $newClient
    $newConfigClientExists = Test-Path("C:\Travail\commun\config\$newClient")
    $newTechClientExists = Test-Path("C:\Travail\NewTech\$newClient")

    if($newClient){
        if(!$newConfigClientExists -and !$newTechClientExists){
        ni -Path "C:\Travail\commun\config" -Name "$newClient" -ItemType Directory
        $ipAddress = get-content next.txt
        $ipToUse = [int]$ipAddress

        ni -Path "C:\Travail\NewTech" -Name "$newClient" -ItemType Directory

        Copy-Item "C:\Travail\commun\Vagrantfile.template" -Destination "C:\Travail\NewTech\$newClient\Vagrantfile"

        $content = Get-Content -Path "C:\Travail\NewTech\$newClient\Vagrantfile"
        $content = $content -replace '{{ip1}}', $ipToUse
        $content = $content -replace '{{ip2}}', ($ipToUse+1)
        $content = $content -replace '{{ip3}}', ($ipToUse+2)
        Set-Content "C:\Travail\NewTech\$newClient\Vagrantfile" -Value $content

        Set-Content "C:\Travail\commun\next.txt" -Value ($ipToUse+3)

        $hostsExists = Dir("C:/Travail/commun/config/hosts")
        if ($hostsExists = ""){
            ni -Path "C:\Travail\commun\config" -Name hosts -ItemType File
        }

        #Writing used IP adresses by the $newClient
        Add-Content "C:\Travail\commun\config\hosts" -Value "[$newClient]"
        for($i =0; $i -lt 3; $i=$i+1){
            Add-Content "C:\Travail\commun\config\hosts" -Value ("192.168.33." + ($ipToUse+[int]$i))
        }
        Add-Content "C:\Travail\commun\config\hosts" -Value ""

        #PROMPT $newClient.com et api.$newClient.com sur hôte
        $title    = "Ajouter noms domaine à l'hôte"
        $question = "Voulez-vous que les entrées $newClient.com et api.$newClient.com fonctionnent sur cet hôte?"
        $choices  = '&Yes', '&No'

    
        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
        if ($decision -eq 0) {
            Write-Host 'confirmed'
            for($i =0; $i -lt 2; $i=$i+1){
                if($i -eq 0){
                    Add-Content "C:\Windows\System32\drivers\etc\hosts" -Value ("192.168.33." + ($ipToUse+[int]$i) + "    $newClient.com")
                    continue
                }
                if($i -eq 1){
                    Add-Content "C:\Windows\System32\drivers\etc\hosts" -Value ("192.168.33." + ($ipToUse+[int]$i) + "    api.$newClient.com")
                    continue
                }
                Add-Content "C:\Windows\System32\drivers\etc\hosts" -Value ("")
            }
        } else {
            Write-Host 'cancelled'
        }

        #CREATION fichiers YML dans commun/config/$newClient
        Copy-Item "C:\Travail\commun\template\install-static.yml.template" -Destination "C:\Travail\commun\config\$newClient\install-static.yml"
        $content = Get-Content -Path "C:\Travail\commun\config\$newClient\install-static.yml"
        $content = $content -replace '{{ip1}}', ($ipToUse)
        Set-Content "C:\Travail\commun\config\$newClient\install-httpd.yml" -Value $content

        Copy-Item "C:\Travail\commun\template\install-httpd.yml.template" -Destination "C:\Travail\commun\config\$newClient\install-httpd.yml"
        $content = Get-Content -Path "C:\Travail\commun\config\$newClient\install-httpd.yml"
        $content = $content -replace '{{ip2}}', ($ipToUse+1)
        Set-Content "C:\Travail\commun\config\$newClient\install-httpd.yml" -Value $content

        Copy-Item "C:\Travail\commun\template\install-postgresql.yml.template" -Destination "C:\Travail\commun\config\$newClient\install-postgresql.yml"
        $content = Get-Content -Path "C:\Travail\commun\config\$newClient\install-postgresql.yml"
        $content = $content -replace '{{ip3}}', ($ipToUse+2)
        $content = $content -replace '{{db_user}}', ($newClient)
        $content = $content -replace '{{password}}', ($newClient - '12345*')
        Set-Content "C:\Travail\commun\config\$newClient\install-postgresql.yml" -Value $content

        #CREATION dans commun/config/$newClient
        Copy-Item "C:\Travail\commun\template\setupssh.sh.template" -Destination "C:\Travail\commun\config\$newClient\setupssh.sh"
        $content = Get-Content -Path "C:\Travail\commun\config\$newClient\setupssh.sh"
        $content = $content -replace '{{ip1}}', $ipToUse
        $content = $content -replace '{{ip2}}', ($ipToUse+1)
        $content = $content -replace '{{ip3}}', ($ipToUse+2)
        Set-Content "C:\Travail\commun\config\$newClient\setupssh.sh" -Value $content
        $setupsshScriptPath = "C:\Travail\commun\config\$newClient\setupssh.sh"

        #CREATION playbook.sh dans commun/config/$newClient
        Copy-Item "C:\Travail\commun\template\playbook.sh.template" -Destination "C:\Travail\commun\config\$newClient\playbook.sh"
        $content = Get-Content -Path "C:\Travail\commun\config\$newClient\playbook.yml"
        $content = $content -replace '{{newClient}}', ($newClient)
        Set-Content "C:\Travail\commun\config\$newClient\playbook.sh" -Value $content
        $playbookScriptPath = "C:\Travail\commun\config\$newClient\playbook.sh"

        #CREATE $newClient.sh - ADD .sh files into it - RUN $newClient.sh for VM configurations
        New-Item -Path "C:\Travail\commun\config\$newClient" -Name "$newClient.sh" -ItemType File
        $setupsshContent = Get-Content -Path $setupsshScriptPath
        $playbookContent = Get-Content -Path $playbookScriptPath
        $ansibleContent = Get-Content -Path "C:\Travail\commun\config\ansible.sh"
        Add-Content -Path "C:\Travail\commun\config\$newClient\$newClient.sh" -Value $ansibleContent
        Add-Content -Path "C:\Travail\commun\config\$newClient\$newClient.sh" -Value $setupsshContent
        Add-Content -Path "C:\Travail\commun\config\$newClient\$newClient.sh" -Value $playbookContent
        $newClientAnsiblePath = "C:\Travail\commun\config\$newClient\$newClient.sh"
        Invoke-Expression "ansible-playbook -i inventory_file $newClientAnsiblePath"
    }   
    else {
        Write-Host "Le client existe déjà"
    }
    } else {
        Write-Host "Nom du client introuvable en argument, veuillez inscrire le nom du client dans la commande pwsh.exe"
    }
} else {
    Write-Host "Vous n'avez pas les accès nécessaires pour exécuter ce script"
}






