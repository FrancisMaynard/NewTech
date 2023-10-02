$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$clientName = $args
$vmName = $clientName + "-httpd"
$ressourceGroupName = $clientName + "_RessGroup"

if ($isAdmin) {
    az group create `
        --name $ressourceGroupName `
        --location canadacentral 

    az vm create `
        --ressource-group $ressourceGroupName `
        --name $vmName `
        --image Debian `
        --size Standard_B1s `
        --admin-user maxime `
        --ssh-key-values ~/.ssh/id_rsa.pub `
        --public-ip-address-dns-name "'$vmName' + '-dns'" `
        --location canadacentral

    az network nsg rule create `
        --resource-group $ressourceGroupName `
        --nsg-name $vmName + "NSG" `
        --name Allow_HTTP `
        --priority 100 `
        --protocol Tcp `
        --direction Inbound `
        --source-address-prefix '*' `
        --source-port-range '*' `
        --destination-address-prefix '*' `
        --destination-port-range 80 `
        --access Allow
}
else {
    Write-Host "Vous devez être administrateur pour pouvoir exécuter le script"
}