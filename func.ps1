Param
(
[Parameter (Mandatory= $false)][String] $ResourceGroup,
[Parameter (Mandatory= $false)][String] $Resource
)

$ConnectionName = 'AzureRunAsConnection'
$ServicePrincipalConnection = Get-AutomationConnection -Name $ConnectionName
$ipAdress =@("0.0.0.0/32","148.168.216.0/24","148.168.40.0/24","148.168.96.0/24","204.114.176.0/26","170.116.64.0/24","204.114.248.0/26","204.114.196.0/24","168.224.160.0/24")
Connect-AzAccount `
-ServicePrincipal `
-TenantId $ServicePrincipalConnection.TenantId `
-ApplicationId $ServicePrincipalConnection.ApplicationId `
-CertificateThumbprint $ServicePrincipalConnection.CertificateThumbprint
$Result=Get-AzWebAppAccessRestrictionConfig -ResourceGroupName $ResourceGroup -Name $Resource
if($Result.MainSiteAccessRestrictions.RuleName -eq "IpRule")
{
Write-Output 'No need to add'
}
else
{
  for ($i=0;$i -lt 9; $i++) {
    $p = 100+$i
     Add-AzWebAppAccessRestrictionRule -ResourceGroupName $ResourceGroup -WebAppName $Resource -Name IpRule-$i -Priority $p -Action Allow -IpAddress $ipAdress[$i]
    }
Set-AzWebApp -ResourceGroupName $ResourceGroup -Name $Resource -HttpsOnly $true
}
