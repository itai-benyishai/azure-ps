# Azure Powershell Assignment for Au10tix Devops role.
# Itai Benyishai

#CONSTANT VARS
$vm = Get-AzVM -Name test-windows -Status
$containername = "test-blob"

# Connect to Account
Connect-AzAccount

## Uploading file to Storage and to VM.
##

# Create Storage Blob Container
$storageaccount = Get-AzStorageAccount -ResourceGroupName $vm.ResourceGroupName
$ctx = $storageaccount.Context
$container = New-AzStorageContainer -Name $containername -Context $ctx -Permission blob

# Upload a file to Blob Container"
Set-AzStorageBlobContent -File "./image.jpg" `
  -Container $containerName `
  -Blob "Image.jpg" `
  -Context $ctx -Force

# List The files in the blob container
Get-AzStorageBlob -Container $ContainerName -Context $ctx

# Register vars regarding blob storage -  lastedit time, uri
$image = Get-AzStorageBlobContent -Blob "Image.jpg" -Container $containername -Context $ctx -Destination ./   
$edit_time = $image.BlobProperties.LastModified.DateTime
$imageuri = $image.ICloudBlob.Uri.AbsoluteUri

# Download Image.jpg to VM, via script
$output = Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name  `
-CommandId 'RunPowerShellScript' -ScriptPath './Download-Image.ps1' -Parameter @{imageuri = $imageuri}

# Output the vm's output to the script
Write-Host $output.Value[0].Message


## Key-vault
## Add key-value entry with the last upload time of the previous file

# Create Vault
$Vault =  New-AzKeyVault -Name 'Itais-Test-Vault' -ResourceGroupName $vm.ResourceGroupName `
-Location $vm.Location

# Add permissions to add and edit vault keys and secret to my user - itai benyishai
$user = Get-AzADUser -SearchString 'itai benyishai'
Set-AzKeyVaultAccessPolicy -VaultName $Vault.VaultName `
-ObjectId $user.Id -PermissionsToKeys backup,create,delete,get,import,list,restore `
-PermissionsToSecrets get,list,set,delete,backup,restore,recover,purge

# Update key value of last edit time of image.jpg file in blob storage
$secretvalue = ConvertTo-SecureString $edit_time -AsPlainText -Force
$secret = Set-AzKeyVaultSecret -VaultName $vault.VaultName -Name 'LastEditTime' -SecretValue $secretvalue

##  Create a CPU usage alert on the VM
##

# Create new acion group
$email = New-AzActionGroupReceiver -Name "itai" -EmailReceiver -EmailAddress "itaibenyishai@gmail.com"
Set-AzActionGroup -Name "itai Action Group" -ResourceGroup $vm.ResourceGroupName `
-ShortName itai -Receiver $email 

# Create PS object of action group
$act = Get-AzActionGroup -ResourceGroupName $vm.ResourceGroupName

# Azure object of action group
$action = New-AzActionGroup -ActionGroupId $act.id
 
# Set alert criteria and counter % Processor Time
$criteria = New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" `
-TimeAggregation average `
-Operator GreaterThanorEqual `
-Threshold 1

# Add the metric
Add-AzMetricAlertRuleV2 -Name "CPU Alert" `
    -ResourceGroupName $act.ResourceGroupName `
    -WindowSize 00:05:00 `
    -Frequency 00:01:00 `
    -TargetResourceId $vm.Id `
    -Condition $criteria `
    -ActionGroup $action `
    -Severity 2


## Restart the VM, print out when the VM is up and running again
##

# Restart VM, Notify When RDP is Available
$restart = Restart-AzVM -Id $vm.Id 
Write-host  "Restart Has $($restart.Status)"
$ip = (Get-AzPublicIpAddress -Name test-windows-ip).ipaddress
while(!(Test-Connection -TcpPort 3389 -IPv4 $ip))
{
    Write-Host "Waiting for $($vm.name) RDP to come up..." -BackgroundColor DarkGray
    Start-Sleep -Seconds 3
}
Write-Host "$($vm.name) Is Running" -ForegroundColor DarkGreen

## BONUS - Monitor VM service
# Get user input for given service
$Service = Read-Host "Which Service Would you like to check on the vm?`nPlease enter Service Name"

$output = Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name  `
-CommandId 'RunPowerShellScript' -ScriptPath './Get-Service.ps1' -Parameter @{param1 = $Service}

# Output the vm's output
Write-Host $output.Value[0].Message
