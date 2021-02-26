Param(
   [Parameter(Position=1)]
   [string]$Mode
)

function GetSizeUnit ($Number) {

if ($Number/1KB -gt 1000) {

if ($Number/1MB -gt 1000) {

if ($Number/1GB -gt 1000) {

if ($Number/1TB -gt 1000) {

 $script:SizeUnit = 1PB; $script:SizeUnitTag = "PB"

}else {$script:SizeUnit = 1TB; $script:SizeUnitTag = "TB"}

}else {$script:SizeUnit = 1GB; $script:SizeUnitTag = "GB"}

}else {$script:SizeUnit = 1MB; $script:SizeUnitTag = "MB"}

}else {$script:SizeUnit = 1KB; $script:SizeUnitTag = "KB"}

}

function GetFreeSpaceUnit ($Number) {

if ($Number/1KB -gt 1000) {

if ($Number/1MB -gt 1000) {

if ($Number/1GB -gt 1000) {

if ($Number/1TB -gt 1000) {

 $script:FreeSpaceUnit = 1PB; $script:FreeSpaceUnitTag = "PB"

}else {$script:FreeSpaceUnit = 1TB; $script:FreeSpaceUnitTag = "TB"}

}else {$script:FreeSpaceUnit = 1GB; $script:FreeSpaceUnitTag = "GB"}

}else {$script:FreeSpaceUnit = 1MB; $script:FreeSpaceUnitTag = "MB"}

}else {$script:FreeSpaceUnit = 1KB; $script:FreeSpaceUnitTag = "KB"}

}

function GetUsedSpaceUnit ($Number) {

if ($Number/1KB -gt 1000) {

if ($Number/1MB -gt 1000) {

if ($Number/1GB -gt 1000) {

if ($Number/1TB -gt 1000) {

 $script:UsedSpaceUnit = 1PB; $script:UsedSpaceUnitTag = "PB"

}else {$script:UsedSpaceUnit = 1TB; $script:UsedSpaceUnitTag = "TB"}

}else {$script:UsedSpaceUnit = 1GB; $script:UsedSpaceUnitTag = "GB"}

}else {$script:UsedSpaceUnit = 1MB; $script:UsedSpaceUnitTag = "MB"}

}else {$script:UsedSpaceUnit = 1KB; $script:UsedSpaceUnitTag = "KB"}

}

function TempSpaceUnit ($Number) {

if ($Number/1KB -gt 1000) {

if ($Number/1MB -gt 1000) {

if ($Number/1GB -gt 1000) {

if ($Number/1TB -gt 1000) {

 $script:TempSpaceUnit = 1PB; $script:TempSpaceUnitTag = "PB"

}else {$script:TempSpaceUnit = 1TB; $script:TempSpaceUnitTag = "TB"}

}else {$script:TempSpaceUnit = 1GB; $script:TempSpaceUnitTag = "GB"}

}else {$script:TempSpaceUnit = 1MB; $script:TempSpaceUnitTag = "MB"}

}else {$script:TempSpaceUnit = 1KB; $script:TempSpaceUnitTag = "KB"}

}

function CleanTemp {

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
 			[Security.Principal.WindowsBuiltInRole]"Administrator")) {

	Write-Host "Insufficient Permissions. :(" -ForegroundColor red
    Write-Host "Script Can't Clean all Temp Files without Admin Permissions." -ForegroundColor white

	break

} else {
$tempfolders = @("C:\Windows\Temp\*", "C:\Users\*\Appdata\Local\Temp\*")
Remove-Item $tempfolders -force -recurse -ErrorAction SilentlyContinue
Write-Host "Cleaned all Temp Files that are not currently in use. :)" -ForegroundColor Green
}}

