## Add Customer Domains
Function Add-MyTeamsDomain
{
    param($CustomerTrunkPrefix)

    Read-Host "Must be connected via both Connect-MSOLService and Connect-MicrosoftTeams. Press Enter to continue"

    #set variables
    $tenantID = (Get-CsTenant).TenantID
    $lasFQDN = "$CustomerTrunkPrefix.las.myteamsuc.com"
    $cjrFQDN = "$CustomerTrunkPrefix.cjr.myteamsuc.com"
    $yyzFQDN = "$CustomerTrunkPrefix.yyz.myteamsuc.com"		
    if (!$CustomerTrunkPrefix)
        {
            $lasFQDN  = "las.myteamsuc.com"
            $cjrFQDN = "cjr.myteamsuc.com"
            $yyzFQDN = "yyz.myteamsuc.com"
        }

    $fqdnArray = ($lasFQDN,$cjrFQDN,$yyzFQDN)
    ForEach ($fqdn in $fqdnArray)
    {
        New-MsolDomain -TenantId $tenantID -Name $fqdn
    }

    Start-Sleep 1

    ForEach ($fqdn in $fqdnArray)
    {
        Get-MsolDomainVerificationDns -TenantId $tenantID -DomainName $fqdn -Mode DnsTxtRecord
    }

    Read-Host "Update DNS TXT Records before continuing.  Once updated, wait 5 minutes and then press Enter to continue"

    ForEach ($fqdn in $fqdnArray)
    {
        Confirm-MsolDomain -TenantId $tenantID -DomainName $fqdn
        Start-Sleep 2
        Get-MsolDomain -TenantId $tenantID -DomainName $fqdn
    }

}

Function Add-MyTeamsTempUsers
{

    Read-Host "Must be connected via Connect-MSOLService and Connect-MicrosoftTeams. Press Enter to continue"

    #Get Domains
    $domains = Get-MsolDomain
    $manual = Read-Host "Do you need to do Manual License Assignment? (Required if less than 3 licenses are available) [Y/N]"
    $l=$true
    Do {
        If ($manual -like "Y*")
        {
            foreach ($d in $domains)
            {
                If ($d.Name -like "*myteamsuc.com")
                {
                    [string]$UPN = $($d.Name.split(".")[1]+"@"+$d.Name)
                    [string]$DN = $d.Name.split(".")[1]
                    New-MsolUser -DisplayName $DN -UserPrincipalName $UPN
                }
            }
            $l=$false
        }
        elseif ($manual -like "N*")
        {
            #Get License SKUs
            Get-MsolAccountSku
            #$skuTeamsExp = $skus.AccountSkuId.Contains("*TEAMS_EXPLORATORY")
            $sku = Read-Host "Copy and Paste the AccountSkuId that will be used for the temp accounts here >>"
            foreach ($d in $domains)
            {
                If ($d.Name -like "*myteamsuc.com")
                {
                    [string]$UPN = $($d.Name.split(".")[1]+"@"+$d.Name)
                    [string]$DN = $d.Name.split(".")[1]
                    New-MsolUser -DisplayName $DN -UserPrincipalName $UPN
                    Start-Sleep 3
                    Set-MsolUser -UserPrincipalName $UPN -UsageLocation US 
                    Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses $sku
                }
            }
            $l=$false
        }
        else {$manual = Read-Host "*Invalid Entry* Do you need to do Manual License Assignment? (Required if less than 3 licenses are available) [Y/N]"}
    }
    Until (!$l)

}

Function Add-BulkAADUsers
{
    param([string] $importfile = $(Read-Host -prompt "Please enter the full file path to the CSV file for this user batch"))
    $importedusers = Import-CSV $importfile

    foreach ($user in $importedusers)
    {
        If ($user.Type -eq "User")
        {
            $check = Get-MsolUser -UserPrincipalName $user.UPN -ErrorAction SilentlyContinue

            If ($check)
            {
                Write-Host "User with UPN >>" $user.UPN "already exists..."
            }
            else 
            {
                New-MsolUser -DisplayName $user.DisplayName -UserPrincipalName $user.UPN -MobilePhone $user.MobilePhone
            }
        }
    }

}

Function Add-UserLicensing
{
    #param([string] $importfile = $(Read-Host -prompt "Please enter the full file path to the CSV file for this user batch"))
    #$importedusers = Import-CSV $importfile

    #Get License SKUs

    [array]$x = Get-MsolAccountSku

    Write-Host [array]$x
    
    #$skuTeamsExp = $skus.AccountSkuId.Contains("*TEAMS_EXPLORATORY")
    Start-Sleep 2
    $sku = Read-Host "Copy and Paste the AccountSkuId that will be used for the temp accounts here >>"
    foreach ($user in $importedusers)
    {
        If ($user.Type -eq "User")
        {
            Start-Sleep 3
            Set-MsolUser -UserPrincipalName $user.UPN -UsageLocation US 
            Set-MsolUserLicense -UserPrincipalName $user.UPN -AddLicenses $sku
        }
    }
}

Function Remove-MyTeamsTempUsers
{
    #Get Domains
    $domains = Get-MsolDomain
    foreach ($d in $domains)
    {
        If ($d.Name -like "*myteamsuc.com")
        {
            [string]$UPN = $($d.Name.split(".")[1]+"@"+$d.Name)
            Remove-MsolUser -UserPrincipalName $UPN -Force
        }
    }
}