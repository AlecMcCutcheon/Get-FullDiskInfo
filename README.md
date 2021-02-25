## Get-FullDiskInfo ##

Get-FullDiskInfo Consolidates Physical Disk, Partition and Volume Information
into One easy to Read and manipulate object.

Here is a list of all of the places Get-FullDiskInfo Grabs it's data from:

- Get-WmiObject Win32_DiskDrive
- Get-WmiObject Win32_DiskPartition
- Get-WmiObject Win32_DiskDriveToDiskPartition
- Get-PhysicalDisk
- Get-Volume

## Running Get-FullDiskInfo in Normal mode ##

```
Get-FullDiskInfo
```

## Some ways to Use with Get-FullDiskInfo in Normal mode ## 

```
(Get-FullDiskInfo) | Where-Object "Volume (Letter, Name, FS)" -like "*C:*" | Format-List
```
```
(Get-FullDiskInfo) | Select -Property "Disk & Partition #", "Volume (Letter, Name, FS)", "Free Space(GB,%)" | Where-Object "Volume (Letter, Name, FS)" -like "*C:*" | Format-List
```
```
(Get-FullDiskInfo)."Disk & Partition #"
```
```
(Get-FullDiskInfo)."Volume (Letter, Name, FS)" 
```

## -Property Names in Normal Mode ##

"Disk(Model,MediaType)"
"Disk & Partition #"
"Volume (Letter, Name, FS)"
"Drive Compression"
"Health & Op. Status"
"Total Disk Size(GB)"
"Used Space(GB,%)"
"Free Space(GB,%)" 


## Running Get-FullDiskInfo in Verbose mode ##

```
Get-FullDiskInfo("verbose")
```

## Some ways to Use with Get-FullDiskInfo in verbose mode ##

```
(Get-FullDiskInfo("verbose")) | Where-Object VolumeLetter -eq "C:" | Format-List
```
```
Get-FullDiskInfo("verbose")) | Where-Object DiskandPartitionNumber -like "*Partition #1*" | Format-List
```
```
(Get-FullDiskInfo("verbose")) | Select -Property VolumeName, TotalDiskSize, UsedSpacePercentage,FreeSpacePercentage | Format-List
```
```
((Get-FullDiskInfo("verbose")) | Where-Object VolumeLetter -eq "C:").FreeSpacePercentage
```
```
((Get-FullDiskInfo("verbose")) | Where-Object VolumeLetter -eq "C:").MediaType 
```

## -Property Names in Verbose Mode ##

DiskModel
MediaType
DiskandPartitionNumber
VolumeLetter          
VolumeName           
FileSystem           
Compressed           
HealthStatus     
OperationalStatus    
TotalDiskSize        
UsedSpace             
UsedSpacePercentage   
FreeSpace          
FreeSpacePercentage

## Credits
Alec McCutcheon created Get-FullDiskInfo to make eveyones life a little bit easier.
