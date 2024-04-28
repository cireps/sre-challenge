#!/bin/bash
root_device=$(df / | awk 'NR==2 {print $1}')

#Isolating the disk and partition number
disk_=$(echo $root_device | sed -r 's/(.*[a-z])([0-9]+)$/\1/')
partition_number=$(echo $root_device | sed -r 's/.*[a-z]([0-9]+)$/\1/')

#Checking if the disk and partition number are empty
if [[ -z "$disk_" || -z "$partition_number" ]]; then 
    echo "Could not parse disk device from $root_device"
    exit 1
fi

#Expanding the disk
echo "Expanding disk $disk_ partition $partition_number"
sudo growpart $disk_ $partition_number
