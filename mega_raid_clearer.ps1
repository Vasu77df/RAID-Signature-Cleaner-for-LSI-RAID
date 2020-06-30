
function Start-Clearing {
    Write-Host "Clearing RAID configuration of Disk in Slot: $slot_number"
    Start-Sleep -Seconds 1
    Write-Host "Clearing Foreign Configuration......"
    .\MegaCli.exe -CfgForeign -Clear -aALL
    Start-Sleep -Seconds 1
    Write-Host "Making the Disk into Unconfigured Good if in Unconfigured Bad state (ignore failure if occurs)"
    .\MegaCli.exe -PDMakeGood -PhysDrv[64:$slot_number] -aALL
    Start-Sleep -Seconds 1
    Write-Host "Converting the Disk into JBOD mode....."
    .\MegaCli.exe -PDMakeJBOD -PhysDrv[64:$slot_number] -aALL
    Start-Sleep -Seconds 1
    Write-Host "----------------Done Clearing RAID Configuration---------------"
    Start-Sleep -Seconds 1
}

function Get-Confirmation {
    $OPT = Read-Host -Prompt "Are you sure you want to clear RAID configuration in slot: $slot_number ?[y/n] "
    
    switch ($OPT) {
        'Y' { Start-Clearing }
        #'y' { Start-Clearing }
        'Yes' { Start-Clearing }
        'yes' { Start-Clearing }
        'n' {break}
        'N' {break}
        'no' {break}
        'No' {break}
        Default {$OPT = Read-Host -Prompt "Please enter 'y' or 'n' "
        if ($OPT -eq "y") {
            Start-Clearing
            }
    }
    
}
}
$RESTART = $true
Do {
Write-Host "---------------------Welcome to RAID Cleaner-------------------"
Set-Location C:\Users\Administrator\Desktop\8-07-14_MegaCLI\Windows
Write-Host "List of all the available drives attached to the controller: "
.\MegaCli.exe -PDList -aALL | Select-String -Pattern "Enclosure Device Id", "Slot Number", "Drive's Position", "Device Id", "Firmware State", "Foreign State"

$nu_disk = Read-Host -Prompt "How many disks would you like to clear? "

if ( $nu_disk -notmatch "^[0-9]+$" ) {
    $nu_disk = Read-Host -Prompt "Invalid Input! Please enter the number of disks to be cleared "
}

for ($i = 0; $i -lt $nu_disk; $i++) {
    $slot_number = Read-Host -Prompt "You can clean the Foreign RAID configuration of the Disk by specifing the slot number(please enter the slot of disk one by one) "
    if ($slot_number -notmatch "^[0-9]+$") {
        $slot_number = Read-Host -Prompt "Invalid Input! Please enter the slot number: "
    }

    if (($slot_number -eq 0) -or ($slot_number -eq 1)) {
        $slot_number = Read-Host -Prompt "The Disk in the Slot you have chosen has O.S installed. Please choose a different slot: "
    }

    Get-Confirmation

    if ( $i -lt $nu_disk - 1) {
        Write-Host "---------------------------Next Disk---------------------------"
    }
}

Write-Host "--------------------- Current Configuration--------------------"
.\MegaCli.exe -PDList -aALL | Select-String -Pattern "Enclosure Device Id", "Slot Number", "Drive's Position", "Device Id", "Firmware State", "Foreign State"

Set-Location C:\Users\Administrator


Start-Sleep -Seconds 2
$EXIT_CONFIRMATION = Read-Host -Prompt "Would you like to exit the program?[y/n]"
if ($EXIT_CONFIRMATION -match 'y') {
    Write-Host "----------------------------Exiting----------------------------"
    $RESTART=$false
    Start-Sleep -Seconds 5
}else {
    $RESTART=$true
}
} While ($RESTART) 
