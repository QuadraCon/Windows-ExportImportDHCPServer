#Export DHCP Scopes
Export-DhcpServer -ComputerName "OldServer01" -File ".\dhcpexport.xml" -leases -ScopeId 10.1.102.0 #Single Scope with leases
Export-DhcpServer -ComputerName "OldServer01" -File ".\dhcpexport.xml" -leases -ScopeId 10.1.107.0, 10.101.100.0, 10.101.140.0 #Multiple scopes with leases
Export-DhcpServer -ComputerName "OldServer01" -File ".\dhcpexport.xml" -leases #All Scopes with leases

#More info: https://learn.microsoft.com/en-us/powershell/module/dhcpserver/export-dhcpserver?view=windowsNewServer02022-ps

#Import DHCP Scopes
Import-DhcpServer -file .\dhcpexport.xml -BackupPath "c:\temp\dhcpbackup\" -Leases -ComputerName "NewServer01"
#BackupPath specifies the path where DHCP server database is backed up before it makes any configuration changes as part of the import operation.
#This will not override existing scopes, if you want that you'll need to add -ScopeOverwrite

#More info: https://learn.microsoft.com/en-us/powershell/module/dhcpserver/import-dhcpserver?view=windowsNewServer02022-ps

#Hot Standby Failover
#Create a backup of both servers first. This can be done through right click on IPv4 -> Backup
#However, on my private server the restore didn't always seem to work, best is to have a full backup through Veeam or any other solution.
#First create Failover Relationship via GUI
#Right click on IPv4 -> Failover
#This script will not overwrite already existing scopes
$PrimaryServer = "NewServer01"  #Replace with the name of the server with the active scopes
$FailoverName = "NewServer01-NewServer02" #Replace with the name of the failover, right click IPv4 -> Properties -> Failover
$Scopes = Get-DhcpServerv4Scope -ComputerName $PrimaryServer
	
foreach ($Scope in $Scopes) {    
    Add-DhcpServerv4FailoverScope -ComputerName $PrimaryServer -Name $FailoverName -ScopeId $Scope.ScopeId.IPAddressToString
    }
    
#More info: https://learn.microsoft.com/en-us/powershell/module/dhcpserver/add-dhcpserverv4failoverscope?view=windowsNewServer02022-ps