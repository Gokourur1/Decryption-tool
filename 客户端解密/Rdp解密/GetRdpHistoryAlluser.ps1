function GetRdpHistoryAlluser{
<#
.SYNOPSIS
This script will list all users' RDP Connections History.

#>
$AllUser = Get-WmiObject -Class Win32_UserAccount
foreach($User in $AllUser)
{
	$RegPath = "Registry::HKEY_USERS\"+$User.SID+"\Software\Microsoft\Terminal Server Client\Servers\"
	Write-Host "User:"$User.Name
	Write-Host "SID:"$User.SID
	Write-Host "Status:"$User.Status
	$QueryPath = dir $RegPath -Name -ErrorAction SilentlyContinue
	If(!$?)
	{
		Write-Host "[!]Not logged in"
		Write-Host "[*]Try to load Hive"
		$File = "C:\Documents and Settings\"+$User.Name+"\NTUSER.DAT"
		$Path = "HKEY_USERS\"+$User.SID
		Write-Host "[+]Path:"$Path 
		Write-Host "[+]File:"$File
		Reg load $Path $File
		If(!$?)
		{
			Write-Host "[!]Fail to load Hive"
			Write-Host "[!]No RDP Connections History"
		}
		Else
		{
			$QueryPath = dir $RegPath -Name -ErrorAction SilentlyContinue
			If(!$?)
			{
				Write-Host "[!]No RDP Connections History"
			}
			Else
			{
				foreach($Name in $QueryPath)
				{   
					$User = (Get-ItemProperty -Path $RegPath$Name -ErrorAction Stop).UsernameHint
					Write-Host "Server:"$Name
					Write-Host "User:"$User
				}
			}
			Write-Host "[*]Try to unload Hive"
			Start-Process powershell.exe -WindowStyle Hidden -ArgumentList "Reg unload $Path"		
		}
	}
	foreach($Name in $QueryPath)
	{   
		Try  
		{  
			$User = (Get-ItemProperty -Path $RegPath$Name -ErrorAction Stop).UsernameHint
			Write-Host "Server:"$Name
			Write-Host "User:"$User
		}
		Catch  
		{
			Write-Host "[!]No RDP Connections History"
		}
	}
	Write-Host "----------------------------------"	
}
}
