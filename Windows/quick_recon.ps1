function recon {

Write-Host @"

#####################################################################################################
##												                                                                         ##
##                                            LOCAL RECON                                          ##
##												                                                                         ##
#####################################################################################################

"@
$(systeminfo | findstr /c:"Host" /c:"OS Name" /c:"Domain" /c:"Logon")

Write-Host @'

=========== LOCAL USERS ===============
'@
Get-LocalUser
Write-Host ' '
Get-NetIPAddress | Where-object {$_.PrefixOrigin -eq 'Manual' -or $_.PrefixOrigin -eq 'Dhcp'} | select-object IPAddress, PrefixLength | ft
$(whoami /priv)

$dom=(cmd /c echo %userdomain%)
Write-Host @"

DOMAIN: $dom

===========    DOMAIN CONTROLLER    ===========

"@
$(cmd /c nltest /dsgetdc:ILFREIGHT | findstr /v Site  | findstr /v Flags | findstr /v The)
$(net user /domain | findstr /v The)
Write-Host @"

===============    Local Shares    ===============

"@
$(net share | findstr /v The)
}
