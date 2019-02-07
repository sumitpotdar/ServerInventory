<#
File Name  : get-server-info.ps1
DESCRIPTION :This script will get the Servers List With Installed Features.
Author: Sumit Potdar
#>


Import-Module ActiveDirectory

$DataTable = New-Object System.Data.DataTable
$DataTable.Columns.Add("ServerName","string") | Out-Null
$DataTable.Columns.Add("OperatingSystem","string") | Out-Null


$Servers = Get-ADComputer -Filter {(OperatingSystem -like "*windows*server*") -and (Enabled -eq "True")} -Properties OperatingSystem


[Int]$ServerCount = $Servers.Count
[Int]$ServerProgressCount = '0'

foreach ($Server in $Servers)
{
    
    $ServerProgressCount++
    Write-Progress -Activity "Inventorying Server" -Id 1 -Status "$($ServerProgressCount) / $($ServerCount)" -CurrentOperation "$($Server.DNSHostName)" -PercentComplete (($ServerProgressCount / $ServerCount) * 100)

    
    Write-Host "Testing Connection to $($Server.DNSHostName)" -ForegroundColor White
    $TestConnection = Test-Connection -Count 2 -ComputerName $Server.DNSHostName -ErrorAction SilentlyContinue
    if (!($TestConnection))
    {
        Write-Host "Cannot contact $($Server.DNSHostName)" -ForegroundColor Red
        Continue
    }
    Write-Host "Successfully connected to $($Server.DNSHostName)" -ForegroundColor Green

    
    Write-Host "Gathering Installed Feature Data from $($Server.DNSHostName) Please wait.." -ForegroundColor White
    $Features = (Get-WindowsFeature -ComputerName $Server.DNSHostName | Where-Object Installed).Name

    
    foreach ($Feature in $Features)
    {
        if ($DataTable.Columns.ColumnName -notcontains $Feature)
        {
            $DataTable.Columns.Add("$Feature","string") | Out-Null
        }
    }

    
    $NewRow = $DataTable.NewRow()

    
    $NewRow.ServerName = $($Server.DNSHostName)
    $NewRow.OperatingSystem = $($Server.OperatingSystem)

    
    foreach ($Feature in $Features)
    {
        $ColumnName = ($DataTable.Columns | Where-Object ColumnName -eq $Feature).ColumnName
        $NewRow.$ColumnName = "X"
    }

    $DataTable.Rows.Add($NewRow)
}


$CSVFileName = 'ServersListWithInstalledFeatures ' + $(Get-Date -f yyyy-MM-dd) + '.csv'
$DataTable | Export-Csv "$env:USERPROFILE\Documents\$CSVFileName" -NoTypeInformation