#    Title: Security Suite    #
#                             #
#    Author: Tencharmin       #
#                             #
###############################
Import-Module ServerManager

$servicelist = "AXInstSV", "bthserv", "CDPUserSvc", "upnphost", "PimIndexMaintenanceSvc", "dmwappushservice", "MapsBroker", "lfsvc", "SharedAccess", "lltdsvc", "wlidsvc", "AppVClient",  "NgcSvc", "NgcCtnrSvc", "NetTcpPortSharing", "NcbService", "CscService" , "PhoneSvc", "PrintNotify", "PcaSvc", "QWAVE", "RmSvc", "SensorDataService", "SensrSvc", "SensorService", "ShellHWDetection", "SCardSvr", "ScDeviceEnum", "SSDPSRV", "WiaRpc", "OneSyncSvc", "TabletInputService", "UserDataSvc", "UnistoreSvc", "UevAgentService", "WalletService", "Audiosrv", "AudioEndpointBuilder", "FrameServer", "stisvc", "wisvc", "icssvc", "WpnService", "WpnUserService", "WSearch", "XblAuthManager", "XblGameSave"

function Script-Menu
{
    param ( [String]$Title = "Usefull Toolbox" )
    Clear-Host
    Write-Output "################ $Title ################"
    Write-Output "# Press '1' for Services menu                   #"
    Write-Output "# Press '2' for Firewall menu                   #"
    Write-Output "# Press '3' for Policy menu (trial)             #"
    Write-Output "# Press 'Q' to quit                             #"
    Write-Output "#################################################"
}

function Services-Menu
{
    Clear-Host
    Write-Output "################ Services Menu ################"
    Write-Output "Press '1' to see unecessary services list"
    Write-Output "Press '2' to disable unecessary services (Default)"
    Write-Output "Press '3' to restore unecessary services (If something goes wrong)"
    Write-Output "Press '4' to enable/disable services manually (Options)"
    Write-Output "Press '5' to set up SNMP services"
    Write-Output "Press 'Q' to go back"
}

function Firewall-Menu
{
    Clear-Host
    Write-Output "################ Firewall Menu ################"
    
    Write-Output "Press '1' to see what will be blocked"    
    Write-Output "Press '2' to apply firewall rules (Default)"
    Write-Output "Press '3' to restore firewall rules (Remove)"
    Write-Output "Press 'Q' to go back"
}    

function Firewall-Menu
{
    Clear-Host
    Write-Output "################ Policy Menu (ANSII) ################"
    
    Write-Output "Press '1' to increase logging size"    
    Write-Output "Press '2' to apply auditing policy"
    Write-Output "Press '3' hu hu ha"
    Write-Output "Press 'Q' to go back"
}
    
