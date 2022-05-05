Function Add-MyTeamsOnlineVoiceRoutingPolicies
	{
	
	param([switch]$WestOnly,[switch]$EastOnly,[switch]$CanadaOnly,[switch]$USOnly)
	
	##Default Switch - Set all OVRPs##
	$setALLOVRP = $true
	$pstnUsages = $(Get-csOnlinePstnUsage).Usage
	$defaultUsage = $pstnUsages.Split(',')[0]
	$pstnUsageList = $pstnUsages.Split(',')
	$pstnUsageUSWEST = "US West"
	$pstnUsageUSEast = "US East"
	$pstnUsageCanada = "Canada"
	$pstnUsageUSWESTUnrestricted = "US West Unrestricted"
	$pstnUsageUSEastUnrestricted = "US East Unrestricted"
	$pstnUsageCanadaUnrestricted = "Canada Unrestricted"
	$pstnUsageEmergency = "Emergency"
	
	##*REMOVING*Set Default Voice Routing Policy*REMOVING*##
	<#
	Write-Host "Setting Global Voice Policy with usages:" $pstnUsageList[0]","$pstnUsageList[1]","$pstnUsageList[2]","$pstnUsageList[3] -nonewline
	Do
		{
		Write-Host "." -nonewline
		Set-CsOnlineVoiceRoutingPolicy -Identity Global -OnlinePstnUsages $pstnUsageList[0],$pstnUsageList[1],$pstnUsageList[2],$pstnUsageList[3] -ErrorAction SilentlyContinue
		Start-Sleep 2
		}
	Until ($(Get-CsOnlineVoiceRoutingPolicy -Identity Global).OnlinePstnUsages -eq $defaultUsage) 
	Write-Host "."
	#>

	
	##Create New Voice Routing Policies##
		##Create US West Policy##
	If ($setALLOVRP -or $WestOnly -or $USOnly -and !$EastOnly -and !$CanadaOnly)
		{
		Write-Host "Setting US West Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageUSWEST","$pstnUsageUSEast","$pstnUsageCanada
		Do
			{
			Write-Host "." -nonewline
			New-CsOnlineVoiceRoutingPolicy -Identity "US West" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageUSWEST,$pstnUsageUSEast,$pstnUsageCanada -ErrorAction SilentlyContinue
			
			$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "US West" -ErrorAction SilentlyContinue
			Start-Sleep 2
			}
		Until ($checkOVRP) 
		Write-Host "."
		}
		##Create US East Policy##
	If ($setALLOVRP -or $EastOnly -or $USOnly -and !$WestOnly -and !$CanadaOnly)
		{
		Write-Host "Setting US East Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageUSEast","$pstnUsageUSWEST","$pstnUsageCanada
		Do
			{
			Write-Host "." -nonewline
			New-CsOnlineVoiceRoutingPolicy -Identity "US East" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageUSEast,$pstnUsageUSWEST,$pstnUsageCanada -ErrorAction SilentlyContinue
			
			$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "US East" -ErrorAction SilentlyContinue
			Start-Sleep 2
			}
		Until ($checkOVRP) 
		Write-Host "."
		}
		##Create Canada Policy##
	If ($setALLOVRP -or $CanadaOnly -and !$USOnly -and !$EastOnly -and !$WestOnly)
		{
		Write-Host "Setting Canada Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageCanada","$pstnUsageUSWEST","$pstnUsageUSEast
		Do
			{
			Write-Host "." -nonewline
			New-CsOnlineVoiceRoutingPolicy -Identity "Canada" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageCanada,$pstnUsageUSWEST,$pstnUsageUSEast -ErrorAction SilentlyContinue
			
			$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "Canada" -ErrorAction SilentlyContinue
			Start-Sleep 2
			}
		Until ($checkOVRP) 
		Write-Host "."
		}
	##Create Us West Unrestricted Policy##
	If ($setALLOVRP -or $WestOnly -or $USOnly -and !$EastOnly -and !$CanadaOnly)
	{
	Write-Host "Setting US West Unrestricted Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageUSWESTUnrestricted","$pstnUsageUSEastUnrestricted","$pstnUsageCanadaUnrestricted
	Do
		{
		Write-Host "." -nonewline
		New-CsOnlineVoiceRoutingPolicy -Identity "US West Unrestricted" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageUSWESTUnrestricted,$pstnUsageUSEastUnrestricted,$pstnUsageCanadaUnrestricted -ErrorAction SilentlyContinue
		
		$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "US West Unrestricted" -ErrorAction SilentlyContinue
		Start-Sleep 2
		}
	Until ($checkOVRP) 
	Write-Host "."
	}
	##Create Us East Unrestricted Policy##
	If ($setALLOVRP -or $EastOnly -or $USOnly -and !$WestOnly -and !$CanadaOnly)
	{
	Write-Host "Setting US East Unrestricted Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageUSEastUnrestricted","$pstnUsageUSWESTUnrestricted","$pstnUsageCanadaUnrestricted
	Do
		{
		Write-Host "." -nonewline
		New-CsOnlineVoiceRoutingPolicy -Identity "US East Unrestricted" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageUSEastUnrestricted,$pstnUsageUSWESTUnrestricted,$pstnUsageCanadaUnrestricted -ErrorAction SilentlyContinue
		
		$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "US East Unrestricted" -ErrorAction SilentlyContinue
		Start-Sleep 2
		}
	Until ($checkOVRP) 
	Write-Host "."
	}
	##Create Canada Unrestricted Policy##
	If ($setALLOVRP -or $CanadaOnly -and !$USOnly -and !$EastOnly -and !$WestOnly)
	{
	Write-Host "Setting Canada Unrestricted Voice Policy with usages:" $pstnUsageEmergency","$pstnUsageCanadaUnrestricted","$pstnUsageUSWESTUnrestricted","$pstnUsageUSEastUnrestricted
	Do
		{
		Write-Host "." -nonewline
		New-CsOnlineVoiceRoutingPolicy -Identity "Canada Unrestricted" -OnlinePstnUsages $pstnUsageEmergency,$pstnUsageCanadaUnrestricted,$pstnUsageUSWESTUnrestricted,$pstnUsageUSEastUnrestricted -ErrorAction SilentlyContinue
		
		$checkOVRP = Get-CsOnlineVoiceRoutingPolicy -Identity "Canada" -ErrorAction SilentlyContinue
		Start-Sleep 2
		}
	Until ($checkOVRP) 
	Write-Host "."
	}		
	}