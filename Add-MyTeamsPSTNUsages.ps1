Function Add-MyTeamsPSTNUsages
	{
		param([switch]$WestPrimary,[switch]$EastPrimary,[switch]$CanadaPrimary)
		if ($WestPrimary)
			{
				Set-CsOnlinePstnUsage -Usage @{Add="Emergency","US West","US East","Canada","US West Unrestricted","US East Unrestricted","Canada Unrestricted"}
			}
		elseif ($EastPrimary)
			{
				Set-CsOnlinePstnUsage -Usage @{Add="Emergency","US East","US West","Canada","US West Unrestricted","US East Unrestricted","Canada Unrestricted"}
			}
		elseif ($CanadaPrimary)
			{
				Set-CsOnlinePstnUsage -Usage @{Add="Emergency","Canada","US West","US East","US West Unrestricted","US East Unrestricted","Canada Unrestricted"}
			}
		else 
			{
				Set-CsOnlinePstnUsage -Usage @{Add="Emergency","US West","US East","Canada","US West Unrestricted","US East Unrestricted","Canada Unrestricted"}
			}
		$datacheck = Get-CsOnlinePstnUsage
		$datacheck
	}