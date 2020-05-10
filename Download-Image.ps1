# Download-Image.ps1
# PowerShell Script for azure VM to download blob storage image
Param(
   [parameter(Mandatory=$true)][String]$imageuri
)

# Downloads image.png file to c:\
Invoke-WebRequest $imageuri -OutFile c:\image.jpg

# Returns output of gci to see that the file downloaded successfully
Get-ChildItem -Path c:\image.jpg