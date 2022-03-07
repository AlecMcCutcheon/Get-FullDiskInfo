function Get-FullDiskInfo {

  param(
    [Parameter(Mandatory = $false)]
    [switch]$CleanTemp
  )

  function Get-Unit {

    param(
      [Parameter(Mandatory = $false,ValueFromPipeLine = $true)]
      [psobject]$Number,
      [Parameter(Mandatory = $false)]
      [switch]$GetTag
    )

    if ($Number / 1KB -gt 1000) {

      if ($Number / 1MB -gt 1000) {

        if ($Number / 1GB -gt 1000) {

          if ($Number / 1TB -gt 1000) {

            $Unit = 1PB; $UnitTag = "PB"

          } else { $Unit = 1TB; $UnitTag = "TB" }

        } else { $Unit = 1GB; $UnitTag = "GB" }

      } else { $Unit = 1MB; $UnitTag = "MB" }

    } else { $Unit = 1KB; $UnitTag = "KB" }

    if ($GetTag -eq $false) {

      Write-Output $Unit
    } else {
      Write-Output $UnitTag
    }
  }

  if ($CleanTemp -eq $true) {

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
           [Security.Principal.WindowsBuiltInRole]"Administrator")) {

      Write-Host "Insufficient Permissions" -ForegroundColor red
      break

    } else {
      $tempfolders = @("C:\Windows\Temp\*","C:\Users\*\Appdata\Local\Temp\*")
      Remove-Item $tempfolders -Force -Recurse -ErrorAction SilentlyContinue
      Write-Host "Cleaned all Temp Files that are not currently in use. :)" -ForegroundColor Green
      break
    }

  }

  Get-CimInstance Win32_DiskDrive | ForEach-Object {

    $disk = $_
    $partitions = "ASSOCIATORS OF " +
    "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
    "WHERE AssocClass = Win32_DiskDriveToDiskPartition"

    Get-CimInstance -Query $partitions | ForEach-Object {

      $partition = $_
      $drives = "ASSOCIATORS OF " +
      "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
      "WHERE AssocClass = Win32_LogicalDiskToPartition"

      Get-CimInstance -Query $drives | ForEach-Object {

        $PhysicalDiskScrap = (Get-PhysicalDisk | Where-Object FriendlyName -EQ $disk.Model)
        $GetVolumeScrap = (Get-Volume | Where-Object FileSystemLabel -EQ ($_.VolumeName))
        $HealthStatus = $GetVolumeScrap.HealthStatus
        $OperationalStatus = $GetVolumeScrap.OperationalStatus
        $MediaType = $PhysicalDiskScrap.MediaType
        $RawUsedSpace = (($_.Size) - ($_.FreeSpace))
        $WindowsDirPath = (($_.DeviceID) + "\Windows\System32")

        if (Test-Path $WindowsDirPath) {

          $WindowsDirVol = "True"

          if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                 [Security.Principal.WindowsBuiltInRole]"Administrator")) {

            $TempSize = "Unknown"

          } else {

            $Temp1 = (Get-ChildItem –force C:\Windows\Temp –Recurse -ErrorAction SilentlyContinue | Measure-Object Length -s).sum
            $Temp2 = (Get-ChildItem –force C:\Users\*\AppData\Local\Temp –Recurse -ErrorAction SilentlyContinue | Measure-Object Length -s).sum
            $totalRawTemp = $Temp1 + $Temp2

            $TempSpaceUnit = $totalRawTemp | Get-Unit
            $TempSpaceUnitTag = $totalRawTemp | Get-Unit -GetTag

            $TempSize = ("{0:N3}" -f ($totalRawTemp / $TempSpaceUnit)) + " " + $TempSpaceUnitTag

          }

        } else {

          $WindowsDirVol = "False"
          $TempSize = "N/A"

        }

        $SizeUnit = $_.Size | Get-Unit
        $SizeUnitTag = $_.Size | Get-Unit -GetTag

        $FreeSpaceUnit = $_.FreeSpace | Get-Unit
        $FreeSpaceUnitTag = $_.FreeSpace | Get-Unit -GetTag

        $UsedSpaceUnit = $RawUsedSpace | Get-Unit
        $UsedSpaceUnitTag = $RawUsedSpace | Get-Unit -GetTag

        $Size = ("{0:N3}" -f ($_.Size / $SizeUnit)) + " " + $SizeUnitTag
        $Free = ("{0:N3}" -f ($_.FreeSpace / $FreeSpaceUnit)) + " " + $FreeSpaceUnitTag
        $FreePercent = "{0:P3}" -f (($_.FreeSpace / 1GB) / ($_.Size / 1GB))
        $Used = ("{0:N3}" -f ($RawUsedSpace / $UsedSpaceUnit)) + " " + $UsedSpaceUnitTag
        $UsedPercent = "{0:P3}" -f (($RawUsedSpace / 1GB) / ($_.Size / 1GB))
        $Compressed = $_.Compressed
        $PartitionStyle = $partition.Description
        $DiskStyle = $_.Description
        $VolumeName = $_.VolumeName

        if ($DiskStyle -eq "Removable Disk" -and $MediaType -eq $null) { $MediaType = "UFD" }

        if ($MediaType -like "*HDD*") { $MediaType = "HDD" }

        if ($VolumeName -eq "") { $VolumeName = "Unlabled" }

        if (!($PSBoundParameters['Verbose'] -or $VerbosePreference -eq 'Continue')) {

          $disks = [pscustomobject]@{

            "DiskType" = "Normal Disk"
            "Disk(Model,MediaType)" = "[ " + $disk.Model + ", " + $MediaType + " ]"
            "Disk & Partition #" = "[ " + $partition.Name + " ]"
            "Vol.(Letter,Name,FS)" = $_.DeviceID + " , " + $VolumeName + ", " + $_.FileSystem
            "Vol. Health & Op. Status" = $HealthStatus + ", " + $OperationalStatus
            "Vol. Compression" = $Compressed
            "Total Vol. Size($SizeUnitTag)" = $Size
            "Used Vol. Space($UsedSpaceUnitTag,%)" = ($Used + ", " + $UsedPercent)
            "Free Vol. Space($FreeSpaceUnitTag,%)" = ($Free + ", " + $FreePercent)
            "Windows Directory Vol." = $WindowsDirVol
            "TotalTempSize($TempSpaceUnitTag)" = $TempSize
          }

          if ($TempSpaceUnitTag -eq $null) {

            $disks = $disks | Select-Object -Property * -ExcludeProperty "TotalTempSize($TempSpaceUnitTag)"
          }

          $uniqueCount = @($disks | Select-Object -Unique "Vol.(Letter,Name,FS)").Count

          if ($uniqueCount -eq $disks.Count) {
            Write-Output $disks
          } else {
            $ignored = [System.Collections.Generic.List[string]]::new()
            foreach ($disk in $disks) {
              if ($disk. "Vol.(Letter,Name,FS)" -notin $ignored) {
                $return = @(
                  $disks | Where-Object {
                    $disk. 'Vol.(Letter,Name,FS)' -eq $_. 'Vol.(Letter,Name,FS)'
                  }
                )
                if ($return.Count -gt 1) {
                  $return. "Vol.(Letter,Name,FS)" | ForEach-Object { $ignored.Add($_) }
                  $outputObj = $disk
                  $outputObj. 'Disk(Model,MediaType)' = $return. 'Disk(Model,MediaType)'
                  $outputObj. 'Disk & Partition #' = $return. 'Disk & Partition #'
                  $outputObj.DiskType = "RAID Group or Storage Pool"
                  Write-Output $outputObj
                } else {
                  Write-Output $disk
                } } } }

        } else {

          $disks = [pscustomobject]@{

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

          $uniqueCount = @($disks | Select-Object -Unique "VolLetter","VolName","VolFileSystem").Count

          if ($uniqueCount -eq $disks.Count) {
            Write-Output $disks
          } else {
            $ignored = [System.Collections.Generic.List[string]]::new()
            foreach ($disk in $disks) {
              if ($disk. "VolLetter" -notin $ignored) {
                $return = @(
                  $disks | Where-Object {
                    $disk. 'VolLetter' -eq $_. 'VolLetter'
                  }
                )
                if ($return.Count -gt 1) {
                  $return. "VolLetter" | ForEach-Object { $ignored.Add($_) }
                  $outputObj = $disk
                  $outputObj. 'DiskModel' = $return. 'DiskModel'
                  $outputObj. 'MediaType' = $return. 'MediaType'
                  $outputObj. 'DiskandPartitionNumber' = $return. 'DiskandPartitionNumber'
                  $outputObj.DiskType = "RAID Group or Storage Pool"
                  Write-Output $outputObj
                } else {
                  Write-Output $disk
                } } } }

        }
      }
    }
  }
}

Set-Alias Get-FDI Get-FullDiskInfo

Export-ModuleMember -Function Get-FullDiskInfo -Alias Get-FDI