function Animation
{
    $animation = @("|","/","-","\","|") 
    $i = 0
    do
    {
        foreach ($item in $animation) 
        {
            Write-Host ("$item" * $i + "`b" * $i) -NoNewline        
            Start-Sleep -m 50
            $i++ 
        }   
    }
    until ($i -eq 15)
}

function CheckServices
{
    $num=0
    $svc=0
    $choix = 0
    Write-Output "Checking services..."

    foreach ($service in $servicelist)
    {
        $svc=$svc + 1
        Get-Service -Name $service
        $status = Get-Service -Name $service
        if($status.Status -eq 'Running')
        {
            $num=$num + 1
        }
    }
   
    $info1 = "$svc services present from which $num are running"
    Write-Output "$info1"
    $choix = Read-Host "Export results to file? (y | n) "
    if($choix -eq 'y')
    {
        Write-Output "Exporting..."
        $loc = [Environment]::GetFolderPath("Desktop")
        $ress = Get-Service -Name $servicelist | Select Name, DisplayName | Export-Csv -Path "$loc\UnecessaryServiceList.csv" -NoType -UseCulture  
        Write-Output "Service list was saved to Desktop"

    }
    else
    {
        Write-Output "Ok!"

    }
    Write-Output "Done!"

}

function StopServices
{
    Write-Output "Stopping services..."
    foreach ($service in $servicelist)
    {
        $status = Get-Service -Name $service
        if($status.Status -eq 'Running')
        {
            Stop-Service -Name $service -Force

        }
    }
    Write-Output "All services stopped... (almost)"
}

function DisableServices
{
    Write-Output "Disabling services..."
    foreach ($service in $servicelist)
    {
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Write-Output "Done!"
}

function RestoreServices
{
    Write-Output "Restoring services..."
    foreach ($service in $svctodisable)
    {
        Set-Service -Name $service -StartupType Manual
    }
    Write-Output "Done!"
}   

function ManualServiceRestore
{
    Write-Output "If you are there something important isn't working (or you are just wandering trought the program).`nIn this step enable or disable any service.`nFirst choose services and in the next step you can choose to whatever enable or disable them`nPS: For service names, use one at a time separated by a comma (Ex: Service1, Service2, ect...)"
    $wybor = Read-Host "Enable, disable or quit?"
    :serv switch($wybor)
    {
       'enable'
       {
           $servicerelist = Read-Host "Services names"
           $servicerelist = $servicerelist.replace(' ','')
           $servicerelist = $servicerelist.split(',')
    
           foreach ($service in $servicerelist)
           {
                Set-Service -Name $service -StartupType Manual
                Start-Service -Name $service 
                $state = Get-Service -Name $service
                if($state.Status -eq 'Running')
                {
                    Write-Output "$service is running!"
                }
                else
                {
                    Write-Output "Oups! $service is still not running"
                }
           }
       }
       'disable'
       {
           $servicerelist = Read-Host "Services names"
           $servicerelist = $servicerelist.replace(' ','')
           $servicerelist = $servicerelist.split(',')
           foreach ($service in $servicerelist)
           {
                Set-Service -Name $service -StartupType Disabled
                Stop-Service -Name $service 
                $state = Get-Service -Name $service
                if($state.Status -eq 'Stopped')
                {
                    Write-Output "$service was stopped!"
                }
                else
                {
                    Write-Output "Oups! $service is still running"
                }
           }
        }
        'quit'
        {
           Write-Output "Quitting"
           break serv
        }
        default
        {
           Write-Output "Make a valid choice..."
        }   
    } 
    Write-Output "Done!"     
}

function FirewallList
{
    Write-Output "BY DEFAULT"
    Write-Output "TCP Inbound ports will be blocked except:`n3389, 7273, 9119"
    Write-Output "TCP Outbound ports will be blocked except:`n25, 135, 238, 389, 443, 587, 1433-1434, 2383, 3389, 9119, 9389"
    Write-Output "UDP Inbound ports will be blocked except:`n3389, 7273, 9119"
    Write-Output "UDP Outbound ports will be blocked except:`n53, 67, 123, 389, 1434, 3389, 5355"
    Write-Output "ICMP Inbound requests will be dropped:`n53, 67, 123, 389, 1434, 3389, 5355"
    Write-Output "Done!"
}

function FirewallRulesDefault
{
    New-NetFirewallRule -DisplayName "TCP In Block" -Direction Inbound -Protocol TCP -Action Block -LocalPort 1-3388, 3390-7272, 7274-9118, 9120-65535 -RemotePort 1-3388, 3390-7272, 7274-9118, 9120-65535
    #New-NetFirewallRule -DisplayName "TCP Out Block" -Direction Outbound -Protocol TCP -Action Block -LocalPort 1-24, 26-79, 81-134, 136-237, 239-388, 390-442, 444-586, 588-1432, 1435-2382, 2384-3388, 3390-9118, 9120-9388, 9390-65535 -RemotePort 1-24, 26-79, 81-134, 136-237, 239-388, 390-442, 444-586, 588-1432, 1435-2382, 2384-3388, 3390-9118, 9120-9388, 9390-65535

    #New-NetFirewallRule -DisplayName "UDP In Block" -Direction Inbound -Protocol UDP -Action Block -LocalPort 1-160, 163-3388, 3390-7272, 7274-9118, 9120-65535 -RemotePort 1-160, 163-3388, 3390-7272, 7274-9118, 9120-65535
    #New-NetFirewallRule -DisplayName "UDP Out Block" -Direction Outbound -Protocol UDP -Action Block -LocalPort 1-52, 54-66, 69-122, 124-160, 163-388, 390-1433, 1435-3388, 3390-5354, 5356-65535 -RemotePort 1-52, 54-66, 69-122, 124-160, 163-388, 390-1433, 1435-3388, 3390-5354, 5356-65535
    
    #New-NetFirewallRule -DisplayName "ICMP In Block" -Direction Inbound -Protocol ICMPv4 -Action Block -IcmpType Any

    Write-Output "Done!"
}

function RestoreFirewall
{
    Remove-NetFirewallRule -DisplayName "TCP In Block" 
    Remove-NetFirewallRule -DisplayName "TCP Out Block" 
    Remove-NetFirewallRule -DisplayName "UDP In Block" 
    Remove-NetFirewallRule -DisplayName "UDP Out Block"  
    Remove-NetFirewallRule -DisplayName "ICMP In Block" 
    Write-Output "Done!"
}

function SNMPService
{
    Write-Output "Checking if SNMP services are installed"
    $snmpsvcheck = Get-WindowsFeature -Name SNMP-Service
    If ($snmpsvcheck.Installed -ne "True") 
    {
        #Install/Enable SNMP-Service
        Write-Host "SNMP Service Installing..."
        Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null
    }

    $snmpsvcheck = Get-WindowsFeature -Name SNMP-Service
    $snmpsvcheck

    If ($snmpsvcheck.Installed -eq "True")
    {
        Write-Host "SNMP Services are installed!"
        Write-Host "Configuring SNMP Services..."
        Write-Host "In this step you can set the probes and communities respect the form with spaces and commas`nEx: Something1, Something2, ect..."

        $hosts = Read-Host "Authorized hosts"
        $hosts = $hosts.replace(' ','')
        $hosts = $hosts.split(',')

        $communities = Read-Host "Communities"
        $communities = $communities.replace(' ','')
        $communities = $communities.split(',')

        $hosts
        $communities
        $choice = Read-Host "Are those informations correct? (y | n)"
        if($choice -eq 'y')
        {
            $x=2
            foreach($probe in $hosts)
            {
                Write-Output $host
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $x /t REG_SZ /d $probe /f | Out-Null
                $x++
            }

            foreach($community in $communities)
            {
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $community /t REG_DWORD /d 4 /f | Out-Null
            }
        }
        else
        {
            Write-Host "Try again..."
        }
    }
}
function JournalSize
{
    $limitSystemLog = @{
      Maximumsize = 200MB
      logname = "System"
      OverflowAction = "OverwriteAsNeeded"
    }
    
    $limitSecurityLog = @{
      Maximumsize = 1000MB
      logname = "Security"
      OverflowAction = "OverwriteAsNeeded"
    }
    
    $limitApplicationLog = @{
      Maximumsize = 200MB
      logname = "Application"
      OverflowAction = "OverwriteAsNeeded"
    }
    
    Write-Host "Setting limits on $($limitSystemLog.logname)"
    Write-Host "Setting limits on $($limitSecurityLog.logname)" 
    Write-Host "Setting limits on $($limitApplicationLog.logname)"
    
    Limit-EventLog @limitSystemLog
    Limit-EventLog @limitSecurityLog 
    Limit-EventLog @limitApplicationLog
    
    Get-Eventlog -list | Where {($_.Log -eq "System") -or ($_.Log -eq "Security") -or ($_.Log -eq "Application")} | Select Log, OverflowAction, MaximumKilobytes, MinimumRetentionDays | FT -AutoSize
}
function AuditPol
{
    auditpol /set /category:"System","Account Management","Account Logon","Logon/Logoff","Policy Change" /failure:enable /success:enable     

}


:mainscript while($mainchoice -ne 'q')
{
    Script-Menu
    $mainchoice = Read-Host "Choose wisely..."
    :menu switch($mainchoice)
    {
        '1'
         {  
            Animation
            :loop1 while(1)
            {
                Services-Menu
                $choice1 = Read-Host "Choose wisely..."
                switch($choice1)
                {
                    '1'
                    {
                        Animation
                        CheckServices
                    }
                    '2'
                    {
                        Write-Output "Magic is happening"
                        Animation
                        StopServices
                        DisableServices

                    }
                    '3'
                    {
                        Write-Output "Magic is happening"
                        Animation
                        RestoreServices
                    }
                    '4'
                    {
                        Animation
                        ManualServiceRestore
                    }
                    '5'
                    {
                        Animation
                        SNMPService
                    }
                    'q'
                    {
                        [System.GC]::Collect()
                        Write-Output "Ok bye \('U_U)"
                        break menu
                    }
                    default
                    {
                        Write-Output "Stop right there! Choose a valid option"
                    }  
                    ''
                    {
                        Write-Output "No options choosen? Am I a joke to you?"
                    }                                      
                }
                pause  
            }
         }
        '2'
         {
            Animation
            :loop2 while(1)
            {
                Firewall-Menu
                $choice2 = Read-Host "Choose wisely..."
                switch($choice2)
                {
                    '1'
                    {
                        Write-Output "Checking for existing firewall rules"
                        FirewallList

                    }
                    '2'
                    {
                        Write-Output "Applying firewall rules"
                        FirewallRulesDefault
                    }
                    '3'
                    {
                        Write-Output "Removing firewall rules"
                        RestoreFirewall
                    }
                    'q'
                    {
                        [System.GC]::Collect()
                        Write-Output "Ok bye \(´U_U)"
                        break menu
                    }
                    default
                    {
                        Write-Output "Stop right there! Choose a valid option"
                    }
                    ''
                    {
                        Write-Output "No options choosen? Am I a joke to you?"
                    }
                }
                pause        
            }
         }
        '3'
         {
            Animation
            :loop3 while(1)
            {
                $choice3 = Read-Host "Choose wisely..."
                switch($choice3)
                {
                    '1'
                    {
                        Write-Output "Changing log size"
                        JournalSize
                    }
                    '2'
                    {
                        Write-Output "Unicorns!"
                        
                    }
                    '3'
                    {
                        Write-Output "Unicorns!"
                        
                    }
                    'q'
                    {
                        [System.GC]::Collect()
                        Write-Output "Ok bye \(´U_U)"
                        break menu
                    }
                    default
                    {
                        Write-Output "Stop right there! Choose a valid option"
                    }
                    ''
                    {
                        Write-Output "No options choosen? Am I a joke to you?"
                    }
                }
                pause
             }        
         }
        'q'
         {
            [System.GC]::Collect()
            return
         }
        default
         {
            Write-Output "Stop right there! Choose a valid option"

         }
        ''
         {
            Write-Output "No options choosen? Am I a joke to you?"
         }
    }
    pause
}