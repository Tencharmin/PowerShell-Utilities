# PowerShell utility scripts


Hello, I'm kinda fresh to PowerShell but you need to start somewhere so I made few usefull scripts which help us at work for doing (variety) of stuff

So here is a little readme for each script:

BackupConfSwitch - Backup the startup and running config via SSH \ FTP of HP switches (may work on other equipements) - You need to install PoshSSH powershell module for it to work - You need to install tftpd server - There are commentaries in the script to make it easier to understand - You need to configure it yourself (Server IP, IP devices, Paths for files and stuff... )

HidePass - A little script which encrypts the user / password so it's not visible - Require a little configuration

ChangeLocalAdminPassword - Script which changes the password of an local machine user (Even when connected to domain) - Use with GPO scheduled task

SNMP - Check and install SNMP Service - Read the commentaries to understand - Use with GPO scheduled task

SNMP Community - Changes an existing community to another one or add some - Use with GPO scheduled task

SwitchBackupXML - As an Paessler PRTG expert I made a little script which can read the result logs from BackupConfSwitch script and show them in PRTG as a sensor - Read the commentary

SecSuite - Interactive script for security puproses still in BETA

xlstocsv - Simply converts xlsx files into CSV with proper formatting

Note: For GPO scheduled task use NT AUTHORITY\SYSTEM account and for the powershell arguments use -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden
