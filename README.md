## Get-FullDiskInfo V.3 ##
Get-FullDiskInfo Consolidates Physical Disk, Partition and Volume Information
into One easy to Read and manipulate object.

* 2/25/2021 With help from ihaxr on reddit, added functionality to distinguish raid groups/storage pools from normal disks, and combine them into a single object

Here is a list of all of the places Get-FullDiskInfo Grabs it's data from:

- Get-WmiObject Win32_DiskDrive
- Get-WmiObject Win32_DiskPartition
- Get-WmiObject Win32_DiskDriveToDiskPartition
- Get-PhysicalDisk
- Get-Volume


Here's a link to the latest <a href="https://github.com/AlecMcCutcheon/Get-FullDiskInfo/releases">Releases</a> of the Module.
or Here's a One-Liner you can use to pull the latest version of the module temporarily for your current session.
```
New-Module -Name Get-FullDiskInfo -ScriptBlock ([Scriptblock]::Create(([System.IO.StreamReader]((([System.Net.WebRequest]::CreateHttp("https://gitcdn.link/cdn/AlecMcCutcheon/Get-FullDiskInfo/V.3/Get-FullDiskInfo.psm1")).GetResponse()).GetResponseStream())).ReadToEnd()))
```
You will have to do Get-FullDiskInfo, or Get-FDI to actually use it after you execute the one liner

Currently working on making it into a PowerShell module..
Plz lmk what you would like me to add or feedback on the project.

![alt text](https://github.com/AlecMcCutcheon/Get-FullDiskInfo/blob/main/Preview.jpg?raw=true)

## Running Get-FullDiskInfo in Normal mode ##

```
Get-FullDiskInfo

Get-FDI
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

"DiskType"<br/>
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

## Some ways to Use with Get-FullDiskInfo in verbose mode ##

```
Get-FullDiskInfo verbose | Where-Object VolLetter -eq "C:" | Format-List
```
```
Get-FullDiskInfo verbose | Where-Object DiskandPartitionNumber -like "*Partition #1*" | Format-List
```
```
Get-FullDiskInfo verbose | Select -Property VolName, TotalVolSize, UsedVolSpacePercentage,FreeVolSpacePercentage | Format-List
```
```
(Get-FullDiskInfo verbose | Where-Object VolLetter -eq "C:").FreeVolSpacePercentage
```
```
(Get-FullDiskInfo verbose | Where-Object VolLetter -eq "C:").MediaType 
```

## -Property Names in Verbose Mode ##

"DiskType"<br/>
DiskModel<br/>
MediaType<br/>
DiskStyle<br/>
PartitionStyle<br/>
DiskandPartitionNumber<br/>
VolLetter<br/>
VolName<br/>
VolFileSystem<br/>
VolCompression<br/>
VolHealthStatus<br/>
VolOperationalStatus<br/>
TotalVolSize<br/>
UsedVolSpace<br/>
UsedVolSpacePercentage<br/>
FreeVolSpace<br/>
FreeVolSpacePercentage<br/>
WindowsDirectoryVol<br/>
TotalTempSize<br/>

## How to use the Extra CleanTemp Function ##
Seems pretty self explanatory but essentially it cleans the temp files from the temp folders that aren't currently in use in windows
- Requires Admin permission
```
CleanTemp
```
## Credits
Creater: Alec McCutcheon, Also Big thx to ihaxr on Reddit: https://www.reddit.com/user/ihaxr/ for the help :)
- Created Get-FullDiskInfo to make eveyones life a little bit easier.
