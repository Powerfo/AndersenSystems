Function Enable-MyTeamsUsers
	{
	<#
		.SYNOPSIS
			Script for managing phone number assignments in Microsoft Teams, utilizing a CSV list (See Template that should have come with the script for this function).
			- Enable Teams Users for Enterprise Voice and set phone numbers for Direct Routing (Assumes Direct Routing has already been established on your tenant and that you are connected using Connect-MicrosoftTeams for the tenant before use).
			- Update Azure Active Directory phone number listing for users (Assumes you are connected using Connect-MSOLService to the tenant before use and that DIRSYNC field is set to FALSE in the CSV data).
			- Update on premise Active Directory phone number listing for users (Assumes you are running this script from the on premise Active Directory Domain Controller, DIRSYNC field is set to TRUE, and you have populated the 'samaccountname' column of the spreadsheet).
			- Check Accounts (The switch -CheckAccounts can be used with any of the above options in order to run a check before attempting to make any changes to the accounts in the CSV template.)
		.DESCRIPTION
		.PARAMETER importfile
			This parameter is for the FULL file path to the CSV.
		.PARAMETER CheckAccounts
			This parameter "switch" should be used when you want to check the account status without pushing any changes.
		.PARAMETER AssignAADPhoneNumberAndExtension
		.PARAMETER AssignOnPremADPhoneNumber
		.PARAMETER LogTranscript
		.EXAMPLE
		.EXAMPLE
		.EXAMPLE
		.INPUTS
			String - importfile
			Switch - CheckAccounts, AssignAADPhoneNumberAndExtension, AssignOnPremADPhoneNumber, LogTranscript
		.NOTES
			Author: Chris Andersen
			Disclaimer: **FOR USE BY AUTHORIZED PARTNERS THAT HAVE BEEN GIVEN EXPLICIT CONSENT OF USE**

	#>

	param([string] $importfile = $(Read-Host -prompt "Please enter the full file path to the CSV file for this user batch"),[switch]$CheckAccounts,[switch]$AssignAADPhoneNumberAndExtension,[switch]$AssignOnPremADPhoneNumber,[switch]$LogTranscript)

	Write-Host "**Reminder**" -NoNewline -ForegroundColor Yellow
	Write-Host ' All User accounts must be licenced for "Microsoft Office 365 Phone System" to be EV enabled and assigned a Phone Number.'
	Read-Host "Press Enter to Continue..."
		
	$importedusers = Import-CSV $importfile

	if ($LogTranscript)
		{
		$transcriptname = "TeamsBulkUsersEnablementLogs" + `
			(Get-Date -format s).Replace(":","-") +".txt"

		Start-Transcript $transcriptname
		}
	if ($checkaccounts -and !$AssignAADPhoneNumberAndExtension -and !$AssignOnPremADPhoneNumber)
		{
		foreach ($user in $importedusers)
			{
			if ($user.Type -ne "Skip" -and $user.Type -ne "Extra")
				{
				Write-Host "Searching for User >> " -NoNewLine
                Write-Host $user.UPN -ForegroundColor Cyan
                #Lookup if User Account Exists
				$checkUser = Get-CsOnlineUser -Identity $user.UPN -ErrorAction SilentlyContinue
				if ($checkUser)
					{
					Write-Host "Found User " -NoNewLine -ForegroundColor Green
                    Write-Host $checkUser.DisplayName -NoNewLine -ForegroundColor Cyan
                    Write-Host " with Sip Address " -NoNewLine -ForegroundColor Green
                    Write-Host $checkUser.SipAddress -ForegroundColor Cyan
                    #Check Licensing
					if ($checkUser.VoicePolicy -eq "HybridVoice" -or $checkUser.AssignedPlan.Capability -match "MCOEV")
						{
						Write-Host $checkUser.DisplayName -NoNewline -ForegroundColor Cyan 
						Write-Host " is licenced for Microsoft Phone System." -ForegroundColor Green
						}
					elseif ($checkUser.VoicePolicy -eq "BusinessVoice")
						{
						Write-Host $checkUser.DisplayName -NoNewline -ForegroundColor Cyan
						Write-Host " is licenced for Microsoft Business Voice. Remove Business Voice before enabling account for Direct Routing." -ForegroundColor Yellow
						}
					else
						{
						Write-Host "*** " -NoNewline -ForegroundColor Red
						Write-Host $checkUser.DisplayName -NoNewline -ForegroundColor Cyan
						Write-Host " is not licensed for Microsoft O365 Phone System.***" -ForegroundColor Red
						}
					#Check if EV enabled
					if ($checkUser.EnterpriseVoiceEnabled -eq $true)
						{
						Write-Host $checkUser.DisplayName -NoNewline -ForegroundColor Cyan 
						Write-Host " is Enabled for Microsoft Teams Enterprise Voice." -ForegroundColor Green
						}
					else
						{
						Write-Host "*** " -NoNewline -ForegroundColor Red
						Write-Host $checkUser.DisplayName -NoNewline -ForegroundColor Cyan
						Write-Host " is NOT ENABLED for Microsoft Teams Enterprise Voice.***" -ForegroundColor Red
						}
                    #Check Phone Number
                    if (!$($checkUser.LineURI) -and $($user.PhoneNumber))
                        {
                            Write-Host "No current Direct Routing Phone Number assigned, " -NoNewLine -ForegroundColor Yellow
                            Write-Host "tel:+1$($user.PhoneNumber)" -NoNewLine -ForegroundColor Cyan
                            Write-Host " will be assigned per datasheet." -ForegroundColor Yellow
                        }
					elseif (!$($checkUser.LineURI) -and !$($user.PhoneNumber))
						{
							Write-Host "No current Direct Routing Phone Number assigned, " -NoNewLine -ForegroundColor Yellow
							#Write-Host "tel:+1$($user.PhoneNumber)" -NoNewLine -ForegroundColor Cyan
							Write-Host "and NO NUMBER will be assigned per datasheet." -ForegroundColor Yellow
						}
                    elseif ($($checkUser.LineURI.replace("tel:+1","") -eq $($user.PhoneNumber)))
                        {
                            Write-Host "User " -nonewline -ForegroundColor Green
                            Write-Host $checkUser.DisplayName -nonewline -ForegroundColor Cyan
                            Write-Host " assigned phone number matches the number provided. Assigned Number >> " -nonewline -ForegroundColor Green
                            Write-Host "$($checkUser.LineURI)" -ForegroundColor Cyan
                        }
                    elseif ($checkUser.LineURI -and ($($checkUser.LineURI.replace("tel:+1","") -ne $($user.PhoneNumber))))
                        {
                            Write-Host "User " -nonewline -ForegroundColor Red
                            Write-Host $checkUser.DisplayName -nonewline -ForegroundColor Cyan
                            Write-Host " assigned phone number DOES NOT MATCH the number provided." -ForegroundColor Red
                            Write-Host "Assigned Number >> " -nonewline -ForegroundColor Red
                            Write-Host "$($checkUser.LineURI)" -ForegroundColor Cyan
                            Write-Host "Provided Number >> " -nonewline -ForegroundColor Red
                            Write-Host "tel:+1$($user.PhoneNumber)" -ForegroundColor Cyan
                        }
					#Check Voice Route Policy
					#Check Caller ID Policy
					If (!$user.CLID -and !$checkUser.CallingLineIdentity)
						{
							Write-Host "User " -nonewline -ForegroundColor Green
							Write-Host $checkUser.DisplayName -nonewline -ForegroundColor Cyan
							Write-Host " is using Global Caller ID Settings, and will not be modified." -nonewline -ForegroundColor Green
						}
					elseif ($user.CLID -and !$checkUser.CallingLineIdentity)
						{
							Write-Host "No current Caller ID Policy assigned, " -NoNewLine -ForegroundColor Yellow
                            Write-Host $user.CLID -NoNewLine -ForegroundColor Cyan
                            Write-Host " will be assigned per datasheet." -ForegroundColor Yellow
						}
					#elseif (){}
					#Check Dial Plan

					}
				else
					{
					Write-Host "Unable to find " -nonewline -ForegroundColor Red
                    Write-Host $user.UPN -ForegroundColor Cyan
					}
				Write-Host ""
				Write-Host ""
				}
			}
		}
	elseif ($AssignAADPhoneNumberAndExtension)
		{
		foreach ($dataSet in $importedusers)
			{
			if ($dataSet.Type -eq "User" -and $dataSet.DirSync -eq "FALSE" -and $dataSet.ADPhoneNumber -and $dataSet.UPN -and !$CheckAccounts)
				{
				Write-Host "Setting AAD Phone Number for " -NoNewline
				Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
				Write-Host " to " -NoNewline
				Write-Host $dataSet.ADPhoneNumber -ForegroundColor Cyan
				Set-MsolUser -UserPrincipalName $dataSet.UPN -PhoneNumber $dataSet.ADPhoneNumber
				If ($dataSet.MobilePhone)
					{
					Write-Host "Setting AAD Mobile Number for " -NoNewline
					Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " to " -NoNewline
					Write-Host $dataSet.MobilePhone -ForegroundColor Cyan
					Set-MsolUser -UserPrincipalName $dataSet.UPN -MobilePhone $dataSet.MobilePhone
					}
				Else
					{
					Write-Host "No Mobile Number listed for " -NoNewline -ForegroundColor Yellow
					Write-Host $dataSet.UPN -ForegroundColor Cyan
					}
				}
			elseif ($dataSet.Type -eq "User" -and $dataSet.DirSync -eq "FALSE" -and $dataSet.ADPhoneNumber -and $dataSet.UPN -and $CheckAccounts)
				{
				$userData = Get-MsolUser -UserPrincipalName $dataSet.UPN
				If ($userData.PhoneNumber -eq $dataSet.ADPhoneNumber)
					{
					Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " currently has a PhoneNumber of "  -NoNewline -ForegroundColor Green
					Write-Host $userData.PhoneNumber -NoNewline -ForegroundColor Cyan
					Write-Host " *MATCHES SOURCE DATA* " -ForegroundColor Green
					}
				Else
					{
					Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " currently has a PhoneNumber of " -NoNewline -ForegroundColor Red
					Write-host $userData.PhoneNumber -NoNewline -ForegroundColor Yellow
					Write-Host " *NO MATCH W/ SOURCE DATA* " -NoNewline -ForegroundColor Red
					Write-Host $dataSet.ADPhoneNumber -ForegroundColor Cyan
					}
				If ($userData.MobilePhone -eq $dataSet.MobilePhone)
					{
					Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " currently has a MobileNumber of " -NoNewline -ForegroundColor Green
					Write-Host $userData.MobilePhone -NoNewline -ForegroundColor Cyan
					Write-Host " *MATCHES SOURCE DATA* " -ForegroundColor Green
					}
				Else
					{
					Write-Host $dataSet.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " currently has a MobileNumber of " -NoNewline -ForegroundColor Red
					Write-Host $userData.MobilePhone -NoNewline -ForegroundColor Cyan
					Write-Host " *NO MATCH W/ SOURCE DATA* " -NoNewline -ForegroundColor Red
					Write-Host $dataSet.MobilePhone -ForegroundColor Cyan
					}
				}
			}
		If (!$CheckAccounts)
			{
			Write-Host "AAD Phone Number Assignment Completed!!!"
			}
		}
	elseif ($AssignOnPremADPhoneNumber)
		{
		foreach ($user in $importedusers)
			{
			if ($user.Type -eq "User" -and $user.DirSync -eq "TRUE" -and $user.ADPhoneNumber -and $user.SamAccountName -and !$CheckAccounts)
				{
				Write-Host "Setting AD Telephone Number for" $user.SamAccountName "/" $user.UPN "to" $user.ADPhoneNumber
				Set-ADuser -Identity $user.SamAccountName -OfficePhone $user.ADPhoneNumber
				}
			elseif ($user.Type -eq "User" -and $user.DirSync -eq "TRUE" -and $user.ADPhoneNumber -and $user.SamAccountName -and $CheckAccounts)
				{
				$checkOnPremADUser = Get-AdUser -Identity $user.SamAccountName -Properties TelephoneNumber
				Write-Host $user.UPN "/" $user.UPN "currently has a PhoneNumber of" $checkOnPremADUser.TelephoneNumber
				}
			}
		If (!$CheckAccounts) {Write-Host "AD Phone Number Assignment Completed!!!"}
		}
	else
		{
		foreach ($importeduser in $importedusers)
			{	
			if ($importeduser.Type -eq "User")
				{
				#Check for user account
				Write-Host "Searching for User >> " -NoNewLine
                Write-Host $importeduser.UPN -ForegroundColor Cyan
				$user = Get-CsOnlineUser -Identity $importeduser.UPN
				#Compile LineURI
				If (!$importeduser.PhoneNumber)
					{
						$lineURI = $null
					} Else {
						$lineURI = "tel:+1$($importeduser.PhoneNumber)"
					}
				Start-Sleep 1
				if ($user)
					{
					Write-Host "Found account for " -NoNewLine -ForegroundColor Green
                    Write-Host $importeduser.UPN -ForegroundColor Cyan
					Write-Host "Attempting to EV enable " -NoNewLine
                    Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
                    Write-Host " with the phone number " -NoNewLine
                    Write-Host $lineURI -ForegroundColor Cyan
					Set-CsUser -Identity $user.UserPrincipalName -LineURI $lineURI -EnterpriseVoiceEnabled $true -HostedVoiceMail $true
					if ($importeduser.VRP)
						{
						Write-Host "Setting Voice Routing Policy for " -NoNewLine
                        Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
                        Write-Host " to " -NoNewLine
                        Write-Host $importeduser.VRP -ForegroundColor Cyan
						Grant-CsOnlineVoiceRoutingPolicy -Identity $user.UserPrincipalName -PolicyName $importeduser.VRP
						}
					else 
						{
						Write-Host "Setting Voice Routing Policy for " -NoNewLine 
                        Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
                        Write-Host " to Global." 
						$id = (Get-CsOnlineUser -Identity $importeduser.UPN).UserPrincipalName
						Grant-CsOnlineVoiceRoutingPolicy -Identity $id -PolicyName $null
						}
					if ($importeduser.DialPlan)
						{
						Write-Host "Setting Custom Dial Plan for " -NoNewLine
						Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
						Write-Host " to " -NoNewLine
						Write-Host $importeduser.DialPlan -ForegroundColor Cyan
						Grant-CsTenantDialPlan -Identity $user.UserPrincipalName -PolicyName $importeduser.DialPlan
						}
					elseif (!$importeduser.DialPlan -and $user.TenantDialPlan) 
						{
						Write-Host "Setting Dial Plan for " -NoNewLine
						Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
						Write-Host " to " -NoNewLine
						Write-Host "Global." -ForegroundColor Cyan
						Grant-CsTenantDialPlan -Identity $user.UserPrincipalName -PolicyName $null
						}
					if ($importeduser.CLID)
						{
						Write-Host "Setting Calling Line Identity for " -NoNewLine
						Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
						Write-Host " to " -NoNewLine
						Write-Host $importeduser.CLID -ForegroundColor Cyan
						Grant-CsCallingLineIdentity -Identity $user.UserPrincipalName -PolicyName $importeduser.CLID
						}
					elseif (!$importeduser.CLID -and $user.CallingLineIdentity)
						{
						Write-Host "Setting Calling Line Identity for " -NoNewLine
						Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
						Write-Host " to " -NoNewLine
						Write-Host "Global." -ForegroundColor Cyan
						Grant-CsCallingLineIdentity -Identity $user.UserPrincipalName -PolicyName $null
						}
					}
				else 
					{
					Write-Host "User not found, please verify the user name in the list matches the Diplay Name of the account on Office 365." -ForegroundColor Red
					}
				}
			if ($importeduser.Type -eq "Resource")
				{
				#Check for resource account
				Write-Host "Searching for Resource Account >> " -NoNewline 
				Write-Host $importeduser.UPN -ForegroundColor Cyan
				$ra = Get-CsOnlineApplicationInstance -Identity $importeduser.UPN
				Start-Sleep 1
				if ($ra)
					{
					Write-Host "Found Resource Account for " -NoNewline
					Write-Host $importeduser.UPN -ForegroundColor Cyan
					Write-Host "Attempting to set DID for " -NoNewline 
					Write-Host $importeduser.UPN -NoNewline -ForegroundColor Cyan
					Write-Host " with the phone number " -NoNewline 
					Write-Host "+1$($importeduser.PhoneNumber)" -ForegroundColor Cyan
					Write-Host ""
					if (!$checkApproved)
						{
						<#No Longer needed due to new number setup
						Write-Host "*Quick Reminder*" -NoNewline -ForegroundColor Yellow
						Write-Host "Resource account names need to be formatted with the UPN of the resource account, and DIDs should be formatted " -NoNewline
						Write-Host "WITHOUT the tel:+" -NoNewline -ForegroundColor Yellow
						Write-Host " in front of the number."
						$check = Read-Host "Is this formatted correctly in your file?[Y/N]"
						While ($check -ne "Y")
							{
							if ($check -ne "Y")
								{
								if ($check -eq "N") 
									{
									Read-Host "Exiting script so that you can update your spreadsheet... press any key..." 
									break
									}
								$check = Read-Host "Bad Entry! ... Is the phone number formatted correctly in your file?[Y/N]"
								}
							}
						#>
						$checkApproved = $true
						}
					Set-CsOnlineApplicationInstance -Identity $importeduser.UPN -OnpremPhoneNumber "1$($importeduser.PhoneNumber)"
					}
				else 
					{
					Write-Host "Resource Account not found, please verify the UPN in the list matches the UPN of the account on Office 365." -ForegroundColor Red
					}
				$user = Get-CsOnlineUser -Identity $importeduser.UPN
				if ($importeduser.VRP)
					{
					Write-Host "Setting Voice Routing Policy for " -NoNewLine
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to " -NoNewLine
					Write-Host $importeduser.VRP -ForegroundColor Cyan
					Grant-CsOnlineVoiceRoutingPolicy -Identity $user.UserPrincipalName -PolicyName $importeduser.VRP
					}
				else 
					{
					Write-Host "Setting Voice Routing Policy for " -NoNewLine 
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to Global." 
					$id = (Get-CsOnlineUser -Identity $importeduser.UPN).UserPrincipalName
					Grant-CsOnlineVoiceRoutingPolicy -Identity $id -PolicyName $null
					}
				if ($importeduser.DialPlan)
					{
					Write-Host "Setting Custom Dial Plan for " -NoNewLine
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to " -NoNewLine
					Write-Host $importeduser.DialPlan -ForegroundColor Cyan
					Grant-CsTenantDialPlan -Identity $user.UserPrincipalName -PolicyName $importeduser.DialPlan
					}
				elseif (!$importeduser.DialPlan -and $user.TenantDialPlan) 
					{
					Write-Host "Setting Dial Plan for " -NoNewLine
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to " -NoNewLine
					Write-Host "Global." -ForegroundColor Cyan
					Grant-CsTenantDialPlan -Identity $user.UserPrincipalName -PolicyName $null
					}
				if ($importeduser.CLID)
					{
					Write-Host "Setting Calling Line Identity for " -NoNewLine
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to " -NoNewLine
					Write-Host $importeduser.CLID -ForegroundColor Cyan
					Grant-CsCallingLineIdentity -Identity $user.UserPrincipalName -PolicyName $importeduser.CLID
					}
				elseif (!$importeduser.CLID -and $user.CallingLineIdentity)
					{
					Write-Host "Setting Calling Line Identity for " -NoNewLine
					Write-Host $importeduser.UPN -NoNewLine -ForegroundColor Cyan
					Write-Host " to " -NoNewLine
					Write-Host "Global." -ForegroundColor Cyan
					Grant-CsCallingLineIdentity -Identity $user.UserPrincipalName -PolicyName $null
					}

				}
            if ($null)
                {

                }
			}
		}

		
	if ($LogTranscript)
		{
		Stop-Transcript
		}
	}