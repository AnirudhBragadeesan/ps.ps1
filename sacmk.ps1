Param

     (

         [Parameter (Mandatory= $false)][String] $ResourceGroup,

         [Parameter (Mandatory= $false)][String] $StorageAccountName

     )

$ConnectionName = 'AzureRunAsConnection'

$ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName

$ipAdress =@("148.168.216.0/24","148.168.40.0/24","148.168.96.0/24","204.114.176.0/26","170.116.64.0/24","204.114.248.0/26","204.114.196.0/24","168.224.160.0/24")

Connect-AzAccount `

       -ServicePrincipal `

        -TenantId $ServicePrincipalConnection.TenantId `

        -ApplicationId $ServicePrincipalConnection.ApplicationId `

        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint

$storageAccount = Set-AzStorageAccount -ResourceGroupName $ResourceGroup `

    -Name $StorageAccountName `

    -AssignIdentity

Set-AzKeyVaultAccessPolicy `

    -VaultName "cspwdev-kv1-eastus1" `

    -BypassObjectIdValidation `

    -ObjectId $storageAccount.Identity.PrincipalId `

    -PermissionsToKeys wrapkey,unwrapkey,get

Set-AzStorageAccount -ResourceGroupName $ResourceGroup `

    -AccountName $StorageAccountName `

    -KeyvaultEncryption `

    -KeyName "cmkforsakey" `

    -KeyVaultUri "https://cspwdev-kv1-eastus1.vault.azure.net/"

for ($i=0;$i -lt 8; $i++) {

    Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroup -AccountName $StorageAccountName -IPAddressOrRange $ipAdress[$i]

    }