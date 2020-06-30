#!/bin/bash

cd /opt/MegaRAID/MegaCli/

function clearing {
	echo "Clearing RAID configuration of Disk in Slot: $slot_number"
        sleep 1 
	echo "Clearing Foreign Configuration......"
        ./MegaCli64 -CfgForeign -Clear -aALL
        sleep 1
	echo "Making the Disk into Unconfigured Good if in Unconfigured Bad state (ignore failure if occurs)"
        ./MegaCli64 -PDMakeGood -PhysDrv[64:$slot_number] -aALL
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
echo "List of all available drives attached to the controller: "
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

        if ($slot_number = 0) || ($slot_number = 1); then
                read -p "The Disk in the Slot you have chosen has O.S installed. Please choose a different slot: " -r slot_number
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
