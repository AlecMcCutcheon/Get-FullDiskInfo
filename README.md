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

Get-FDI
```
![alt text](https://github.com/AlecMcCutcheon/Get-FullDiskInfo/blob/main/Screenshot%202021-02-25%20104905.jpg?raw=true)

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

"Disk(Model,MediaType)"<br/>
"Disk & Partition #"<br/>
"Volume (Letter, Name, FS)"<br/>
"Drive Compression"<br/>
"Health & Op. Status"<br/>
"Total Disk Size(Dynamic:GB|PB|MB|etc.)"<br/>
"Used Space(Dynamic:GB|PB|MB|etc.,%)"<br/>
"Free Space(Dynamic:GB|PB|MB|etc.,%)"<br/>
"Windows Directory Vol."<br/>
"TotalTempSize(Dynamic:GB|PB|MB|etc.)"<br/>


## Running Get-FullDiskInfo in Verbose mode ##

```
Get-FullDiskInfo verbose

Get-FDI verbose
```
![alt text](https://github.com/AlecMcCutcheon/Get-FullDiskInfo/blob/main/Screenshot%202021-02-25%20105459.jpg?raw=true)

## Some ways to Use with Get-FullDiskInfo in verbose mode ##

```
Get-FullDiskInfo verbose | Where-Object VolumeLetter -eq "C:" | Format-List
```
```
Get-FullDiskInfo verbose | Where-Object DiskandPartitionNumber -like "*Partition #1*" | Format-List
```
```
Get-FullDiskInfo verbose | Select -Property VolumeName, TotalDiskSize, UsedSpacePercentage,FreeSpacePercentage | Format-List
```
```
Get-FullDiskInfo verbose | Where-Object VolumeLetter -eq "C:").FreeSpacePercentage
```
```
Get-FullDiskInfo verbose | Where-Object VolumeLetter -eq "C:").MediaType 
```

## -Property Names in Verbose Mode ##

DiskModel<br/>
MediaType<br/>
DiskandPartitionNumber<br/>
VolumeLetter<br/>
VolumeName<br/>
FileSystem<br/>
Compressed<br/>
HealthStatus<br/>
OperationalStatus<br/>
TotalDiskSize<br/>
UsedSpace<br/>
UsedSpacePercentage<br/>
FreeSpace<br/>
FreeSpacePercentage<br/>
WindowsDirectoryVol<br/>
TotalTempSize<br/>

## How to use the Extra CleanTemp Function ##
Seems pretty self explanatory but essentially it cleans the temp files from the temp folders that aren't currently in use in windows
```
CleanTemp
```
## Credits
Alec McCutcheon created Get-FullDiskInfo to make eveyones life a little bit easier.
