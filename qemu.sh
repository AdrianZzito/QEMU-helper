#! /bin/bash
# QEMU helper tool

### VARIABLES ###
# Size regex
re="^[0-9]+$"

# RAM memory array
memory_sizes=(1024 2048 4096 8192 16384 32768)

# Architectures
architectures=("ARM" "x86_64" "aarch64" "i386")

# Decision
option=1

### MAIN FUNCTIONS ###
# Create virtual disk
create_virtual_disk () {
    clear

    ## Virtual disk name
    echo 'Introduce the name of the virtual disk'
    read virtual_disk_name

    ## Virtual disk size
    echo 'Now enter the size of the virtual disk'
    read size

    size_formatted="${size}G"

    if ! [[ $size =~ $re ]]; then
        echo "ERROR: Not a number" >&2
        exit 1
    fi

    ## Command execution
    qemu-img create -f qcow2 $virtual_disk_name.qcow2 $size_formatted

    ## Command extra information
    echo "Virtual disk successfuly created"
    echo "Name: $virtual_disk_name"
    echo "Size: ${size}G"
}

# Create virtual machine
create_virtual_machine () {
    clear

    ## Architecture selection
    echo "Indique la arquitectura que va a usar"
    echo "${architectures[*]}"
    read arch

    formatted_arch="qemu-system-$arch"

    ## Memory selection
    echo "Enter the amount of ram that you want to use"
    read memory

    ## ISO selection
    echo 'Introduzca la ruta al archivo ISO'
    read iso

    if ! [ -f $iso ]; then
        echo "ERROR: result of the iso path: $iso is not a file" >&2
        exit 1
    fi

    ## Virtual disk selection
    echo 'Introduzca la ruta al disco virtual'
    read virtual_disk_path

    if ! [ -f $virtual_disk_path ]; then
        echo "ERROR: result of the virtual disk path: $virtual_disk_path is not a file" >&2
        exit 1
    fi

    ## Core selection
    echo "Indique el numero de nucleos que quiere usar"
    read cores

    ## Confirmation menu
    echo "You are about to create the following machine:"
    echo "Arch: $arch"
    echo "Memory: ${memory}MB"
    echo "ISO file: $iso"
    echo "Virtual disk: $virtual_disk_path"
    echo "Cores: $cores"
    read -p "Press Enter to continue..."

    ## Command execution
    $formatted_arch -boot d -cdrom $iso -hda $virtual_disk_path -smp $cores -m $memory
}

# Get virtual disk info
virtual_disk_info () {
    clear

    ## Virtual disk selection
    echo "Indica el disco virtual del que quiere obtener informacion"
    read virtual_disk

    if ! [[ -f $virtual_disk ]]; then
        echo "ERROR: the indicated resource is not a file" >&2
        exit 1
    fi

    ## Command execution
    qemu-img info $virtual_disk

}

## Modify virtual disk size
virtual_disk_size_modifier () {
    clear

    ## Virtual disk selector
    echo "Introduce la ruta al disco virtual que quiere modificar"
    read virtual_disk_name

    ## Space amount
    echo "Introduzca el numero de espacio que quiere agregar al disco"
    read added_space

    added_space_formatted="${added_space}G"

    ## Command execution
    qemu-img resize $virtual_disk_name +$added_space_formatted
}

## Open an existing virtual machine
open_virtual_machine () {
    clear

    ## Virtual disk path
    echo "Introduce la ruta al disco virtual de la maquina que quiere iniciar"
    read virtual_disk_path_open

    ## Ram amount
    echo "Introduce la cantidad de ram que quiere usar"
    read ram_amount

    ## Command execution
    qemu-system-x86_64 $virtual_disk_path_open -m $ram_amount
}

### HELPER FUNCTIONS ###
ram_shower () {

    echo "Choose the amount of ram that you want to use"
    echo "1. 1024"
    echo "2. 2048"
    echo "3. 4096"
    echo "4. 8192"
    echo "5. 16384"
    echo "6. Other"
    read decision

    if [ $decision -eq 1 ]; then
        return 1024
    elif [ $decision -eq 2 ]; then
        return 2048
    elif [ $decision -eq 3 ]; then
        return 4092
    elif [ $decision -eq 4 ]; then
        return 8192
    elif [ $decision -eq 5 ]; then
        return 16384
    elif [ $decision -eq 6 ]; then
        echo "Introduce the desired amount"
        read other_amount
        return $other_amount
    else 
        echo "Unknown amount" >&2
        exit 1
    fi

}

### MAIN LOGIC ###

## Option route
while [ $option -ne 6 ]
do

    ### MAIN MENU ###
    echo "Select the option you want to execute:"
    echo "1. Create a virtual disk"
    echo "2. Create a virtual machine"
    echo "3. Open an existing virtual machine"
    echo "4. Get virtual disk info"
    echo "5. Modify virtual disk size"
    echo "6. Exit"

    read option
    if [ $option -eq 1 ]; then
        create_virtual_disk
    elif [ $option -eq 2 ]; then
        create_virtual_machine
    elif [ $option -eq 3 ]; then
        open_virtual_machine
    elif [ $option -eq 4 ]; then
        virtual_disk_info
    elif [ $option -eq 5 ]; then
        virtual_disk_size_modifier
    fi
done