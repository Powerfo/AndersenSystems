Function Create-MyTeamsResourceAccounts
{
    param([string] $importfile = $(Read-Host -prompt "Please enter the full file path to the CSV file for this user batch"),[switch]$AssignToServices,[switch]$UpdateDN)

    $newaccounts = Import-CSV $importfile

    If ($newaccounts -and !$assignToServices -and !$UpdateDN)
    {
        foreach ($ra in $newaccounts)
        {
            If ($ra.Skip -ne "Yes" -and $ra.TypeID) 
            {
                New-CsOnlineApplicationInstance -UserPrincipalName $ra.UPN -DisplayName $ra.DisplayName -ApplicationId $ra.TypeID
            } elseif ($ra.Skip -ne "Yes" -and !$ra.TypeID)
            {
                New-CsOnlineApplicationInstance -UserPrincipalName $ra.UPN -DisplayName $ra.DisplayName
            }
        }
    }
    Elseif ($newaccounts -and $assignToServices -and !$UpdateDN)
    {
        foreach ($ra in $newaccounts)
        {
            If ($ra.Type -eq "CallQueue" -and $ra.Skip -ne "Yes")
            {
                #Get IDs
                $appID = (Get-CsOnlineUser -Identity $ra.UPN).ObjectID
                $cqID = (Get-CsCallQueue -NameFilter $ra.CQName).Identity
                
                #Connect IDs together
                New-CsOnlineApplicationInstanceAssociation -Identities @($appID) -ConfigurationId $cqID -ConfigurationType CallQueue
            }
        }
    }
    Elseif ($newaccounts -and !$assignToServices -and $UpdateDN)
    {
        foreach ($ra in $newaccounts)
        {
            If ($ra.Skip -ne "Yes" -and $ra.DisplayName)
            {
                Set-MsolUser -UserPrincipalname $ra.UPN -DisplayName $ra.DisplayName
            }
        }
    }
}