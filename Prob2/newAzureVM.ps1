$clientName = $args;
$resourceGroupName = "$clientName-RessGroup";

Connect-AzAccount

New-AzResourceGroup `
    -Name $resourceGroupName `
    -Location canadacentral

$adminUser = Read-Host "Entrez un nom d'administrateur "
$tempAdminPass = Read-Host "Veuillez entrer un mot de passe " -AsSecureString
$adminPass = ConvertTo-SecureString -String $tempAdminPass -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $adminPass 


New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Name $clientName"-static" `
    -ImageName UbuntuLTS `
    -Size Standard_B1s `
    -Location canadacentral `
    -VirtualNetworkName $clientName"-vnet" `
    -PublicIpAddressName $clientName"-static-Ip" `
    -OpenPorts 22, 80, 443 `
    -Credential $credential

New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Name $clientName"-httpd" `
    -ImageName UbuntuLTS `
    -Size Standard_B1s `
    -Location canadacentral `
    -VirtualNetworkName $clientName"-vnet" `
    -PublicIpAddressName $clientName"-httpd-Ip" `
    -OpenPorts 22, 80, 443 `
    -Credential $credential `
    -SubnetName $clientName"-static"

New-AzVm `
    -ResourceGroupName $resourceGroupName `
    -Name $clientName"-postgresql" `
    -ImageName UbuntuLTS `
    -Size Standard_B1s `
    -Location canadacentral `
    -VirtualNetworkName $clientName"-vnet" `
    -PublicIpAddressName $clientName"-postgresql-Ip" `
    -OpenPorts 22, 80, 443 `
    -Credential $credential `
    -SubnetName $clientName"-static"
