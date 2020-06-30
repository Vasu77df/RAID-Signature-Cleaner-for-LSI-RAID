# MegaRAID RAID-Signature-Cleaner

This is a guide to setup or run the Raid-Signature Cleaner Application on Either Windows or CentOS 6 Linux

## Running the application on existing machines with setup already completed

### On Windows Server

- Login to the machine as administrator

- Password: *Americaneagle#2020*

- Open PowerShell

- Navigate to Desktop Directory where the application resides using the command

```powershell
PS C:\Users> Set-Location C:\Users\Adminstrator\Desktop
```

- Run the application using the following command

```powershell
PS C:\Users> .\mega_raid_clearer.ps1
```

### On CentOS 6

- Login to the server as root 

- Password: *americaneagle2020*

- navigate to *root* directory

- run raid_clear.sh script by entering the cmd

```console
root@localhost:~$ bash raid_clear.sh
```

- or by make the file executable and run it this way!

 ```console
 root@localhost:~$ chmod +x raid_clear.sh
 root@localhost:~$ ./raid_clear.sh
 ```

## RAID Signature Cleaner Setup

This is a guide to create and a setup a server to erase RAID Signature of old disks using the MegaRAID controller's MegaCli Command Line tool or using the script developed for easier operation.

### Setup for Window Server

- Install Windows Server as usual and login as admin

