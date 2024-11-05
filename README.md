# Mishkys-AD-Range
Mishky's AD Range &amp; The Escalation Path from Hell

Pre-reqs.ps1 creates the folder structure, VMSwitch, etc that I tested this out with. It will also download a Windows Server 2022 ISO and save it with the expected name.

Run Create-Range.ps1 and wait 30 - 45 minutes. It spins up & configures 4 VMs in 2 domains.

Run Generate-Traffic.ps1 to import the function. 

Fire up your Kali VM, run the command 'Generate-Traffic', and begain atacking the range.

A lengthier explanation and our thought process is here: https://happycamper84.medium.com/mishkys-ad-range-382a24884825

An expansion pack to Mishky's AD Range is here (https://github.com/EugeneBelford1995/Mishkys-Range-Expansion-Pack/tree/main). It includes enumeration and pivoting to another forest, DACL abuse on computer accounts and AD CS templates, and more. 
