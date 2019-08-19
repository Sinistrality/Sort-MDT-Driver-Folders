#Standard GPLv3 License
#This script sorts the MDT driver folders into alphabetical order.
#If you're overwriting the path and running this script please be sure to BACKUP your original DriverGroups.xml file.
#Please feel free to tweak this script to suit your needs.
#Below there is an exclude group list.  I'd recommend putting your top level folders in this group. (Default and Hidden are already hard coded in)
#______________________________________________________________________________________________________
#Author: Mike Kisiel 
#Contributors:
#Latest Update: 8/19/2019
#Patch Notes:
#v1.0.1 - Added file backup feature.
#v1.0 - Release version
#______________________________________________________________________________________________________

#Set the path to the DriverGroups.XML file you wish to edit.
$FileToEdit = "C:\DeploymentShare$\Control\DriverGroups.xml"

#Set the export path where you want the new file to go.
$exportPath = "C:\DeploymentShare$\Control\DriverGroups.xml"

##Set back up options - A file will be created with the date appended to the file name in the directory you set.
#Turn the back up file feature On/Off (Off by default)
$BackupFileOn = $false
#Set the folder where you want the backups to go
$BackupFolderPath = 'C:\DeploymentShare$\Control\DriverGroups\'

#Exits the program if it is unable to read/find the file.
Try{[xml]$xml = get-content $FileToEdit -ErrorAction Stop}
Catch{
Write-Host "Could not access path $FileToEdit. Check your path/access rights." -ForegroundColor Yellow
Exit
}

#Backup original file
If ($BackupFileOn -eq $true){
    #Copy the original file to the specified folder and append a data value to its name. 
     If (Test-Path -Path $BackupFolderPath){
        #Copys the file
        Try{Copy-Item $FileToEdit -Destination $BackupFolderPath\DriverGroups$((Get-Date).ToString('MM-dd-yyyy')).xml -Force -ErrorAction Stop}   
        catch{Write-Host "Could not access path $BackupFolderPath. Check your path/access rights." -ForegroundColor Yellow}
    }Else{ 
        #Creates directory if it doesn't exist then copys the file.
        Try{New-Item -ItemType 'Directory' -Path $BackupFolderPath -ErrorAction Stop | Out-Null
        Copy-Item $FileToEdit -Destination $BackupFolderPath\DriverGroups$((Get-Date).ToString('MM-dd-yyyy')).xml -Force -ErrorAction Stop}
        Catch{Write-Host "Could not move file to $BackupFolderPath"}
    }
}


#Create the list objects we'll be using
$GroupList = New-Object System.Collections.Generic.List[System.Object]
$ReadOnlyList = New-Object System.Collections.Generic.List[System.Object]

#Create groups that are at the top level you do not want to remove or have explicitly sorted
#Default and hidden groups are already included!
$ExcludeGroup1 = 'WinPE x64'
$ExcludeGroup2 = 'Windows 10 x64'
#$ExcludeGroup3 = 'Add more groups here if you don't want certain top level folders sorted.'

#Pull info from XML File
$XMLGroups = $xml.FirstChild.group

#Builds two separate lists.  One you do not want to edit, and one you do.
Foreach ($group in $XMLGroups){

    #Separates list into two different groups as you don't want to sort the high level and read-only groups
    If (
    $Group.Name -eq 'default' -or
    $Group.Name -eq 'hidden' -or
    $Group.Name -eq $ExcludeGroup1 -or
    $Group.Name -eq $ExcludeGroup2 #-or
    #$Group.Name -eq $ExcludeGroup3 #uncomment this to add another group you explicitly don't want sorted.

    ){#Add into read only list that will remain at the top of the xml
    $ReadOnlyList.Add($group)   
    }
    else{#Put all other groups into a list to be sorted.
    $GroupList.Add($group)
    }
}
#Add tag with no XML header to the beginning of the file
"<groups>" | Out-File -Encoding utf8 -FilePath $exportPath -NoNewline

#Sorts remaining groups into alphabetical order
$Sorter = $GroupList | Sort Name

#Add read-onlys back to the master list
ForEach ($listItem in $ReadOnlyList){
$listItem.OuterXML | Out-File -Encoding utf8 -FilePath $exportPath -Append -NoNewline
}
#Add the sorted folders back in
ForEach ($ChangedItem in $sorter){
$ChangedItem.OuterXML | Out-File -Encoding utf8 -FilePath $exportPath -Append -NoNewline
}
#End the file with /groups
"</groups>" | Out-File -Encoding utf8 -FilePath $exportPath -Append -NoNewline