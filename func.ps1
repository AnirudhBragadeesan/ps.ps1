Param
     (
         [Parameter (Mandatory= $false)][String] $ResourceGroup,
         [Parameter (Mandatory= $false)][String] $StorageAccountName
     )
#$srt = Get-AzKeyVaultSecret -VaultName 'keyfs' -Name 'test'
#$azureAplicationId ='122d2e97-f588-4ec5-ad5d-91ea8f571aa2'
#$azureTenantId= '6df164b8-1fa9-4ecc-b708-ef519900caee'
#$azurePassword = ConvertTo-SecureString $srt -AsPlainText -Force
#$psCred = New-Object System.Management.Automation.PSCredential($azureAplicationId , $azurePassword)
#Connect-AzAccount -Credential $psCred -TenantId $azureTenantId -ServicePrincipal
$ConnectionName = 'AzureRunAsConnection'
$ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName
Connect-AzAccount `
       -ServicePrincipal `
        -TenantId $ServicePrincipalConnection.TenantId `
        -ApplicationId $ServicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint
$storageAccount = Set-AzStorageAccount -ResourceGroupName $ResourceGroup `
    -Name $StorageAccountName `
    -AssignIdentity
Set-AzKeyVaultAccessPolicy `
    -VaultName "keyfs" `
    -BypassObjectIdValidation `
    -ObjectId $storageAccount.Identity.PrincipalId `
    -PermissionsToKeys wrapkey,unwrapkey,get
Set-AzStorageAccount -ResourceGroupName $ResourceGroup `
    -AccountName $StorageAccountName `
    -KeyvaultEncryption `
    -KeyName "abc" `
    -KeyVaultUri "https://keyfs.vault.azure.net/"