# Title: HP switch configuration #
#               backup           #
#                                #
#     Author: Tencharmin         # 
#                                # 
# Read the commentary at the end #  
##################################   

Write-Output "Initialising"
$day = Get-Date -Format "dd_MM_yyyy"
$month = Get-Date -Format "MM_yyyy"
$year = Get-Date -Format "yyyy"
$tftp_server = "Server IP"
$switches_array = "IP1", "IP2", "IP3", "IP4"

#########################################################################################################

$Key = Get-Content "localisation\3c6e0b8a9c15224a8228b9a98ca1531d" 
$SEC_User_File = Get-Content "localisation\ee11cbb19052e40b07aac0ca060c23ee"
$SEC_Password_File = Get-Content "localisation\\5f4dcc3b5aa765d61d8327deb882cf99" 

$SEC_User = ConvertTo-SecureString $SEC_User_File -Key $Key
$SEC_Password = ConvertTo-SecureString $SEC_Password_File -Key $Key

$PSSTB = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SEC_Password)
$USSTB = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SEC_User)

$User = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($USSTB)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($PSSTB)

$swcreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $SEC_Password
#mail_cred = use the same method as above but with different variables

#########################################################################################################

function Directories
{
    Get-Item "localisation\$year\" -ErrorAction SilentlyContinue
    if (!$?)
    {
        New-Item "localisation\$year\" -ItemType Directory
    }
    Get-Item "localisation\$year\$month\" -ErrorAction SilentlyContinue
    if (!$?)
    {
        New-Item "localisation\$year\$month\" -ItemType Directory
    }
    Get-Item "localisation\$year\$month\$day\" -ErrorAction SilentlyContinue
    if (!$?)
    {
        New-Item "localisation\$year\$month\$day\" -ItemType Directory
    }
}

#########################################################################################################

function Backupium
{
    foreach ($switch in $switches_array)
    {
        Get-Item "localisation\$year\$month\$day\$switch" -ErrorAction SilentlyContinue
        if (!$?)
        {
            New-Item "localisation\$year\$month\$day\$switch" -ItemType Directory
        }
        $path = "\$year\$month\$day\$switch\"
        $startupConfig = "sc_" + $switch
        $runningConfig = "rc_" + $switch
        New-SSHSession "$switch" -Port 22 -Credential $swcreds
        sleep 2
        $SSHStream = New-SSHShellStream -Index 0
        sleep 2
        #$SSHStream.WriteLine("$User") #For some switches
        #$SSHStream.WriteLine("$Password") #it's necessary
        #$SSHStream.WriteLine("en") #to do it like this
        Sleep 3
        $SSHStream.WriteLine("copy startup-config tftp $tftp_server $path$startupConfig")
        Sleep 3
        $SSHStream.WriteLine("copy startup-config tftp $tftp_server $path$runningConfig")
        sleep 5
        Remove-SSHSession -SessionId 0 #lancer cettte comande apres les test
	}
}

#########################################################################################################

function Repeat
{
    Write-Output "Repeating"
    foreach ($switch in $switches_array)
    {
        $startup = "sc_" + $switch
        $running = "rc_" + $switch
        Get-Item "localisation\$year\$month\$day\$switch\$running" -ErrorAction SilentlyContinue
        if(!$?)
        {
            Write-Output "File not existing"
            $path = "\$year\$month\$day\$switch\"
            $startupConfig = "sc_" + $switch
            $runningConfig = "rc_" + $switch
            New-SSHSession "$switch" -Port 22 -Credential $swcreds
            sleep 2
            $SSHStream = New-SSHShellStream -Index 0
            sleep 2
            $SSHStream.WriteLine("en")
            Sleep 3
            $SSHStream.WriteLine("copy startup-config tftp $tftp_server $path$startupConfig")
            Sleep 3
            $SSHStream.WriteLine("copy startup-config tftp $tftp_server $path$runningConfig")
            sleep 5
            Remove-SSHSession -SessionId 0
	    }
    }
}

#########################################################################################################

function Check
{
    Write-Output "Checking"
    foreach ($switch in $switches_array)
    {
        $runres = 0
        $startres = 0
        $startup = "sc_" + $switch
        $running = "rc_" + $switch
        Get-Item "localisation\$year\$month\$day\$switch\$running" -ErrorAction SilentlyContinue
        if (!$?)
        {
            Write-Output "NOK"
            $runres = 0
        }
        else
        {
            Write-Output "OK"
            $runres = 1
        }
        Get-Item "localisation\$year\$month\$day\$switch\$startup" -ErrorAction SilentlyContinue
        if (!$?)
        {
            $startres = 0
        }
        else
        {
            $startres = 1 
        }
        if(($runres -eq 0) -and ($startres -eq 0))
        {
            "$switch Running:NOK Startup:NOK" | Add-Content "loglocalisation\IntegrityCheck $(get-date -f yyyy-MM-dd).txt"
        }
        if(($runres -eq 0) -and ($startres -eq 1))
        {
            "$switch Running:NOK Startup:OK" | Add-Content "loglocalisation\IntegrityCheck $(get-date -f yyyy-MM-dd).txt"
        }
        if(($runres -eq 1) -and ($startres -eq 0))
        {
            "$switch Running:OK Startup:NOK" | Add-Content "loglocalisation\IntegrityCheck $(get-date -f yyyy-MM-dd).txt"
        }
        if(($runres -eq 1) -and ($startres -eq 1))
        {
            "$switch Running:OK Startup:OK" | Add-Content "loglocalisation\IntegrityCheck $(get-date -f yyyy-MM-dd).txt"
        }
    }
}

#########################################################################################################

Directories
sleep 1
Backupium
sleep 1
$i = 0
while($i -ne 5)
{
    Repeat
    Sleep 1
    $i++
}
Check

#########################################################################################################

#Directories function is for creating backup folders arranged by year, month and day
#There is a function which get the key and decrypt the password and user so check the directories for those
#Backupium function if for connecting to the switches and backup their configuration so put correct IPs into the switch and server variables
#Repeat function check missing files when the backup goes wrong (there may issues sometimes) and tries to backup it again.
#Check function check th emissing files and create a log file you can add a sendmail function or integrate the log to PRTG
#Send-MailMessage -From "mail" -To "mail" -Subject "Switch backup results" -Body "Results in the attachement" -Attachments "loglocalisation\IntegrityCheck $(get-date -f yyyy-MM-dd).txt"  -Priority High -dno None -UseSsl -SmtpServer <server> -Port 587 -Credential <Create a user/password files for smtp with HidePass.ps1>



