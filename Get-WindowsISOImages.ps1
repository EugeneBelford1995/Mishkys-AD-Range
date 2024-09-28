#http://woshub.com/find-windows-version-edition-build-iso-wim-file/

#Specify a path to the ISO file:
#$imagePath = "C:\iso\WindowsServer_RTM.iso"
$imagePath = "C:\PowerLab\ISOs\Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

#Mount the ISO image:
$Report = @()
$beforeMount = (Get-Volume).DriveLetter
$mountResult = Mount-DiskImage $imagePath -PassThru
$afterMount = (Get-Volume).DriveLetter
#$ImageDrive= "$(($afterMount -join '').replace(($beforeMount -join ''), '')):"
$ImageDrive = "E:\"

#You will get a drive letter where the image is mounted (the drive letter is assigned automatically, if not, check how to fix it here).

#Then get the information about Windows versions in install.wim or install.esd:

$WinImages = Get-windowsimage -ImagePath "$ImageDrive\sources\install.wim”
Foreach ($WinImage in $WinImages)
{
$curImage=Get-WindowsImage -ImagePath "$ImageDrive\sources\install.wim” -Index $WinImage.ImageIndex
$objImage = [PSCustomObject]@{
ImageIndex = $curImage.ImageIndex
ImageName = $curImage.ImageName
Version = $curImage.Version
Languages=$curImage.Languages
Architecture =$curImage.Architecture
}
$Report += $objImage
}

#Unmount the ISO image:

Dismount-DiskImage $mountResult.ImagePath
#You can display the result in the Out-GridView table:
$Report  | Out-GridView