function Get-FullDiskInfoRaw ($Mode) {Get-WmiObject Win32_DiskDrive | ForEach-Object {

  $disk = $_
  $partitions = "ASSOCIATORS OF " +
                "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                "WHERE AssocClass = Win32_DiskDriveToDiskPartition"

  Get-WmiObject -Query $partitions | ForEach-Object {

    $partition = $_
    $drives = "ASSOCIATORS OF " +
              "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
              "WHERE AssocClass = Win32_LogicalDiskToPartition"

    Get-WmiObject -Query $drives | ForEach-Object {

      $PhysicalDiskScrap = (Get-PhysicalDisk | Where-Object FriendlyName -eq $disk.Model)
      $GetVolumeScrap = (Get-Volume | Where-Object FileSystemLabel -eq ($_.VolumeName))
      $HealthStatus = $GetVolumeScrap.HealthStatus
      $OperationalStatus = $GetVolumeScrap.OperationalStatus
      $MediaType = $PhysicalDiskScrap.MediaType
      $RawUsedSpace = (($_.Size) - ($_.FreeSpace))
      $WindowsDirPath = (($_.DeviceID) + "\Windows\System32")

      if (Test-Path $WindowsDirPath) {
      
       $WindowsDirVol = "True"

       $Temp1 = (gci –force C:\Windows\Temp –Recurse -ErrorAction SilentlyContinue| measure Length -s).sum
       $Temp2 = (gci –force C:\Users\*\AppData\Local\Temp –Recurse -ErrorAction SilentlyContinue| measure Length -s).sum
       $totalRawTemp = $Temp1 + $Temp2
       TempSpaceUnit($totalRawTemp)

       $TempSize = ("{0:N3}" -f ($totalRawTemp/$TempSpaceUnit)) + " " + $TempSpaceUnitTag

      } else { 
      
      $WindowsDirVol = "False" 
      $TempSize = "N/A"
      
      }

      GetSizeUnit($_.Size)
      GetFreeSpaceUnit($_.FreeSpace)
      GetUsedSpaceUnit($RawUsedSpace)

      $Size = ("{0:N3}" -f ($_.Size/$SizeUnit)) + " " + $SizeUnitTag
      $Free = ("{0:N3}" -f ($_.FreeSpace/$FreeSpaceUnit)) + " " + $FreeSpaceUnitTag
      $FreePercent = "{0:P3}" -f (($_.FreeSpace/1GB)/($_.Size/1GB))
      $Used = ("{0:N3}" -f ($RawUsedSpace/$UsedSpaceUnit)) + " " + $UsedSpaceUnitTag
      $UsedPercent = "{0:P3}" -f (($RawUsedSpace/1GB)/($_.Size/1GB))
      $Compressed = $_.Compressed
      $PartitionStyle = $partition.Description
      $DiskStyle = $_.Description
      $VolumeName = $_.VolumeName

      if ($DiskStyle -eq "Removable Disk" -AND $MediaType -eq $null) {$MediaType = "UFD"}

      if ($MediaType -like "*HDD*") {$MediaType = "HDD"}

      if ($VolumeName -eq "") {$VolumeName = "Unlabled"}

      if($Mode -ne "verbose"){

        [PSCustomObject]@{
        
        "DiskType" = "Normal Disk"
        "Disk(Model,MediaType)" = "[ " + $disk.Model + ", " + $MediaType + " ]"
        "Disk & Partition #"   = "[ " + $partition.Name + " ]"
        "Vol.(Letter,Name,FS)" = $_.DeviceID + " , " + $VolumeName + ", " + $_.FileSystem
        "Vol. Health & Op. Status" = $HealthStatus + ", " + $OperationalStatus
        "Vol. Compression" = $Compressed
        "Total Vol. Size($SizeUnitTag)" = $Size
        "Used Vol. Space($UsedSpaceUnitTag,%)" = ($Used + ", " + $UsedPercent)
        "Free Vol. Space($FreeSpaceUnitTag,%)" = ($Free + ", " + $FreePercent)
        "Windows Directory Vol." = $WindowsDirVol
        "TotalTempSize($TempSpaceUnitTag)" = $TempSize
            
            }}else {

           [PSCustomObject]@{

        "DiskType" = "Normal Disk"
        "DiskModel" = $disk.Model
        "MediaType" = $MediaType
        "DiskStyle" = $DiskStyle
        "PartitionStyle" = $PartitionStyle
        "DiskandPartitionNumber" = "[ " + $partition.Name + " ]"
        "VolLetter" = $_.DeviceID
        "VolName" = $VolumeName
        "VolFileSystem" = $_.FileSystem
        "VolCompression" = $Compressed
        "VolHealthStatus" = $HealthStatus
        "VolOperationalStatus" = $OperationalStatus
        "TotalVolSize" = $Size
        "UsedVolSpace" = $Used
        "UsedVolSpacePercent" = $UsedPercent
        "FreeVolSpace" = $Free
        "FreeVolSpacePercent" = $FreePercent
        "WindowsDirectoryVol" = $WindowsDirVol
        "TotalTempSize" = $TempSize
          
          }
        }
      }
    }
  }
}

function Get-FullDiskInfo ($Mode) {

$disks = Get-FullDiskInforaw($Mode)

if($Mode -ne "verbose"){

$uniqueCount = @($disks | Select-Object -Unique "Vol.(Letter,Name,FS)").Count

if ($uniqueCount -eq $disks.Count) {
  Write-Output $disks
} else {
    $ignored = [System.Collections.Generic.List[string]]::new()
    foreach ($disk in $disks) {
        if ($disk."Vol.(Letter,Name,FS)" -notin $ignored) {
            $return = @(
                $disks | Where-Object {
                    $disk.'Vol.(Letter,Name,FS)' -eq $_.'Vol.(Letter,Name,FS)'
                }
            )
         if ($return.Count -gt 1) {
                $return."Vol.(Letter,Name,FS)" | ForEach-Object { $ignored.Add($_) }
                $outputObj = $disk
                $outputObj.'Disk(Model,MediaType)' = $return.'Disk(Model,MediaType)'
                $outputObj.'Disk & Partition #' = $return.'Disk & Partition #'
                $outputObj.DiskType = "RAID Group or Storage Pool"
                Write-Output $outputObj
            } else {
                Write-Output $disk
            }}}}

}else{

$uniqueCount = @($disks | Select-Object -Unique "VolLetter", "VolName", "VolFileSystem").Count

if ($uniqueCount -eq $disks.Count) {
  Write-Output $disks
} else {
    $ignored = [System.Collections.Generic.List[string]]::new()
    foreach ($disk in $disks) {
        if ($disk."VolLetter" -notin $ignored) {
            $return = @(
                $disks | Where-Object {
                    $disk.'VolLetter' -eq $_.'VolLetter'
                }
            )
         if ($return.Count -gt 1) {
                $return."VolLetter" | ForEach-Object { $ignored.Add($_) }
                $outputObj = $disk
                $outputObj.'DiskModel' = $return.'DiskModel'
                $outputObj.'MediaType' = $return.'MediaType'
                $outputObj.'DiskandPartitionNumber' = $return.'DiskandPartitionNumber'
                $outputObj.DiskType = "RAID Group or Storage Pool"
                Write-Output $outputObj
            } else {
                Write-Output $disk
            }}}}

  }
}

function Get-FDI ($Mode) {

Get-FullDiskInfo ($Mode)

}
