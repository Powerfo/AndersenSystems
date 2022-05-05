Function Start-MyTeamsDeployment
{
    param($CustomerTrunkPrefix,[switch]$WestPrimary,[switch]$EastPrimary,[switch]$CanadaPrimary)

    Add-MyTeamsDomain -CustomerTrunkPrefix $CustomerTrunkPrefix

    Add-MyTeamsTempUsers

    [int]$c = 0
    $f = $false
    Do {
    If ($WestPrimary -or $c -eq 1) {$f = $true; Add-MyTeamsPSTNUsages -WestPrimary}
    elseif ($EastPrimary -or $c -eq 2) {$f = $true; Add-MyTeamsPSTNUsages -EastPrimary}
    elseif ($CanadaPrimary -or $c -eq 3) {$f = $true; Add-MyTeamsPSTNUsages -CanadaPrimary}
    else {
        Write-Host "Please Select Primary Location:"
        Write-Host "1. US West Coast"
        Write-Host "2. US East Coast"
        Write-Host "3. Canada"
        $c = Read-Host "Input number selection"
    }
    } 
    Until ($f)

    ## Remove Default Local Route
    $check = Get-CsOnlineVoiceRoute -Identity LocalRoute
    If ($check) {Remove-CsOnlineVoiceRoute -Identity LocalRoute}
    $check = $false

    Add-MyTeamsVoiceRoutes -CustomerTrunkPrefix $CustomerTrunkPrefix
    
    Remove-MyTeamsTempUsers

    Add-MyTeamsOnlineVoiceRoutingPolicies

    $l = $true
    $check = Read-Host "Would you like to run user enablement at this time? (Y/N)"
    Do {
    If ($check -like "Y*")
        {
            $l=$false
            Enable-MyTeamsUsers
        }
    elseif ($check -like "N*") {$l=$false}
    else {$check = Read-Host "*Invalid Entry* Would you like to run user enablement at this time? (Y/N)"}
    }
    Until (!$l)
    $check=$false
}