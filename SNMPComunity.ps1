# Title: SNMP Comunity Edit      #
#                                #
#     Author: Tencharmin         # 
#                                #   
##################################  

#Removes old communities and put new one, usefull with scheduled task GPO

function SNMPComunity
{
    $snmpsvcheck = Get-WindowsFeature -Name SNMP-Service
    If ($snmpsvcheck.Installed -eq "True")
    {
        Write-Host "Configuring SNMP Services..."
        $communities = "SetOne" #change here
        foreach($community in $communities)
        {
            reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $community /t REG_DWORD /d 4 /f | Out-Null
        }
            reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v "PUBLIC" /f | Out-Null
    }
    else 
    {
        Write-Host "Snmp Service not installed"
    }
}
SNMPComunity