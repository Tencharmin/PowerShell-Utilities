# Title: Credentials Encryption  #
#                                #
#     Author: Tencharmin         # 
#                                #   
##################################   

# Launch each function one at a time
# Decrypt is just for testing purposes
# After you create a key comment the Key generator piece of code <#BOOO#>                        

$DesktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

#Key generator

$KeyFile = "$DesktopPath\3c6e0b8a9c15224a8228b9a98ca1531d"
$Key = New-Object Byte[] 24   # You can use 16, 24, or 32 for AES
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | out-file $KeyFile


#Encrypt

$UserFile = "$DesktopPath\ee11cbb19052e40b07aac0ca060c23ee"
$User = ConvertTo-SecureString "User" -AsPlainText -Force
$User | ConvertFrom-SecureString -key $Key | Out-File $UserFile

$PasswordFile = "$DesktopPath\5f4dcc3b5aa765d61d8327deb882cf99"
$Password = ConvertTo-SecureString "Password" -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile


<#Decrypt

$Key = Get-Content "$DesktopPath\3c6e0b8a9c15224a8228b9a98ca1531d" 
$SEC_User_File = Get-Content "$DesktopPath\ee11cbb19052e40b07aac0ca060c23ee"
$SEC_Password_File = Get-Content "$DesktopPath\5f4dcc3b5aa765d61d8327deb882cf99" 

$SEC_User = ConvertTo-SecureString $SEC_User_File -Key $Key
$SEC_Password = ConvertTo-SecureString $SEC_Password_File -Key $Key

$PSSTB = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SEC_Password)
$USSTB = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SEC_User)

$User = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($USSTB)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($PSSTB)

write-host $User 
write-host $Password #>




