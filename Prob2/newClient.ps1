$clientName = $args
$vmName = "$clientName-httpd"
$ressourceGroupName = "$clientName-RessGroup"

az group create `
    --name $ressourceGroupName `
    --location canadacentral 

az vm create `
    --resource-group $ressourceGroupName `
    --name $vmName `
    --image Debian `
    --size Standard_B1s `
    --admin-user maxime `
    --ssh-key-values ~/.ssh/id_rsa.pub `
    --public-ip-address-dns-name $vmName"-dns" `
    --location canadacentral

az network nsg rule create `
    --resource-group $ressourceGroupName `
    --nsg-name $vmName"NSG" `
    --name Allow_HTTP `
    --priority 100 `
    --protocol Tcp `
    --direction Inbound `
    --source-address-prefix '*' `
    --source-port-range '*' `
    --destination-address-prefix '*' `
    --destination-port-range 80 `
    --access Allow


Write-Host "VM créé"