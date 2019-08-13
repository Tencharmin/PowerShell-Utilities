#    Title: XLS to CSV        #
#                             #
#    Author: Tencharmin       #
#                             #
###############################

#Use with -xls "file" as parameter <without .xlsx>

Param([Parameter(Mandatory=$True)][string]$xls)
Function Export
{
    $csvLoc = ($pwd).path
    $excelFile = $csvLoc  + "\" + $xls + ".xlsx"
    $convert = New-Object -ComObject Excel.Application
    $convert.Visible = $false
    $convert.DisplayAlerts = $false
    $csvlist = $convert.Workbooks.Open($excelFile)
    foreach ($csv in $csvlist.Worksheets)
    {
        $csvfile = $xls + "_" + $csv.Name
        $csv.SaveAs($csvLoc + "\" + $csvfile + ".csv", 6)
    } 
    $convert.Quit()#>
}
Export 