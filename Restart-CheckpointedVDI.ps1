<#
.DESCRIPTION
   Reboots a pooled VDI after a checkpoint is restored in order to fix MAC address conflicts.

.PARAMETER EventChannel
   The EventChannel of the event that triggered the script.

.PARAMETER EventRecordID
   The EventRecordID of the event that triggered the script.

.NOTES
   Restart-CheckpointedVDI.ps1
   Written by Tom Murphy
   http://blog.tmurphy.org
   
   Some of the task scheduler code borrowed from TechNet
   http://blogs.technet.com/b/wincat/archive/2011/08/25/trigger-a-powershell-script-from-a-windows-event.aspx

   Attach a task to event ID 18596 in Microsoft-Windows-Hyper-V-Worker/Admin to execute this script.
   Set the MAC address of the checkpoints to dynamic by running the following command (this is REQUIRED!)
   Get-VM -Name "Name_Here" | Get-VMSnapshot | Get-VMNetworkAdapter | Set-VMNetworkAdapter -DynamicMacAddress

.LINK
   http://blog.tmurphy.org

#>

#Requires -Version 3
#Requires -Modules Hyper-V

# Define parameters
Param
(
    # Event Channel (log name)
    [Parameter(Mandatory=$true)]
    [string]$EventChannel,

    # EventRecordID (specific event record)
    [Parameter(Mandatory=$true)]
    $EventRecordID
)

# Import Hyper-V Module
Import-Module Hyper-V

# Get the checkpoint restore event from event log that triggered the script
$Event = Get-WinEvent -LogName $EventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[(EventRecordID=$eventRecordID)]]</Select></Query></QueryList>"

# If the event is found (no reason it shouldn't, since task scheduler passed the eventRecordID), continue on...
if ($Event){
    # Extract the name of the VM from the event message, removing the single quotes
    $Name = $Event.Message.Split(" ") | Select-Object -First 1
    $Name = $Name.Substring(1,$Name.Length - 2)

    # Get the VM specified in the event message
    $VM = Get-VM -Name $Name
    # Get the VM's checkpoint
    $Checkpoint = $VM | Get-VMSnapshot

    # Ensure the VM is an RDS pooled virtual desktop by checking the name of the checkpoint
    # RDS 2012+ pooled desktops use a consistent naming convention for the checkpoint
    if ($Checkpoint.Name -like "RDV_ROLLBACK - *"){
        # This is a pooled desktop. Stop the VM
        $VM | Stop-VM -TurnOff
        # Pause a few seconds to ensure it's powered down
        Start-Sleep -Seconds 5
        # Bring the VM back online
        $VM | Start-VM
    } # End if
} # End if