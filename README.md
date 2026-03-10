## VM-Deploy.ps1 – Quick Run Guide

**Goal**: Take answers from the Atmosera VM request questionnaire and turn them into a fast, repeatable Azure PowerShell deployment.

### Prerequisites

- Az PowerShell modules installed (`Az.Accounts`, `Az.Compute`, `Az.Network`, `Az.Resources`).
- Logged in: `Connect-AzAccount`.
- If needed, know the VNet + subnet (or let the script create a simple one).

### Question → Parameter Mapping

- **2. VM name** → `-VmName`
- **3. Subscription** → `-SubscriptionId`
- **4. Region** → `-Location`
- **5. Resource group** → `-ResourceGroupName`
- **6. Availability set** → `-AvailabilitySetName` (optional)
- **7. OS** → `-ImageUrn` (defaults to Windows Server 2022)
- **8. Size** → `-VmSize`
- **9/10. Disks** → `-OsDiskSizeGB`, `-DataDiskSizeGB`
- **11. VNet** → `-VirtualNetworkName`, `-VirtualNetworkResourceGroup` (if different)
- **12. Subnet** → `-SubnetName`
- **13. IP / Public IP** → `-PrivateIpAddress`, `-AllocatePublicIp`
- **14. Start/Stop schedule** → `-StartStopSchedule` (stored as tag)
- **15. Patch group** → `-PatchGroup` (tag)
- **16. Backup** → `-EnableBackup`
- **17. Firewall / ports** → `-InboundPorts` (NSG rules)
- **18. Domain** → `-DomainToJoin` (stored as tag)

### Example Command (DRILL-VM)

From the `VM-Deploy` folder:

```powershell
cd "C:\Users\OmarRugel\Documents\Work\Useful Scripts\Azure\VM-Deploy"

.\VM-Deploy.ps1 `
  -VmName "DRILL-VM" `
  -SubscriptionId "42b37afe-e1cb-4cee-aba5-84f5960d6d3c" `
  -Location "westus" `
  -ResourceGroupName "RG-DRILL-VM" `
  -VirtualNetworkName "YOUR-VNET-NAME" `
  -VirtualNetworkResourceGroup "NETWORK-RG" `
  -SubnetName "YOUR-SUBNET" `
  -PrivateIpAddress "10.2.2.141" `
  -VmSize "Standard_B12ms" `
  -OsDiskSizeGB 128 `
  -DataDiskSizeGB 256 `
  -InboundPorts 3389,80,443 `
  -PatchGroup "YOUR-PATCH-GROUP" `
  -EnableBackup `
  -DomainToJoin "your.domain.com" `
  -EnableDiagnosticLogs
```

The script will prompt for local admin credentials and then build the NSG, NIC, VM, and optional data disk.

### GitHub Versioning (quick steps)

In the root `Azure` folder (once), you can run:

```powershell
cd "C:\Users\OmarRugel\Documents\Work\Useful Scripts\Azure"
git init
git add .
git commit -m "Add VM-Deploy script and README"
git remote add origin https://github.com/<your-user>/<your-repo>.git
git push -u origin main
```

After any small change:

```powershell
git add .
git commit -m "Update VM-Deploy parameters"
git push
```

