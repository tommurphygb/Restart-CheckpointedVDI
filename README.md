# Restart-CheckpointedVDI

This repository contains two files:
Restart-CheckpointedVDI.ps1 - a PowerShell script to reboot an RDS pooled virtual desktop.
Restart-CheckpointedVDI.xml - import into Task Scheduler to create a task to trigger Restart-CheckpointedVDI.ps1 each time a checkpoint is restored on a Hyper-V VM.

For more information about the need for this script, see my blog post at http://blog.tmurphy.org/2015/10/hyper-v-dynamic-mac-addressing-is.html
