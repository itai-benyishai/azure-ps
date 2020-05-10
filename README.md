# azure-ps
Assignment for au10tix DevOps Role By Itai Benyishai
The Main ps1 file is azure.ps1 ( The other scripts are called for by the main Script )
Azure.ps1 is documented in deatail with comments.

The Script does all the tasks as requested in the assignment. 

1. Creates a Blob Storage (Test-blob) and Uploads a picture file to the Blob Storage
2. Lists the files in the Blob Storage
3. Download the picture file to the Windows VM.
4. Creates a key vault
5. Updates a secret to the vault, containing the last edit date of the file.
6. Creates a CPU usage alert on the VM, the threshold is 1% CPU usage, it sends an alert to itaibenyishai@gmail.com
7. Restarts the VM, prints out when the VM is up and running again and available on RDP
8. BONUS - Monitors a VM service, according to user input.
