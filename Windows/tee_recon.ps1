function recon {

    $outputFile = "recon_output.txt"

    @"
#####################################################################################################
##												   ##
##                                            LOCAL RECON                                          ##
##												   ##
#####################################################################################################

"@ | Tee-Object -FilePath $outputFile -Append

    $(systeminfo | findstr /c:"Host" /c:"OS Name" /c:"Domain" /c:"Logon" | Tee-Object -FilePath $outputFile -Append)

    @"

=========== LOCAL USERS ===============
"@ | Tee-Object -FilePath $outputFile -Append

    Get-LocalUser | Tee-Object -FilePath $outputFile -Append

    @"
"@ | Tee-Object -FilePath $outputFile -Append

    Get-NetIPAddress | Where-Object { $_.PrefixOrigin -eq 'Manual' -or $_.PrefixOrigin -eq 'Dhcp' } | Select-Object IPAddress, PrefixLength | Format-Table | Tee-Object -FilePath $outputFile -Append

    $(whoami /priv | Tee-Object -FilePath $outputFile -Append)

    $dom = (cmd /c echo %userdomain%)
    @"
DOMAIN: $dom

===========    DOMAIN CONTROLLER    ===========
"@ | Tee-Object -FilePath $outputFile -Append

    $(cmd /c nltest /dsgetdc:ILFREIGHT | findstr /v Site  | findstr /v Flags | findstr /v The | Tee-Object -FilePath $outputFile -Append)
    $(net user /domain | findstr /v The | Tee-Object -FilePath $outputFile -Append)

    @"
===============    Local Shares    ===============
"@ | Tee-Object -FilePath $outputFile -Append

    $(net share | findstr /v The | Tee-Object -FilePath $outputFile -Append)
}

# Call the function
recon
