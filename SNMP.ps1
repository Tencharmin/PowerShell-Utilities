# Title: SNMP Service Install    #
#                                #
#     Author: Tencharmin         # 
#                                #   
##################################  

#Pretty usefull when making a GPO to deploy SNMP 
#Use as scheduled task localisation\script.ps1 -Probes "IP1, IP2, IP3"


Param([Parameter(Mandatory=$True)][string]$Probes)
function SNMPService
{

    Write-Output "Checking if SNMP services are installed"
    $snmpsvcheck = Get-WindowsFeature -Name SNMP-Service
    If ($snmpsvcheck.Installed -ne "True") 
    {
        Write-Host "SNMP Service Installing..."
        Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null
    }
    else
    {
        Write-Output "SNMP Service is already installed" 
    }

    $snmpsvcheck = Get-WindowsFeature -Name SNMP-Service

    If ($snmpsvcheck.Installed -eq "True")
    {
        Write-Host "Configuring SNMP Services..."

        $Probes = $Probes.replace(' ','')
        $Probes = $Probes.split(',')
        $communities = "SetOne" #change here
        $x = 2
        foreach($probe in $Probes)
        {
            Write-Output $probe
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $x /t REG_SZ /d $probe /f | Out-Null
            $x++
        }
        foreach($community in $communities)
        {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $community /t REG_DWORD /d 4 /f | Out-Null
        }
    }
}
SNMPService