- The **MegaCli** command line tool has to be downloaded and installed. This can be downloaded [here](https://www.broadcom.com/support/download-search?dk=megacli)

- Unzip the contents of the file and save it in the Desktop Directory.

- Download the *mega_raid_cleaner.ps1* Powershell script from [https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/raid_clear.sh](https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/raid_clear.sh)

- Save this file in the Desktop Directory and run the application using the following command 

```powershell
PS C:\Users> .\mega_raid_clearer.ps1
```

- You can also create your own powershell script by copying the contents below and editing as needed:

```powershell
Set-Location C:\Users\Administrator\Desktop\8-07-14_MegaCLI\Windows

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
    $OPT = Read-Host -Prompt "Are you sure you want to clear RAID configuration in slot: $slot_number ?[y/n]: "
    
    switch ($OPT) {
        'Y' { Start-Clearing }
        'y' { Start-Clearing }
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

Write-Host "---------------------Welcome to RAID Cleaner-------------------"
Write-Host "List of all the available drives attached to the controller: "
.\MegaCli.exe -PDList -aALL | Select-String -Pattern "Enclosure Device Id", "Slot Number", "Drive's Position", "Device Id", "Firmware State", "Foreign State"

$nu_disk = Read-Host -Prompt "How many disks would you like to clear?: "

if ( $nu_disk -notmatch "^[0-9]+$" ) {
    $nu_disk = Read-Host -Prompt "Invalid Input! Please enter the number of disks to be cleared: "
}

for ($i = 0; $i -lt $nu_disk; $i++) {
    $slot_number = Read-Host -Prompt "You can clean the Foreign RAID configuration of the Disk by specifing the slot number(please enter the slot of disk one by one): "
    if ($slot_number -notmatch "^[0-9]+$") {
        $slot_number = Read-Host -Prompt "Invalid Input! Please enter the slot number: "
    }

    if (($slot_number -eq 0) -or ($slot_number -eq 1)) {
        $slot_number = Read-Host -Prompt "The Disk in the Slot you have chosen has O.S installed. Please choose a different slot: "
    }

    Get-Confirmation

    if ( $i -lt $nu_disk) {
        Write-Host "---------------------------Next Disk---------------------------"
    }
}

Write-Host "--------------------- Current Configuration--------------------"
.\MegaCli.exe -PDList -aALL | Select-String -Pattern "Enclosure Device Id", "Slot Number", "Drive's Position", "Device Id", "Firmware State", "Foreign State"

Set-Location C:\Users\Administrator
Write-Host "----------------------------Exiting----------------------------"

Start-Sleep -Seconds 2

```

## Setup for Centos 6

---------------------------------

### Installing Centos 6

---------------------------------
IBM System X3550 M2 are installed with ServeRAID 1015 RAID Controllers this Hardware RAID Controller is only detected and supported in Centos 6 and Centos 7. They are not supported in Centos 8 and above.

##### Flashing USB Drive with Centos 6

-----------------------------------

First Centos 6 ISO has to bee flashed on an USB for us to install it onto or RAID Clearer Server. Use your workstation to complete this process.

- **Rufus** is an utility that helps format and create bootable USB flash disks. This can be downloaded from [here](https://rufus.ie/)

- **Centos 6** can be downloaded from [here](https://wiki.centos.org/Download)

Now create a bootable drive using **Rufus**.

![rufus setup](https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/images/rufus.png)

###### Installation and Setting up the Centos Environment for running the utility

----------------------------------------------

- Plug in the usb Drive to the server and enter the BIOS to choose the USB drive as boot drive.

- run through the installer as directed and setup your login credentials

- The username after intial installation is _root_ and the password is the credentials you have setup during installation

####### Downloading prerequistes and packages

For our utility to run certain prerequistes have to be installed and configured.

The **MegaCli** command line tool has to be downloaded and installed. This can be downloaded [here](https://www.broadcom.com/support/download-search?dk=megacli)

- Use your workstation to download this package and copy the _zip_ file to a USB Drive

![megacli download page](https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/images/mega_cli_download_page.png)

- Insert the USB drive to the server and copy the _zip_ file using the following command to the */root/Downloads* directory.

```console
root@localhost:~$ cp /media/usb_drive_name/8-07-14_MegaCLI /root/Downloads/
```

- The **unzip** utilit has to be installed to extraxt our _zip_ file. Use this command to install unzip. 

```console
root@localhost:~$ yum install unzip
```

- Navigate to the Downloads directory and unzip the downloaded MegaCli file using the following commands

```console
root@localhost:~$ cd Downloads/
root@localhost:~$ unzip 8-07-14_MegaCLI.zip
```

- Now navigate to the Linux directory to from the extracted folder and install the command line tool using the following command/ 

```console
root@localhost:~$ cd Linux/
root@localhost:~$ yum localinstall MegaCli-8.07.14-1.noarch.rpm
```

- Now Navigate to the home directory to directory and create and alias to easily use the command line tool.

```console
root@localhost:~$ cd ~
root@localhost:~$ alais megacli=/opt/MegaRAID/MegaCli/MegaCli64
```

- You can add this alias to the .bashrc file to permanently save the alias.

```console
root@localhost:~$ vi .bashrc
```

- append the alias command as shown above by entering _i_ to go into insert mode and the press _esc_ and enter _:wq_ to save and quit the file.

- Test the installation by entering the command.

```console
root@localhost:~$ megacli -h
```

**Now the MegCli RAID Command Line Tool is now installed** 

#### Setting up and running the RAID Cleaner Bash Script

- Download the *raid_clear.sh* Bash script from [https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/raid_clear.sh](https://github.com/Vasu77df/MegaRAID-RAID-Signature-Cleaner/blob/master/raid_clear.sh) and copy the script to an USB Drive.

- Copy the script from the USB Drive into the root directory */root* using the following command. 

```console
root@localhost:~$ cp /media/name_of_usbdrive/raid_clear.sh /root/
```

- You can run the script using the following command.

```console
root@localhost:~$ bash raid_clear.sh
```

- You can make the file executable and run it this way.

```console
root@localhost:~$ chmod +x raid_clear.sh
root@localhost:~$ ./raid_clear.sh
```

###### You can also copy the shell script and create your own bash script

```bash
#!/bin/bash

cd /opt/MegaRAID/MegaCli/

function clearing {
echo "Clearing RAID configuration of Disk in Slot: $slot_number"
        sleep 1 
echo "Clearing Foreign Configuration......"
        ./MegaCli64 -CfgForeign -Clear -aALL
        sleep 1
echo "Converting the Disk into JBOD mode....."
        ./MegaCli64 -PDMakeJBOD -PhysDrv[64:$slot_number] -aALL
        sleep 1
        echo "----------------Done Clearing RAID Configuration---------------"
        sleep 1
}

function getconfirmation() {
        read -p "Are you sure you want to clear RAID configuration in slot: $slot_number ?[y/n]: " -r opt
        case "$opt" in
                y|Y|yes|Yes)
                        clearing
                        ;;
                n|N|No|no)
                        return 1
                        ;;
                *)
                        echo "Please enter 'y' or 'n'"
                        return 1
                        ;;
        esac
}
echo "---------------------Welcome to RAID Cleaner-------------------"
echo "List of all available drives attached to the controller:"
./MegaCli64 -PDList -aALL | grep -i "enclosure device id\|slot number\|Drive's Position\|Device id\|Firmware state\|foreign state"
read -p "How many disks would you like to clear?: " -r nu_disks
if ! [[ $nu_disks =~ ^[0-9]+$ ]]
    then 
    read -p "Invalid Input! Please enter the number of disks to be cleared: " -r $nu_disks
fi

for (( c=1; c<=$nu_disks; c++))
do
        read -p "You can clean the Foreign RAID configuration of the Disk by specifing the slot number(please enter the slot of disk one by one): " -r slot_number
        if ! [[ $slot_number =~ ^[0-9]+$ ]]
        then 
                read -p "Invalid Input! Please enter the slot number: " -r $nu_disks
        fi

        getconfirmation

        if [ $c -lt $nu_disks ]; then
                echo "---------------------------Next Disk---------------------------"
        fi
done

echo "--------------------- Current Configuration--------------------"
./MegaCli64 -PDList -aALL | grep -i "enclosure device id\|slot number\|Drive's Position\|Device id\|Firmware state\|foreign state"

cd ~

echo "----------------------------Exiting----------------------------"
sleep 3

```

### Appendix A

#### MegaCli commands to manually erase the RAID Signature

To list all attached Drives:

```console
root@localhost:~$ megacli -PDList -aALL
```

To list only the useful parameters: 

```console
root@localhost:~$ megacli -PDList -aALL | grep -i "enclosure device id\|slot number\|Drive's Position\|Device id\|Firmware state\|foreign state"
```

To scan and clear all Foreign RAID Signature:

```console
root@localhost:~$ megacli -CfgForeign -Scan -aALL
root@localhost:~$ megacli -CfgForeign -Clear -aALL
```

Convert the Unconfigured Drives into JBOD Drives

```console
root@localhost:~$ Megacli -PDMakeJBOD -PhysDrv[64(enclosure id), 3(slot number)] -aN
```

