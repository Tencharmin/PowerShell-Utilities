# Title: Password changer        #
#                                #
#     Author: Tencharmin         # 
#                                #   
##################################  

#Changes local password for local users of the machine which is connected to a domain
#Use HidePass.ps1 to generate secure credentials

$Key = Get-Content "key location" 
$SEC_User_File = Get-Content "user location"
$SEC_Password_File = Get-Content "password location" 

$SEC_User = ConvertTo-SecureString $SEC_User_File -Key $Key
$SEC_Password = ConvertTo-SecureString $SEC_Password_File -Key $Key

$USSTB = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SEC_User)
$User = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($USSTB)

Set-LocalUser -Name $User -Password $SEC_Password