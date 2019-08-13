# Title: Credentials Encryption  #
#                                #
#     Author: Tencharmin         # 
#                                #   
##################################   

#PRTG Custom script for getting the backup results from previous day and generating an xml so prtg can read it as sensor

$date = (get-date (get-date).addDays(-1) -UFormat "%Y-%m-%d") 
Get-Item "loglocalisation\IntegrityCheck $date.txt" -ErrorAction SilentlyContinue
if (!$?)
{
    $d=1
} 
$content = Get-Content "loglocalisation\IntegrityCheck $date.txt" -ErrorAction SilentlyContinue
function cut {
  param(
    [Parameter(ValueFromPipeline=$True)] [string]$inputobject,
    [string]$delimiter='\s+',
    [string[]]$field
  )

  process {
    if ($field -eq $null) { $inputobject -split $delimiter } else {
      ($inputobject -split $delimiter)[$field] }
  }
}

Write-Output '<?xml version="1.0" encoding="UTF-8"?>'
Write-Output "<prtg>"

foreach($line in $content)
{
    switch($line)
    {
        {($_ -match "Startup:NOK") -and ($_ -match "Running:OK")}{$b=1}
        {($_ -match "Startup:OK") -and ($_ -match "Running:NOK")}{$c=1}
        {($_ -match "Startup:NOK") -and ($_ -match "Running:NOK")}{$d=1}   
        default{$a=1}
    }
}
if($d -eq 1) {$general=3}
elseif($c -eq 1) {$general=2}
elseif($b -eq 1) {$general=1}
else {$general=0} 

Write-Output "<result>"
             "<channel>General</channel>"
             "<value>$general</value>"
             "<ValueLookup>custom.switch.ovl</ValueLookup>"
             "</result>"

foreach($line in $content)
{        
    $ip = $line | cut -f 0 -delimiter " "
    switch($line)
    {
        {($_ -match "Startup:NOK") -and ($_ -match "Running:OK")}
        {       
            Write-Output "<result>"
                         "<channel>$ip</channel>"
                         "<value>1</value>"
                         "<ValueLookup>custom.switch.ovl</ValueLookup>"
                         "</result>"
        }
        {($_ -match "Startup:OK") -and ($_ -match "Running:NOK")}
        {
            Write-Output "<result>"
                         "<channel>$ip</channel>"
                         "<value>2</value>"
                         "<ValueLookup>custom.switch.ovl</ValueLookup>"
                         "</result>"
        }
        {($_ -match "Startup:NOK") -and ($_ -match "Running:NOK")}
        {
            Write-Output "<result>"
                         "<channel>$ip</channel>"
                         "<value>3</value>"
                         "<ValueLookup>custom.switch.ovl</ValueLookup>"
                         "</result>"
        }   
        default
        {
            Write-Output "<result>"
                         "<channel>$ip</channel>"
                         "<value>0</value>"
                         "<ValueLookup>custom.switch.ovl</ValueLookup>"
                         "</result>"
        }
    }
}
Write-output "</prtg>"
