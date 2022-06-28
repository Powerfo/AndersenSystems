Function Get-MyTeamsInformation
{
    param([string] $ExportFileLocation,
    [string]$CustomerName,
    [switch]$Basic,
    #Default
    [switch]$Expanded,
    [switch]$RawDump,
    [switch]$EnabledWithPhoneOnly,
    [switch]$OnlyWithPhoneLicense,
    [switch]$CheckRoutedNumbers,
    [string]$RoutingLabel,
    [switch]$CQDetails)
    
    If ($defaultTeamsDumpLocation -and !$ExportFileLocation)
    {
        $ExportFileLocation = $defaultTeamsDumpLocation
    } elseif (!$ExportFileLocation)
    {
        $ExportFileLocation = $(Read-Host -prompt 'Please enter the file path to the location you want to dump the output file (End the filepath with a "\")')
    }

    If (!$CustomerName)
    {
        $CustomerName = (Get-CsTenant).DisplayName.Replace(" ","")
    }

    If (!$Basic -and !$Expanded -and !$RawDump)
    {
        $Expanded = $true
    }

    function Test-FileReady {
        param ([parameter(Mandatory=$true)][string]$Path)
    
        $File = New-Object System.IO.FileInfo $Path
        if ((Test-Path -Path $Path) -eq $false){
            # file does not exist
            return $true
        }
        try {
            # try to open file for exclusive access - [System.IO.FileShare]::None
            $Stream = $File.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            if ($Stream){  
                $Stream.Close() 
                # file is ready.
                return $true
            }
        }
        catch { 
            # file is locked.
            return $false
        }
    }

    [int]$loopbreak = 0
    Do {
        $filecheck = Test-FileReady "$ExportFileLocation$CustomerName-TeamsDump.xlsx"
        If (!$filecheck -and !$firstCheck)
            {
                Write-Host "Excel File is in use. File must be closed before proceeding. File will be checked every 5 seconds until closed or 30 minutes passes..." -NoNewline
                $firstCheck = $true
            } elseif (!$filecheck -and $firstCheck) {
                Write-Host "." -NoNewline
            }
        Start-Sleep 5
        $loopbreak =+ 1
    } Until ($filecheck -or $loopbreak -gt 360)

    #Check for ExcelImport module
    $check = Get-Command Export-Excel -ErrorAction SilentlyContinue
    If (!$check)
    {
        Write-Host 'The ImportExcel Module is required for this command, please run: "Install-Module -Name ImportExcel" prior to running this script.'
    }
    
    #Get User Details
    If ($RawDump)
    {
        If ($EnabledWithPhoneOnly)
        {
            $data = Get-CsOnlineUser -Filter {EnterpriseVoiceEnabled -eq $true -and LineURI -ne $null} 
        } else {
            $data = Get-CsOnlineUser
        }
        
    } elseif ($Expanded) {
        If ($EnabledWithPhoneOnly)
        {
            $data = Get-CsOnlineUser -Filter {EnterpriseVoiceEnabled -eq $true -and LineURI -ne $null} | Select-Object DisplayName,UserPrincipalName,IsSIPEnabled,EnterpriseVoiceEnabled,LineURI,TenantDialPlan,CallingLineIdentity,OnlineVoiceRoutingPolicy
        } else {
            $data = Get-CsOnlineUser | Select-Object DisplayName,UserPrincipalName,IsSIPEnabled,EnterpriseVoiceEnabled,LineURI,TenantDialPlan,CallingLineIdentity,OnlineVoiceRoutingPolicy
        }
    } else {
        #Basic
        If ($EnabledWithPhoneOnly)
        {
            $data = Get-CsOnlineUser -Filter {EnterpriseVoiceEnabled -eq $true -and LineURI -ne $null} | Select-Object DisplayName,UserPrincipalName,LineURI
        } else {
            $data = Get-CsOnlineUser | Select-Object DisplayName,UserPrincipalName,LineURI
        }
    }

    Export-Excel -Path "$ExportFileLocation$customerName-TeamsDump.xlsx" -InputObject $data -WorksheetName "TeamsUsers" -ClearSheet -FreezeTopRow -AutoFilter -AutoSize -TableName "TeamsUsers" -TableStyle Medium9

    #Get Resource Account Details
    If ($RawDump)
    {
        $data = Get-CsOnlineApplicationInstance
    } elseif ($Expanded) {
        $data = Get-CsOnlineApplicationInstance | Select-Object DisplayName,UserPrincipalName,PhoneNumber,ObjectID,ApplicationId
    } else {
        #Basic
        $data = Get-CsOnlineApplicationInstance | Select-Object DisplayName,UserPrincipalName,PhoneNumber
    }
    
    Export-Excel -Path "$ExportFileLocation$customerName-TeamsDump.xlsx" -InputObject $data -WorksheetName "TeamsResourceAccounts" -ClearSheet -FreezeTopRow -AutoFilter -AutoSize -TableName "TeamsResourceAccounts" -TableStyle Medium9

    #Get Call Queue Details
    If ($CQDetails)
    {
        $data = Get-CsCallQueue
    }
    If ($CQDetails)
    {
        Export-Excel -Path "$ExportFileLocation$customerName-TeamsDump.xlsx" -InputObject $data -WorksheetName "CallQueueDetails" -ClearSheet -FreezeTopRow -AutoFilter -AutoSize -TableName "CallQueueDetails" -TableStyle Medium9
    }
}