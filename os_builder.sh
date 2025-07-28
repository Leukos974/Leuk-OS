#!/bin/bash

if [ -z "$1" ]; then
    echo "USAGE: ./os_builder boot_file kernel_file os_name"
    exit 1
fi


if [ -z "$OS_TARGET" ]; then
    OS_env.sh
fi


echo "Assemble Boot file..."
$OS_PREFIX/bin/$OS_TARGET-as $1 -o boot.o

if [ ! -f boot.o ]; then
    echo "Stopping os_builder: boot.o not found"
    exit 1
else
    echo "OK"
fi


echo "Compile the kernel.."
$OS_PREFIX/bin/$OS_TARGET-gcc -c $2 -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra

if [ ! -f kernel.o ]; then
    echo "Stopping os_builder: kernel.o not found"
    exit 1
else
    echo "OK"
fi


echo "Linking OS..."
$OS_PREFIX/bin/$OS_TARGET-gcc -T linker.ld -o $3.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc

if [ ! -f $3.bin ]; then
    echo "Stopping os_builder: os.bin didnt link"
    exit 1
else
    cp $3.bin isodir/boot/$3.bin
    echo "OK"
fi

echo "Checking Multiboot..."
grub2-file --is-x86-multiboot $3.bin


if [ $? -ne 0 ]; then
    echo "The file is not multiboot"
    exit 1
else
    echo "Multiboot confirmed"
fi

echo "Creating .iso image..."
grub2-mkrescue -o $3.iso isodir

if [ ! -f $3.iso ]; then
    echo "Stopping os_builder: .iso file failed"
    exit 1
else
    echo "OK"
fi

echo "Done !"
echo "Test your os with qemu-system-TARGET -cdrom [YOUR-OS.iso]"
