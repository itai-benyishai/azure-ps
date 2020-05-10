# Get-Service.ps1
# PowerShell Script for azure VM to get-service
Param(
   [parameter(Mandatory=$true)][String]$param1
)
Get-service -name $param1