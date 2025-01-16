# Mishkys-AD-Range
Edit to add: I have since created Version 1.1

Mishky’s AD Range is here: https://github.com/EugeneBelford1995/Mishkys-AD-Range-Version1.1/tree/main

The Expansion pack (second forest) is here: https://github.com/EugeneBelford1995/Mishkys-Range-Expansion-Pack-Version1.1

--- break ---

Mishky's AD Range &amp; The Escalation Path from Hell

Pre-reqs.ps1 creates the folder structure, VMSwitch, etc that I tested this out with. It will also download a Windows Server 2022 ISO and save it with the expected name.

Run Create-Range.ps1 and wait 30 - 45 minutes. It spins up & configures 4 VMs in 2 domains.

Run Generate-Traffic.ps1 to import the function. 

Fire up your Kali VM, run the command 'Generate-Traffic', and begain atacking the range.

A lengthier explanation and our thought process is here: https://happycamper84.medium.com/mishkys-ad-range-382a24884825

An expansion pack to Mishky's AD Range is here (https://github.com/EugeneBelford1995/Mishkys-Range-Expansion-Pack/tree/main). It includes enumeration and pivoting to another forest, DACL abuse on computer accounts and AD CS templates, and more. 

--- Important note if you are trying to run this on a Win10 laptop with Hyper-V enabled ---

Go into Lines 39 - 41 of Create-Range.ps1:
Set the RAM to something more like 2 GB startup, 3 GB max (depending on how much RAM you have)
Change "Testing" to "Default Switch" as your Win10 OS likely put the Default Switch on your Wi-Fi adapter that's actually network connected.
Change the PrefixLength to 20 in P1.ps1 for each VM.
