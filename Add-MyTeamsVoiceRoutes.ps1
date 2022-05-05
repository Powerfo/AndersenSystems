Function Add-MyTeamsVoiceRoutes
	{
		param($CustomerTrunkPrefix)
		
		#set variables
		$pstnUsages = $(Get-csOnlinePstnUsage).Usage
		$sbcUSWest = "$CustomerTrunkPrefix.las.myteamsuc.com"
		$sbcUSEast = "$CustomerTrunkPrefix.cjr.myteamsuc.com"
		$sbcCanada = "$CustomerTrunkPrefix.yyz.myteamsuc.com"		
		if (!$CustomerTrunkPrefix)
			{
			$sbcUSWest = "las.myteamsuc.com"
			$sbcUSEast = "cjr.myteamsuc.com"
			$sbcCanada = "yyz.myteamsuc.com"
			}
			
		$preCheckUSWest = Get-CsOnlineVoiceRoute -Identity "US West" -ErrorAction SilentlyContinue
		$preCheckUSEast = Get-CsOnlineVoiceRoute -Identity "US East" -ErrorAction SilentlyContinue
		$preCheckCanada = Get-CsOnlineVoiceRoute -Identity "Canada" -ErrorAction SilentlyContinue		
		$preCheckUSWestUnrestricted = Get-CsOnlineVoiceRoute -Identity "US West Unrestricted" -ErrorAction SilentlyContinue
		$preCheckUSEastUnrestricted = Get-CsOnlineVoiceRoute -Identity "US East Unrestricted" -ErrorAction SilentlyContinue
		$preCheckCanadaUnrestricted = Get-CsOnlineVoiceRoute -Identity "Canada Unrestricted" -ErrorAction SilentlyContinue
		$preCheckEmergency = Get-CsOnlineVoiceRoute -Identity "Emergency" -ErrorAction SilentlyContinue

		if ($pstnUsages.Contains('US West') -and !$preCheckUSWest)
			{
			Write-Host "Setting up US West Voice Routes ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "US West" -NumberPattern "^(\+1[0-9]{10})$" -OnlinePstnUsages "US West" -OnlinePstnGAtewayList $sbcUSWest -ErrorAction SilentlyContinue
				
				$checkWest1 = Get-CsOnlineVoiceRoute -Identity "US West" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkWest1)
			Write-Host "US West Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for US West, or Route already exists for "$sbcUSWest"!"
			}
		if ($pstnUsages.Contains('US East') -and !$preCheckUSEast)
			{
			Write-Host "Setting up US East Voice Route ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "US East" -NumberPattern "^(\+1[0-9]{10})$" -OnlinePstnUsages "US East" -OnlinePstnGAtewayList $sbcUSEast -ErrorAction SilentlyContinue
				
				$checkEast1 = Get-CsOnlineVoiceRoute -Identity "US East" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkEast1)
			Write-Host "US East Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for US East, or Route already exists for "$sbcUSEast"!"
			}
		if ($pstnUsages.Contains('Canada') -and !$preCheckCanada)
			{
			Write-Host "Setting up Canada Voice Route ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "Canada" -NumberPattern "^(\+1[0-9]{10})$" -OnlinePstnUsages "Canada" -OnlinePstnGAtewayList $sbcCanada -ErrorAction SilentlyContinue
				
				$checkCanada1 = Get-CsOnlineVoiceRoute -Identity "Canada" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkCanada1)
			Write-Host "Canada Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for Canada, or Route already exists for "$sbcCanada"!"
			}



		if ($pstnUsages.Contains('US West Unrestricted') -and !$preCheckUSWestUnrestricted)
			{
			Write-Host "Setting up US West Unrestricted Voice Routes ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "US West Unrestricted" -NumberPattern ".*" -OnlinePstnUsages "US West Unrestricted" -OnlinePstnGAtewayList $sbcUSWest -ErrorAction SilentlyContinue
				
				$checkWest1 = Get-CsOnlineVoiceRoute -Identity "US West Unrestricted" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkWest1)
			Write-Host "US West Unrestricted Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for US West Unrestricted, or Route already exists for "$sbcUSWest"!"
			}
		if ($pstnUsages.Contains('US East Unrestricted') -and !$preCheckUSEastUnrestricted)
			{
			Write-Host "Setting up US East Unrestricted Voice Route ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "US East Unrestricted" -NumberPattern ".*" -OnlinePstnUsages "US East Unrestricted" -OnlinePstnGAtewayList $sbcUSEast -ErrorAction SilentlyContinue
				
				$checkEast1 = Get-CsOnlineVoiceRoute -Identity "US East Unrestricted" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkEast1)
			Write-Host "US East Unrestricted Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for US East, or Route already exists for "$sbcUSEast"!"
			}
		if ($pstnUsages.Contains('Canada Unrestricted') -and !$preCheckCanadaUnrestricted)
			{
			Write-Host "Setting up Canada Unrestricted Voice Route ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "Canada Unrestricted" -NumberPattern ".*" -OnlinePstnUsages "Canada Unrestricted" -OnlinePstnGAtewayList $sbcCanada -ErrorAction SilentlyContinue
				
				$checkCanada1 = Get-CsOnlineVoiceRoute -Identity "Canada Unrestricted" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkCanada1)
			Write-Host "Canada Unrestricted Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for Canada Unrestricted, or Route already exists for "$sbcCanada"!"
			}
		if ($pstnUsages.Contains('Emergency') -and !$preCheckEmergency)
			{
			Write-Host "Setting up Emergency Voice Route ..." -NoNewLine
			Do
				{
				Write-Host "." -NoNewLine
				New-CsOnlineVoiceRoute -Name "Emergency" -NumberPattern "^\+?1?911|933$" -OnlinePstnUsages "Emergency" -OnlinePstnGAtewayList $sbcUSWest,$sbcUSEast,$sbcCanada -ErrorAction SilentlyContinue
				
				$checkEmergency1 = Get-CsOnlineVoiceRoute -Identity "Emergency" -ErrorAction SilentlyContinue

				Start-Sleep 2
				}
			Until ($checkEmergency1)
			Write-Host "Emergency Route Complete!"
			}
		else
			{
			Write-Host "Either PSTN usage not found for Emergency, or Route already exists!"
			}
	}