##Change the Name on your Powershell Window
Function Set-SessionTitle
	{
	param([string]$NewTitle)
	if (!$NewTitle)
		{
		$NewTitle = Read-Host "What would you like to change the PS Session Window Title to?"
		}
	$host.ui.RawUI.WindowTitle = $NewTitle
	}